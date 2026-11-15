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

## Configuration

Out of the box the gem leaves the choice of Chrome and chromedriver to Selenium, and starts Chrome with the arguments `--headless=new --disable-gpu --no-sandbox --disable-software-rasterizer`. Each of these can be changed:

```ruby
HTML2PDFChrome.configure do |config|
  # Start this Chrome binary.
  config.chrome_binary = "/path/to/chrome"

  # Start this chromedriver.
  config.chromedriver_path = "/path/to/chromedriver"

  # Replace the arguments Chrome is started with.
  config.chrome_arguments = %w[--headless=new --disable-gpu]
end
```

For example, `chrome-headless-shell` is always headless, so it is started without `--headless=new`:

```ruby
HTML2PDFChrome.configure do |config|
  config.chrome_binary = "/path/to/chrome-headless-shell"
  config.chrome_arguments -= ["--headless=new"]
end
```

These settings apply to this gem's driver only. Selenium's own process-wide settings, such as `Selenium::WebDriver::Chrome.path=`, still apply where a setting here is left unset.

Configure the gem before the first conversion. A Chrome that is already running keeps the settings it was started with.

## Errors

Before a page is printed, the gem checks that Chrome is on the page it was sent and has finished loading it. If it is not, the page is sent once more. If Chrome still has not loaded it, `HTML2PDFChrome::NavigationError` (a subclass of `HTML2PDFChrome::Error`) is raised and no PDF is returned.
