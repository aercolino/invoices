require "invoices/version"
require 'bigdecimal'
require 'bigdecimal/util'

module Invoices

  class Invoice

    attr_reader :lines, :sub_totals, :total

    def initialize(lines)
      @lines = lines
      @sub_totals = totals_by_tax_rate
      @total = grand_total
    end


    private

    def totals_by_tax_rate
      result = {}
      lines.group_by(&:tax_rate).each do |tax_rate, lines|
        result[tax_rate] = TotalByTaxRate.new(
          before_tax: lines.sum(&:before_tax),
          tax_rate: tax_rate,
          num_lines: lines.count
        )
      end
      result
    end


    def grand_total
      before_tax = 0
      tax = 0
      num_lines = 0
      @sub_totals.each do |_, sub_total|
        before_tax += sub_total.before_tax
        tax += sub_total.tax
        num_lines += sub_total.num_lines
      end
      Total.new(before_tax: before_tax, tax: tax, num_lines: num_lines)
    end

  end



  class Line

    attr_reader :article, :units, :price, :tax_rate, :before_tax

    def initialize(article:, units:, price:, tax_rate:)
      @article = article
      @units = BigDecimal(units)
      @price = BigDecimal(price)
      @tax_rate = BigDecimal(tax_rate)

      @before_tax = @units * @price
    end

  end



  class Total

    attr_reader :before_tax, :tax, :after_tax, :num_lines

    def initialize(before_tax:, tax:, num_lines:)
      @before_tax = before_tax
      @tax = tax
      @num_lines = num_lines

      @after_tax = before_tax + tax
    end

    def for_accounting
      Total.new(before_tax: before_tax.round(2), tax: tax.round(2), num_lines: num_lines)
    end

  end



  class TotalByTaxRate < Total

    attr_reader :tax_rate

    def initialize(before_tax:, tax_rate:, num_lines:)
      @tax_rate = tax_rate
      tax = before_tax * tax_rate / 100

      super(before_tax: before_tax, tax: tax, num_lines: num_lines)
    end

  end


end
