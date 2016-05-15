require 'rails_helper'

describe 'ExchangeRateConverter' do
  let(:date) { 10.days.ago }
  let!(:rate) { create(:rate, date: date) }

  it 'should correctly convert between currencies for date' do
    expect(ExchangeRateConverter.convert(120, date.to_s)).to be(180.0)
  end

  it 'should find the last date that has exchange rate if there is no rate for given date' do
    expect(ExchangeRateConverter.convert(120, Date.today.to_s)).to be(180.0)
  end
end
