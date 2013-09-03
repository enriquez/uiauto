require 'uiauto/formatters/base_formatter'

module UIAuto
  module Formatters
    class InstrumentsFormatter < BaseFormatter
      def instruments_line(line)
        output.puts line
      end
    end
  end
end
