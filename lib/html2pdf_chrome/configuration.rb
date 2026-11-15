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

    # Whether one Chrome is started on first use and shared by every
    # conversion (true, the default) or each conversion starts a Chrome of its
    # own and quits it when it is done (false). A shared Chrome makes each
    # conversion faster and stays running for the life of the process; a
    # Chrome per conversion is slower and is quit as soon as its conversion is
    # done.
    attr_accessor :reuse_driver

    def initialize
      @chrome_arguments = DEFAULT_CHROME_ARGUMENTS.dup
      @chrome_binary = nil
      @chromedriver_path = nil
      @reuse_driver = true
    end
  end
end
