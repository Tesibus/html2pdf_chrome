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
end
