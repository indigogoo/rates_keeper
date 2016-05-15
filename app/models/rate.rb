class Rate < ActiveRecord::Base
  validates :exchange_rate, :date, presence: true

  scope :with_exchanged_rates, -> { where.not(exchange_rate: nil) }
  scope :before_date, -> (date) { where('date <= ?', date).order(:date) }
end
