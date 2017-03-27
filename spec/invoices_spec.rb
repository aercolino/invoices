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



  context 'creating the sample invoice from requirements' do
    invoice_lines = <<~END
      PRINGLES CEBOLLA 190 GR         |     2     |     1,7364 € |    10     |
      BARRITAS HUESITOS PACK 12X20GR  |     1     |     2,3000 € |    10     |
      COOKIE AVELL CHOC CARREF 200G   |     2     |     0,7364 € |    10     |
      G.SANDW.YOGUR DIET NAT.GUL220G  |     1     |     1,7273 € |    10     |
      BARRITA TWIX 6 UNDS X 58 GR     |     2     |     2,5455 € |    10     |
      CHOC.SNICKERS 4X 50 GRS         |     1     |     1,7909 € |    10     |
      PASTAS DE TE DELITEA 400 GR     |     1     |     1,7909 € |    10     |
      TE FRUTAS DEL BOSQUE LIPTON 20  |     1     |     1,7727 € |    10     |
      PALMERITAS EL PONTON 380 GRS    |     2     |     2,5455 € |    10     |
      CHEETOS STICKS 96 GRS           |     2     |     1,0727 € |    10     |
      CHEETOS RIZOS 125GR             |     2     |     1,4909 € |    10     |
      CHEETOS CRUNCHETOS 130 GRS      |     2     |     1,0182 € |    10     |
      TUC QUESO 100 GRS               |     2     |     1,0000 € |    10     |
      TUC CREAM&ONION 100 GRS         |     2     |     1,0000 € |    10     |
      ENERG.MONSTER ZERO 500ML        |     5     |     0,5091 € |    10     |
      ENERG.MONSTER ZERO 500ML        |     5     |     1,0364 € |    10     |
      CROISSANT CACAO CASADO 360G     |     2     |     1,1727 € |    10     |
      ALMENDRA TOSTAD.COMUN CRF 200G  |     1     |     2,5455 € |    10     |
      SNATTS PIPAS 4X40 GR            |     1     |     1,9091 € |    10     |
      TORTITAS MAIZ OLIVAS/CEBOLLINO  |     1     |     1,6545 € |    10     |
      TORTITA MAIZ QUESO&ALBAHACA124  |     1     |     1,6727 € |    10     |
      ENERGETICO RED BULL 25 CL P-8   |     3     |     6,6455 € |    10     |
      20 CUCHA TRANSPARENTES API CA   |     2     |     0,8182 € |    21     |
      AZUCAR BLANCA AZUCARERA 1,5 KG  |     1     |     0,9727 € |    10     |
      GOMINOLA HARIBO OSITO ORO 275G  |     1     |     2,0818 € |    10     |
      PRINGLES XTRA BARBACOA 175G     |     1     |     1,8636 € |    10     |
      PRINGLES ORIGINAL 190 GR        |     2     |     1,7364 € |    10     |
      CAFE INTENSO CRF CAPSULAS 30UD  |     1     |     4,9091 € |    10     |
      CAFE EXTRAFUERTE CRF CAPS 30UD  |     1     |     4,9091 € |    10     |
      CAFE SUAVE CRF CAPSULAS 30UDS   |     1     |     4,9091 € |    10     |
      TORTITA ARR C/CHO BICEN 210 G   |     1     |     1,7273 € |    10     |
      GASTOS DE ENVIO                 |     1     |     4,9587 € |    21     |
    END

    invoice = Invoices::Invoice.new(invoice_lines.split(/\n/).map do |l|
      parts = l.split(/\|/)
      values = [parts[0].strip] + parts[1..3].map { |x| x.tr(',', '.').to_d }
      Invoices::Line.new(Hash[[:article, :units, :price, :tax_rate].zip(values)])
    end)

    it 'should have 32 lines' do
      expect(invoice_lines.split(/\n/).count).to eq(32)
      expect(invoice.lines.count).to eq(32)
    end

    it 'The whole invoice: total amount without taxes 104,90 €, VAT 11,22 €, total amount 116,12 €' do
      expect(invoice.total.before_tax.round(2)).to eq('104.90'.to_d)
      expect(invoice.total.tax.round(2)).to eq('11.22'.to_d)
      expect(invoice.total.after_tax.round(2)).to eq('116.12'.to_d)
    end
  end



  context 'when prices could cause rounding issues' do
    invoice = Invoices::Invoice.new [
        Invoices::Line.new(article:'four',   units:'1', price:'12.3456', tax_rate:'10'),
        Invoices::Line.new(article:'five',   units:'1', price:'23.4567', tax_rate:'20'),
    ]

    it 'should get data for accounting right' do
      expect(invoice.sub_totals['10'.to_d].for_accounting.before_tax).to eq('12.35'.to_d)
      expect(invoice.sub_totals['20'.to_d].for_accounting.before_tax).to eq('23.46'.to_d)

      expect(invoice.total.for_accounting.before_tax).to eq('35.80'.to_d)  # instead of 35.81
    end
  end

end
