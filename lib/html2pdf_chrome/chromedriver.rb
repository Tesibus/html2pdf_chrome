module HTML2PDFChrome
  class Chromedriver
    # Created when the class is loaded, so that every caller takes the same one.
    @semaphore = Mutex.new

    ##
    # Starting chromedriver can be slow. This method initializes a single
    # driver instance to share. This driver is accessed via a Mutex to prevent
    # async caller's operations from bleeding into each other.
    #
    class << self
      def fetch_driver
        @semaphore.synchronize do
          @driver ||= initialize_driver
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
