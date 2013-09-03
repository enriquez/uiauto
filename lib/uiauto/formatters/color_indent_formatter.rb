require 'uiauto/formatters/base_formatter'
require 'rainbow'

module UIAuto
  module Formatters
    class ColorIndentFormatter < BaseFormatter
      def initialize
        @passes   = []
        @failures = []
        @current_script = ''
      end

      def script_start(script)
        output.puts
        output.puts "Script: #{script}"
        @current_script = script
      end

      def load_simulator_data(path)
        output.puts
        output.puts "  Simulator Data: #{path}"
      end

      def log_start(message)
        output.puts
        output.puts "  Test: \"#{message}\""
      end

      def log_pass(message)
        output.puts "    Test: \"#{message}\" Passed".foreground(:green)
        @passes << message
      end

      def log_fail(message)
        output.puts "    Test: \"#{message}\" Failed".foreground(:red)
        @failures << "#{@current_script} \"#{message}\""
      end

      def log_issue(message)
        output.puts "    Test: \"#{message}\" Issue".foreground(:yellow)
      end

      def log_debug(message)
        if output.tty?
          colored_message = message.foreground(:cyan)
          colored_message = colored_message.gsub(/"((?:[^"\\]|\\.)*)"/) do
            # hack to ensure ansi start/end codes for cyan are matched between bright cyan
            "\e[0m#{"\"#{$1}\"".bright.foreground(:cyan)}\e[36m"
          end

          message = colored_message
        end
        output.puts "    #{message}"
      end

      def log_error(message)
        output.puts "    Error: #{message}".foreground(:red)
      end

      def log_default(message)
        output.puts message
      end

      def log_warning(message)
        output.puts "    Warning: #{message}".foreground(:yellow)
      end

      def log_none(message)
        output.puts "    #{message}".foreground(:red)
        @failures << @current_script unless @failures.include?(@current_script)
      end

      def log_stopped(message)
        output.puts "    #{message}".foreground(:red)
        @failures << @current_script unless @failures.include?(@current_script)
      end

      def element_tree_start
        output.puts "    Element Tree:".color("333333")
      end

      def element_tree_line(line)
        output.puts "    #{line}".color("333333")
      end

      def run_finish
        if @failures.count > 0
          output.puts
          output.puts "Failing Tests:".foreground(:red)
          @failures.each do |failure|
            output.puts failure.foreground(:red)
          end
        end

        output.puts
        output.puts "#{@passes.count + @failures.count} tests #{summary}"
      end

      protected

      def summary
        failures = ''
        passes   = ''

        if @failures.count > 0
          failures = "#{@failures.count} failed".foreground(:red)
        end

        if @passes.count > 0
          passes = "#{@passes.count} passed".foreground(:green)
        end

        if failures.length > 0 && passes.length > 0
          "(#{failures}, #{passes})"
        elsif failures.length > 0
          "(#{failures})"
        elsif passes.length > 0
          "(#{passes})"
        end
      end
    end
  end
end
