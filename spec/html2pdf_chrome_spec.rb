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
end
