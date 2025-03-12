# HTML2PDFChrome

This gem provides a tool for converting HTML documents to PDFs.

There are a lof of tools out there that do this. This one uses Chromedriver to render the HTML and convert it to a PDF. It uses Selenium to fire up Chromedriver.

## Installation

This gem can be installed with rubygems:

```ruby
gem "html2pdf_chrome"
```

You will, of course, also need a working Google Chrome and Chromedriver installation. Chromedriver can be downloaded from Google or it can be installed via homebrew.

## Usage

Once everything is installed using it is pretty easy:

```ruby
require "html2pdf_chrome"
my_html = "<p>This PDF just has this paragraph</p>"
pdf_data = HTML2PDFChrome.convert_html_to_pdf(my_html)
File.write("my_pdf.pdf", pdf_data)
```
