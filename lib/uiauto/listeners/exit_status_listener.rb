require 'uiauto/listeners/base_listener'

module UIAuto
  module Listeners
    class ExitStatusListener < BaseListener

      def initialize
        @result = 0
      end

      def log_fail(message)
        @result = 1 unless @result == 2
      end

      def log_error(message)
        @result = 2
      end

      def result
        @result
      end

    end
  end
end
