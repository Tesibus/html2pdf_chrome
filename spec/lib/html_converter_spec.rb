# frozen_string_literal: true

RSpec.describe HTML2PDFChrome::HtmlConverter do
  describe ".fetch_driver" do
    it 'converts HTML to a PDF document' do
      html = "<h1>Hello, world</h1>"
      pdf_data = described_class.new(html).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with custom header template to PDF' do
      html = "<h1>Hello, world</h1>"
      header = "<div style='font-size: 10px; text-align: center;'>Custom Header</div>"
      pdf_data = described_class.new(html, header_template: header).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with custom footer template to PDF' do
      html = "<h1>Hello, world</h1>"
      footer = <<~HTML
        <div style="font-size:10px; text-align:right; width:100%; padding-right:20px;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span>
        </div>
      HTML
      pdf_data = described_class.new(html, footer_template: footer).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end

    it 'converts HTML with both custom header and footer templates to PDF' do
      html = "<h1>Hello, world</h1>"
      header = "<div style='font-size: 10px; text-align: center;'>Custom Header</div>"
      footer = "<div style='font-size: 10px; text-align: center;'>Page <span class='pageNumber'></span></div>"
      pdf_data = described_class.new(html, header_template: header, footer_template: footer).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end
  end
end
