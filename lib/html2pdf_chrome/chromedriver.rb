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

        # Self-hosted arm64 CI: Google publishes no linux/arm64 chromedriver,
        # so selenium-manager cannot provision one there. CHROMEDRIVER_BIN
        # (the chromium snap's own driver) supplies it — and the snap driver
        # launches its OWN paired in-snap browser, so no binary may be set
        # alongside it (a snap-confined driver cannot exec the /snap/bin
        # wrapper; FGL hub runbook §Chrome-on-arm64 — same wiring as
        # expeal-app's spec/support/capybara.rb). CHROME_BIN alone still
        # points selenium-manager at a custom browser. Both unset on hosted
        # runners, local dev, and Heroku (chrome-for-testing buildpack), where
        # behavior is unchanged.
        if ENV['CHROMEDRIVER_BIN']
          service = Selenium::WebDriver::Chrome::Service.new(path: ENV['CHROMEDRIVER_BIN'])
          Selenium::WebDriver.for(:chrome, options: options, service: service)
        else
          options.binary = ENV['CHROME_BIN'] if ENV['CHROME_BIN']
          Selenium::WebDriver.for(:chrome, options: options)
        end
      end
    end
  end
end
