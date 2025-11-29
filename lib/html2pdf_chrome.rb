# frozen_string_literal: true

require 'base64'
require 'selenium-webdriver'

require_relative "html2pdf_chrome/version"

require_relative "./html2pdf_chrome/chromedriver"
require_relative "./html2pdf_chrome/html_converter"

module HTML2PDFChrome
  class Error < StandardError; end

  def self.convert_html_to_pdf(html, header_template: "<div></div>", footer_template: "<div></div>")
    HtmlConverter.new(html, header_template:, footer_template:).convert_to_pdf!
  end
end
