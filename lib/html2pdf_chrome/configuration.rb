module HTML2PDFChrome
  ##
  # How Chrome is started. Set these before the first conversion: a Chrome
  # that is already running keeps the settings it was started with.
  #
  class Configuration
    DEFAULT_CHROME_ARGUMENTS = %w[
      --headless=new
      --disable-gpu
      --no-sandbox
      --disable-software-rasterizer
    ].freeze

    # The command line arguments Chrome is started with.
    attr_accessor :chrome_arguments

    # The path of the Chrome binary to start. When nil, the choice is left to
    # Selenium.
    attr_accessor :chrome_binary

    # The path of the chromedriver to start. When nil, the choice is left to
    # Selenium, which finds or downloads one.
    attr_accessor :chromedriver_path

    def initialize
      @chrome_arguments = DEFAULT_CHROME_ARGUMENTS.dup
      @chrome_binary = nil
      @chromedriver_path = nil
    end
  end
end
