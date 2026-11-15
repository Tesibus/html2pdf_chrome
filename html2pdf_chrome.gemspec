# frozen_string_literal: true

require_relative "lib/html2pdf_chrome/version"

Gem::Specification.new do |spec|
  spec.name = "html2pdf_chrome"
  spec.version = HTML2PDFChrome::VERSION
  spec.authors = ["Jonathan Hooper"]
  spec.email = ["jon9820@gmail.com"]

  spec.summary = "A gem for generating PDFs from HTML using Chromedriver."
  spec.description = "This gem is built to convert HTML document into PDFs. There are lots of tools out there that do this. This one uses Selenium+Chromedriver to render the HTML and generate the PDF."
  spec.homepage = "https://github.com/Tesibus/html2pdf_chrome"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Tesibus/html2pdf_chrome"

  # Specify which files should be added to the gem when it is released.
  # They are listed from the directory itself, so the list is the same whether
  # or not the directory is a git checkout and whether or not git is installed.
  spec.files = Dir.glob(%w[lib/**/* sig/**/* exe/* LICENSE.txt README.md], base: __dir__).select do |path|
    File.file?(File.join(__dir__, path))
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "selenium-webdriver"
end
