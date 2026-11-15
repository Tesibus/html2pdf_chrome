# frozen_string_literal: true

RSpec.describe HTML2PDFChrome::HtmlConverter do
  describe ".fetch_driver" do
    it 'converts HTML to a PDF document' do
      html = "<h1>Hello, world</h1>"
      pdf_data = described_class.new(html).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with custom header template to PDF' do
      html = "<h1>Hello, world</h1>"
      header = "<div style='font-size: 10px; text-align: center;'>Custom Header</div>"
      pdf_data = described_class.new(html, header_template: header).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with custom footer template to PDF' do
      html = "<h1>Hello, world</h1>"
      footer = <<~HTML
        <div style="font-size:10px; text-align:right; width:100%; padding-right:20px;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span>
        </div>
      HTML
      pdf_data = described_class.new(html, footer_template: footer).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with both custom header and footer templates to PDF' do
      html = "<h1>Hello, world</h1>"
      header = "<div style='font-size: 10px; text-align: center;'>Custom Header</div>"
      footer = "<div style='font-size: 10px; text-align: center;'>Page <span class='pageNumber'></span></div>"
      pdf_data = described_class.new(html, header_template: header, footer_template: footer).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end
  end

  # The examples below use a stand-in for the driver, so that they can decide
  # where Chrome is when the converter looks.
  let(:html) { "<h1>Hello, world</h1><p>Private text</p>" }
  let(:sent_url) { "data:text/html;base64,#{Base64.strict_encode64(html)}" }
  let(:pdf_bytes) { "%PDF-1.7 stand-in" }
  let(:cdp_response) { { "data" => Base64.strict_encode64(pdf_bytes) } }

  # Each navigate.to takes the next of `landings` as the page current_url then
  # reads (:sent is the URL it was sent to); `ready` is what
  # document.readyState answers. Chrome starts on ChromeDriver's blank page.
  # The driver is a plain double: Selenium adds execute_cdp to a driver when
  # it is created, so the class does not declare it.
  def stand_in_driver(landings:, ready: "complete")
    current = "data:,"
    queue = landings.dup
    navigation = instance_double(Selenium::WebDriver::Navigation)
    allow(navigation).to receive(:to) do |url|
      landing = queue.shift
      current = landing == :sent ? url : landing
    end
    driver = double("driver", navigate: navigation)
    allow(driver).to receive(:current_url) { current }
    allow(driver).to receive(:execute_script).with("return document.readyState") { ready }
    allow(driver).to receive(:execute_cdp).and_return(cdp_response)
    allow(HTML2PDFChrome::Chromedriver).to receive(:fetch_driver).and_yield(driver)
    driver
  end

  def convert
    described_class.new(html).convert_to_pdf!
  end

  describe "checking the page before printing" do
    it 'prints the page it navigated to, navigating once' do
      driver = stand_in_driver(landings: [:sent])

      expect { expect(convert).to eq(pdf_bytes) }.not_to output.to_stderr
      expect(driver.navigate).to have_received(:to).with(sent_url).once
      expect(driver).to have_received(:execute_cdp).once
    end

    it 'refuses to print when Chrome stays on the start page, after navigating again once' do
      driver = stand_in_driver(landings: ["data:,", "data:,"])

      expect do
        expect { convert }.to raise_error(
          HTML2PDFChrome::NavigationError, /did not load the page it was sent \(on the start page/
        )
      end.to output(/navigating again once/).to_stderr
      expect(driver).not_to have_received(:execute_cdp)
      expect(driver.navigate).to have_received(:to).with(sent_url).twice
    end

    it 'prints once when Chrome lands on the second try, and warns about the miss' do
      driver = stand_in_driver(landings: ["data:,", :sent])

      expect { expect(convert).to eq(pdf_bytes) }.to output(
        /\A\[html2pdf_chrome\] .*on the start page.*navigating again once/
      ).to_stderr
      expect(driver.navigate).to have_received(:to).with(sent_url).twice
      expect(driver).to have_received(:execute_cdp).once
    end

    it 'counts the sent page still loading as a miss' do
      driver = stand_in_driver(landings: [:sent, :sent], ready: "loading")

      expect do
        expect { convert }.to raise_error(
          HTML2PDFChrome::NavigationError, /on the sent page, readyState "loading"/
        )
      end.to output.to_stderr
      expect(driver).not_to have_received(:execute_cdp)
    end

    it 'refuses any page but the one it sent' do
      driver = stand_in_driver(landings: ["about:blank", "about:blank"])

      expect do
        expect { convert }.to raise_error(HTML2PDFChrome::NavigationError, /on another page/)
      end.to output.to_stderr
      expect(driver).not_to have_received(:execute_cdp)
    end

    it 'raises an error that callers rescuing HTML2PDFChrome::Error already catch' do
      stand_in_driver(landings: ["data:,", "data:,"])

      expect do
        expect { convert }.to raise_error(HTML2PDFChrome::Error)
      end.to output.to_stderr
    end

    # The URL is the document itself, base64 encoded.
    it 'keeps the document out of the warning and the error' do
      stand_in_driver(landings: ["data:,", "data:,"])
      encoded = Base64.strict_encode64(html)

      expect do
        expect { convert }.to raise_error(HTML2PDFChrome::NavigationError) { |error|
          expect(error.message).not_to include(encoded[0, 24])
          expect(error.message).not_to include("Private text")
        }
      end.to output(
        satisfy do |warning|
          warning.include?("navigating again") && !warning.include?(encoded[0, 24]) && !warning.include?("Private text")
        end
      ).to_stderr
    end

    # document.readyState is the page's to answer, so only its three standard
    # values are ever repeated.
    it 'names a non-standard readyState generically, never its value' do
      stand_in_driver(landings: [:sent, :sent], ready: "Private text")

      expect do
        expect { convert }.to raise_error(HTML2PDFChrome::NavigationError, /readyState "unexpected"/) { |error|
          expect(error.message).not_to include("Private text")
        }
      end.to output(
        satisfy { |warning| warning.include?("navigating again") && !warning.include?("Private text") }
      ).to_stderr
    end

    it "counts a readiness read that the page's script breaks as a miss" do
      driver = stand_in_driver(landings: [:sent, :sent])
      allow(driver).to receive(:execute_script).with("return document.readyState")
        .and_raise(Selenium::WebDriver::Error::JavascriptError, "javascript error: Private text")

      expect do
        expect { convert }.to raise_error(HTML2PDFChrome::NavigationError, /refusing to print/) { |error|
          expect(error.message).not_to include("Private text")
        }
      end.to output.to_stderr
      expect(driver).not_to have_received(:execute_cdp)
    end

    # With a real Chrome: an ordinary conversion must pass the check the first
    # time, or every document would be loaded twice.
    it 'finds a real Chrome on the sent page at the first check' do
      pdf_data = nil

      expect { pdf_data = convert }.not_to output(/navigating again/).to_stderr
      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'finds a real Chrome on the sent page when the document is large' do
      large_html = "<p>#{'Is this a long document? ' * 20_000}</p>"
      expect(Base64.strict_encode64(large_html)).to include("/")
      pdf_data = nil

      expect { pdf_data = described_class.new(large_html).convert_to_pdf! }
        .not_to output(/navigating again/).to_stderr
      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'prints a page that is on the sent URL with a fragment of its own' do
      driver = stand_in_driver(landings: ["#{sent_url}#top"])

      expect { expect(convert).to eq(pdf_bytes) }.not_to output.to_stderr
      expect(driver.navigate).to have_received(:to).once
    end

    it 'prints, with a real Chrome, a document whose script gives its URL a fragment' do
      fragment_html = '<h1>Hello, world</h1><script>history.replaceState(null, "", "#top")</script>'
      pdf_data = nil

      expect { pdf_data = described_class.new(fragment_html).convert_to_pdf! }
        .not_to output(/navigating again/).to_stderr
      expect(pdf_data[0..4]).to eq('%PDF-')
    end
  end

  describe "retrying a failed print" do
    let(:printing_failed) do
      Selenium::WebDriver::Error::UnknownError.new(
        'unhandled inspector error: {"code":-32000,"message":"Printing failed"}'
      )
    end

    it 'retries once when Chrome answers "Printing failed", and warns about it' do
      driver = stand_in_driver(landings: [:sent])
      calls = 0
      allow(driver).to receive(:execute_cdp) do
        calls += 1
        raise printing_failed if calls == 1

        cdp_response
      end

      expect { expect(convert).to eq(pdf_bytes) }.to output(
        /\A\[html2pdf_chrome\] .*retrying once/
      ).to_stderr
      expect(calls).to eq(2)
      expect(driver.navigate).to have_received(:to).once
    end

    it 'raises the second failure unchanged' do
      driver = stand_in_driver(landings: [:sent])
      allow(driver).to receive(:execute_cdp).and_raise(printing_failed)

      expect do
        expect { convert }.to raise_error(Selenium::WebDriver::Error::UnknownError, /Printing failed/)
      end.to output.to_stderr
      expect(driver).to have_received(:execute_cdp).twice
    end

    it 'does not retry another error that carries the same code' do
      driver = stand_in_driver(landings: [:sent])
      allow(driver).to receive(:execute_cdp).and_raise(
        Selenium::WebDriver::Error::UnknownError.new(
          'unhandled inspector error: {"code":-32000,"message":"Invalid parameters"}'
        )
      )

      expect do
        expect { convert }.to raise_error(Selenium::WebDriver::Error::UnknownError, /Invalid parameters/)
      end.not_to output.to_stderr
      expect(driver).to have_received(:execute_cdp).once
    end

    it 'does not retry another class of error' do
      driver = stand_in_driver(landings: [:sent])
      allow(driver).to receive(:execute_cdp).and_raise(
        Selenium::WebDriver::Error::TimeoutError.new("timed out")
      )

      expect do
        expect { convert }.to raise_error(Selenium::WebDriver::Error::TimeoutError, /timed out/)
      end.not_to output.to_stderr
      expect(driver).to have_received(:execute_cdp).once
    end
  end
end
