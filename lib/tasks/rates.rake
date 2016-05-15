namespace :rates do
  desc 'Import rates from csv'
  task import: [:environment] do
    Rates::DataImporter.import
  end

  desc 'Convert usd to eur for specific date'
  task :convert, [:amount, :date] => [:environment] do |task, args|
    puts args.inspect
    puts ExchangeRateConverter.convert(args[:amount], args[:date])
  end
end
