# frozen_string_literal: true

RSpec.describe HTML2PDFChrome::Chromedriver do
  describe ".fetch_driver" do
    it 'yields the selenium webdriver singleton' do
      expect do |block|
        described_class.fetch_driver(&block)
      end.to yield_with_args(Selenium::WebDriver::Chrome::Driver)
    end

    it 'returns nil' do
      expect(described_class.fetch_driver {}).to eq(nil)
    end
  end

  # The examples below start no Chrome: Selenium is stubbed.
  context "with Selenium stubbed" do
    let(:drivers) { [] }

    # Sets the shared driver aside, so that these examples start their own and
    # leave no stand-in behind for an example that needs a real Chrome.
    around do |example|
      shared_driver = described_class.instance_variable_get(:@driver)
      described_class.instance_variable_set(:@driver, nil)
      example.run
    ensure
      described_class.instance_variable_set(:@driver, shared_driver)
    end

    before do
      allow(Selenium::WebDriver).to receive(:for) do
        double("driver", quit: nil).tap { |driver| drivers << driver }
      end
    end

    def yielded_drivers(calls)
      Array.new(calls) do
        yielded = nil
        described_class.fetch_driver { |driver| yielded = driver }
        yielded
      end
    end

    # Returns once every thread is waiting. Fails, rather than hangs, if one
    # of them dies or never waits.
    def wait_until_blocked(*threads)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
      until threads.all? { |thread| thread.status == "sleep" }
        threads.each { |thread| thread.join unless thread.alive? }
        raise "a call did not wait" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

        sleep 0.01
      end
    end

    describe "the driver's lifetime" do
      it 'starts one driver, shares it between calls and does not quit it' do
        expect(yielded_drivers(2)).to eq([drivers.first, drivers.first])
        expect(drivers.size).to eq(1)
        expect(drivers.first).not_to have_received(:quit)
      end

      it 'starts one driver when the first calls arrive together' do
        gate = Queue.new
        allow(Selenium::WebDriver).to receive(:for) do
          gate.pop # holds the start until both calls have arrived
          double("driver", quit: nil).tap { |driver| drivers << driver }
        end

        calls = Array.new(2) { Thread.new { described_class.fetch_driver {} } }
        begin
          wait_until_blocked(*calls)
          2.times { gate << :start }
          expect(calls.map { |call| call.join(5) }).to eq(calls)
        ensure
          calls.each(&:kill) # so that a failure here cannot leave the lock held
        end

        expect(drivers.size).to eq(1)
      end
    end
  end
end
