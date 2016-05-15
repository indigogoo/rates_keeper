module Rates
  class DataImporter
    class DataImporterError < StandardError; end;

    def initialize(source=DataSources::EuropeanCentralBank.new)
      @datafetcher = DataFetcher.new(source)
      @filename = @datafetcher.filename
    end

    def import
      fetch_new_data

      logger :info, "Start importing new from #{@datafetcher.data_source.name}"
      parse_options = @datafetcher.data_source.class::PARSE_OPTIONS
      chunks = SmarterCSV.process(@filename, parse_options)

      logger :info, "Start concurrent processing csv processing"
      Parallel.map(chunks) do |chunk|
        ActiveRecord::Base.connection.reconnect!
        chunk.each do |params|
          rate = Rate.find_by(date: params[:date])
          unless rate.present?
            rate = Rate.new(params)
            logger.debug rate.errors.full_messages.join(', ') unless rate.save
          end
        end
      end
      logger :info, "Processing csv is finished"
      ActiveRecord::Base.connection.reconnect!
      
    rescue DataImporterError => e
      logger :debug, e.message
    rescue Exception => e
      logger :debug, e.message
      raise e
    end

    def logger(level, message)
      @logger ||= Logger.new(File.join(Rails.root, 'tmp', 'rates', "#{Rails.env}", 'importer.log'))
      @logger.send(level, "#{@datafetcher.data_source.name}: #{message}")
    end

    def self.import
      new.import
    end

    private

    def fetch_new_data
      unless @datafetcher.fetch
        raise DataImporterError, @datafetcher.errors.join(', ') 
      end
    end
  end
end