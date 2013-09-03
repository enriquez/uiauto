require 'uiauto/listeners/base_listener'

module UIAuto
  module Formatters
    class BaseFormatter < Listeners::BaseListener
      def output
        STDOUT
      end
    end
  end
end
