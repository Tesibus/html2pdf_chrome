module HTML2PDFChrome
  class HtmlConverter
    attr_reader :html

    def initialize(html)
      @html = html
    end

    def convert_to_pdf!
      encoded_html = Base64.strict_encode64(html)
      data_url = "data:text/html;base64,#{encoded_html}"

      pdf_data = nil
      Chromedriver.fetch_driver do |driver|
        driver.navigate.to(data_url)
        cdp_response = driver.execute_cdp('Page.printToPDF')
        pdf_data = Base64.decode64(cdp_response['data'])
      end
      pdf_data
    end
  end
end
