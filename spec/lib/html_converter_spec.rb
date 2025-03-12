# frozen_string_literal: true

RSpec.describe HTML2PDFChrome::HtmlConverter do
  describe ".fetch_driver" do
    it 'converts HTML to a PDF document' do
      html = "<h1>Hello, world</h1>"
      pdf_data = described_class.new(html).convert_to_pdf!

      expect(pdf_data[0..4]).to eq('%PDF-')
    end
  end
end
