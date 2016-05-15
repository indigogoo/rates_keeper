module Rates
  module DataSources
    class Base
      attr_reader :name

      def initialize(params=self.class::REQUEST_PARAMS)
        @params = params
        @name = self.class.name.split('::').last
      end
    end
  end
end