require "spec_helper"

RSpec.describe Invoices do
  it "has a version number" do
    expect(Invoices::VERSION).not_to be nil
  end



  context 'creating an invoice' do
    invoice = Invoices::Invoice.new [
      Invoices::Line.new(article:'one',   units:'1', price:'1.1', tax_rate:'10'),
      Invoices::Line.new(article:'two',   units:'2', price:'1.2', tax_rate:'20'),
      Invoices::Line.new(article:'three', units:'3', price:'1.3', tax_rate:'10'),
    ]

    it 'should add up all lines' do
      expect(invoice.total.num_lines).to eq(3)
    end
  end

end
