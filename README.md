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

### Custom Headers and Footers

You can also specify custom header and footer templates for your PDFs:

```ruby
require "html2pdf_chrome"

my_html = "<h1>My Document</h1><p>Content goes here</p>"

header = "<div style='font-size: 10px; text-align: center; width: 100%;'>My Custom Header</div>"

footer = <<~HTML
  <div style="font-size: 10px; text-align: center; width: 100%;">
    Page <span class="pageNumber"></span> of <span class="totalPages"></span>
  </div>
HTML

pdf_data = HTML2PDFChrome.convert_html_to_pdf(
  my_html,
  header_template: header,
  footer_template: footer
)

File.write("my_pdf.pdf", pdf_data)
```

The header and footer templates support HTML and CSS styling. You can use special Chrome variables for pagination:
- `<span class="pageNumber"></span>` - Current page number
- `<span class="totalPages"></span>` - Total number of pages
- `<span class="date"></span>` - Current date
- `<span class="title"></span>` - Document title
- `<span class="url"></span>` - Document URL
