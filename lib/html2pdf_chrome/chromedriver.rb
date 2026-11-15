module HTML2PDFChrome
  class Chromedriver
    # Created when the class is loaded, so that every caller takes the same one.
    @semaphore = Mutex.new

    ##
    # Starting chromedriver can be slow. This method initializes a single
    # driver instance to share. This driver is accessed via a Mutex to prevent
    # async caller's operations from bleeding into each other.
    #
    # With `reuse_driver` turned off in the configuration, each call starts a
    # driver of its own instead and quits it when its block is done.
    #
    class << self
      def fetch_driver(&block)
        return fetch_own_driver(&block) unless HTML2PDFChrome.configuration.reuse_driver

        @semaphore.synchronize do
          @driver ||= initialize_driver
          yield @driver
        end
        nil
      end

      private

      ##
      # Starts a driver for this call alone and quits it when the block is
      # done, whether the block returned or raised. Calls still run one at a
      # time.
      #
      def fetch_own_driver
        @semaphore.synchronize do
          driver = initialize_driver
          begin
            yield driver
          ensure
            quit_quietly(driver)
          end
        end
        nil
      end

      # A driver that cannot be quit (its Chrome is already gone, say) must
      # not replace the block's own result or error.
      def quit_quietly(driver)
        driver.quit
      rescue StandardError => e
        warn "[html2pdf_chrome] the driver could not be quit: #{e.class}: #{e.message}"
      end

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
