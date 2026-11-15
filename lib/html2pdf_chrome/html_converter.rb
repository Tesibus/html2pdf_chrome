module HTML2PDFChrome
  class HtmlConverter
    # The page ChromeDriver opens a new browser on.
    START_PAGE = "data:,"
    READY_STATES = %w[loading interactive complete].freeze

    attr_reader :html, :header_template, :footer_template

    def initialize(html, header_template: "<div></div>", footer_template: "<div></div>")
      @html = html
      @header_template = header_template
      @footer_template = footer_template
    end

    def convert_to_pdf!
      encoded_html = Base64.strict_encode64(html)
      data_url = "data:text/html;base64,#{encoded_html}"

      pdf_data = nil
      Chromedriver.fetch_driver do |driver|
        driver.navigate.to(data_url)
        ensure_page_loaded!(driver, data_url)
        cdp_response = driver.execute_cdp(
          'Page.printToPDF',
          displayHeaderFooter: true,
          printBackground: true,
          headerTemplate: header_template,
          footerTemplate: footer_template,
        )
        pdf_data = Base64.decode64(cdp_response['data'])
      end
      pdf_data
    end

    private

    ##
    # `navigate.to` can return before Chrome has committed the page, and a
    # print taken then is a PDF of the page Chrome was still on, such as the
    # blank start page of a new browser. So before printing, Chrome must be on
    # the URL it was sent to with the document fully loaded. On a miss the page
    # is sent once more; if that misses too, nothing is printed.
    #
    def ensure_page_loaded!(driver, url)
      return if page_loaded?(driver, url)

      warn "[html2pdf_chrome] the page was not loaded after navigation " \
           "(#{describe_page(driver, url)}); navigating again once"
      driver.navigate.to(url)
      return if page_loaded?(driver, url)

      raise NavigationError,
            "Chrome did not load the page it was sent (#{describe_page(driver, url)}) " \
            "after navigating again once; refusing to print"
    end

    def page_loaded?(driver, url)
      on_sent_url?(driver.current_url, url) && ready_state(driver) == "complete"
    end

    # The sent URL is base64 and holds no "#", so anything from a "#" on is a
    # fragment the document gave itself.
    def on_sent_url?(current_url, url)
      current_url.to_s.split("#", 2).first == url
    end

    # Where Chrome is, for a warning or an error. The URL is the document
    # itself and readyState is the page's to answer, so neither is repeated.
    def describe_page(driver, url)
      current_url = driver.current_url
      page =
        if current_url == START_PAGE
          "on the start page"
        elsif on_sent_url?(current_url, url)
          "on the sent page"
        else
          "on another page"
        end
      state = ready_state(driver)
      state = "unexpected" unless READY_STATES.include?(state)
      "#{page}, readyState #{state.inspect}"
    end

    # A read that the page's own script breaks counts as not loaded.
    def ready_state(driver)
      driver.execute_script("return document.readyState")
    rescue Selenium::WebDriver::Error::JavascriptError
      nil
    end
  end
end
