module Rates
  module DataSources
    class EuropeanCentralBank < Base
      BASE_URI = URI('http://sdw.ecb.europa.eu/export.do')
      
      REQUEST_PARAMS = {
        type: '',
        trans: 'N',
        node: 2018794,
        CURRENCY: 'USD',
        FREQ: 'D',
        start: 'start',
        q: {
          'submitOptions.y': 6,
          'submitOptions.x': 51,
          'sfl1': 4,
          'end': '',
          'SERIES_KEY': '120.EXR.D.USD.EUR.SP00.A',
          'sfl3': 4,
          'DATASET': 0,
          'exportType': 'csv'
        }
      }

      PARSE_OPTIONS = {
        col_sep: ",",
        comment_regexp: /^(?!2\d{3}-\d{2}-\d{2},\d\W\d{4})/,
        headers_in_file: false,
        user_provided_headers: ['date', 'exchange_rate'],
        chunk_size: 500
      }

      def source_url
        uri = BASE_URI
        uri.query = URI.encode_www_form(@params)
        uri
      end

      def self.source_url
        new.source_url
      end
    end
  end
end