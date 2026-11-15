# frozen_string_literal: true

RSpec.describe HTML2PDFChrome do
  it "has a version number" do
    expect(HTML2PDFChrome::VERSION).not_to be nil
  end

  it "has a PDF conversion method" do
    my_html = "<p>This PDF just has this paragraph</p>"
    pdf_data = HTML2PDFChrome.convert_html_to_pdf(my_html)
    expect(pdf_data).to start_with("%PDF")
  end

  it "converts with a Chrome of its own, and quits it, when the driver is not reused" do
    configuration = HTML2PDFChrome::Configuration.new
    configuration.reuse_driver = false
    allow(HTML2PDFChrome).to receive(:configuration).and_return(configuration)
    started = []
    allow(Selenium::WebDriver).to receive(:for).and_wrap_original do |start, *arguments, **options|
      start.call(*arguments, **options).tap do |driver|
        allow(driver).to receive(:quit).and_call_original
        started << driver
      end
    end

    pdf_data = HTML2PDFChrome.convert_html_to_pdf("<p>This PDF just has this paragraph</p>")

    expect(pdf_data).to start_with("%PDF")
    expect(started.size).to eq(1)
    expect(started.first).to have_received(:quit).once
  end
end
