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

    it 'should group lines by tax rate' do
      expect(invoice.sub_totals.keys).to match_array(['10'.to_d, '20'.to_d])
    end

    it 'should get subtotals right' do
      sub10 = invoice.sub_totals['10'.to_d]
      expect(sub10.before_tax).to eq('5'.to_d)
      expect(sub10.after_tax).to eq('5.5'.to_d)
    end

    it 'should get total right' do
      expect(invoice.total.before_tax).to eq('7.4'.to_d)
      expect(invoice.total.after_tax).to eq('8.38'.to_d)
    end

  end

end
