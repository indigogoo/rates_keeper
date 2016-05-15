class ExchangeRateConverter
  class RateConverterError < StandardError; end;

  attr_accessor :converted_amount, :errors

  def initialize(amount, date)
    @amount = amount
    @date = Date.parse(date)
    @rate = get_rate
    @errors = []
  end

  def convert
    @converted_amount = @amount.to_f * @rate.exchange_rate
  end

  def self.convert(amount, date)
    new(amount, date).convert
  end

  private

  def get_rate
    rate = Rate.with_exchanged_rates.before_date(@date).last
    raise RateConverterError, 'There are no rates for given date yet'  if rate.blank?
    rate
  end
end
