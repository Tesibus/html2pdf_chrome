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
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "selenium-webdriver"
end
