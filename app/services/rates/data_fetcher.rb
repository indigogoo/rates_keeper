module Rates
  class DataFetcher
    attr_reader :errors, :filename, :data_source

    DIR = File.join(Rails.root, 'tmp', 'rates', "#{Rails.env}")

    def initialize(data_source)
      @data_source = data_source
      @data_source_uri = @data_source.source_url
      @filename = File.join(DIR, "#{@data_source.name.underscore}_rates.csv")
      @errors = []
    end

    def fetch
      create_parent_dirs(@filename)
      Net::HTTP.start(@data_source_uri.host) do |http|
        request = Net::HTTP::Get.new @data_source_uri
        http.request request do |response|
          case response
          when Net::HTTPSuccess then
            open @filename, 'w' do |io|
              response.read_body do |chunk|
                io.write chunk
              end
            end
          else
            @errors << "#{response}: An error has occured while uploading new rates data #{Time.now}"
          end
        end
      end
      @errors.blank?
    end

    private

    def create_parent_dirs(file_path)
      dir_path = File.dirname(file_path)
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    end
  end
end