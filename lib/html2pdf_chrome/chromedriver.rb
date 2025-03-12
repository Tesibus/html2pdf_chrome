module HTML2PDFChrome
  class Chromedriver
    ##
    # Starting chromedriver can be slow. This method initializes a single
    # driver instance to share. This driver is accessed via a Mutex to prevent
    # async caller's operations from bleeding into each other.
    #
    class << self
      def fetch_driver
        @driver ||= initialize_driver
        @semaphore ||= Mutex.new
        @semaphore.synchronize do
          yield @driver
        end
        nil
      end

      private

      def initialize_driver
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless=new')
        options.add_argument('--disable-gpu')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-software-rasterizer')

        Selenium::WebDriver.for(:chrome, options: options)
      end
    end
  end
end
