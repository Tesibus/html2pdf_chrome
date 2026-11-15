# frozen_string_literal: true

RSpec.describe HTML2PDFChrome::Configuration do
  it 'starts Chrome with the default arguments' do
    expect(described_class.new.chrome_arguments).to eq(
      %w[--headless=new --disable-gpu --no-sandbox --disable-software-rasterizer]
    )
  end

  it 'leaves the Chrome binary and the chromedriver for Selenium to find' do
    configuration = described_class.new

    expect(configuration.chrome_binary).to be_nil
    expect(configuration.chromedriver_path).to be_nil
  end

  it 'keeps a change to one list of arguments out of the defaults' do
    described_class.new.chrome_arguments << "--hide-scrollbars"

    expect(described_class.new.chrome_arguments).not_to include("--hide-scrollbars")
  end

  describe "HTML2PDFChrome.configure" do
    around do |example|
      chrome_binary = HTML2PDFChrome.configuration.chrome_binary
      example.run
    ensure
      HTML2PDFChrome.configuration.chrome_binary = chrome_binary
    end

    it 'yields the configuration the gem reads' do
      HTML2PDFChrome.configure do |config|
        config.chrome_binary = "/path/to/chrome"
      end

      expect(HTML2PDFChrome.configuration.chrome_binary).to eq("/path/to/chrome")
    end
  end
end
