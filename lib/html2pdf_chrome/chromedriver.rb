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
        configuration = HTML2PDFChrome.configuration
        options = Selenium::WebDriver::Chrome::Options.new
        configuration.chrome_arguments.each { |argument| options.add_argument(argument) }
        options.binary = configuration.chrome_binary if configuration.chrome_binary

        if configuration.chromedriver_path
          service = Selenium::WebDriver::Service.chrome(path: configuration.chromedriver_path)
          Selenium::WebDriver.for(:chrome, options: options, service: service)
        else
          Selenium::WebDriver.for(:chrome, options: options)
        end
      end
    end
  end
end
