# frozen_string_literal: true

require 'base64'
require 'selenium-webdriver'

require_relative "html2pdf_chrome/version"

require_relative "./html2pdf_chrome/chromedriver"
require_relative "./html2pdf_chrome/html_converter"

module HTML2PDFChrome
  class Error < StandardError; end

  def self.convert_html_to_pdf(html)
    HtmlConverter.new(html).convert_to_pdf!
  end
end
