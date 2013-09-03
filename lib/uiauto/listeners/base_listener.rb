module UIAuto
  module Listeners
    class BaseListener
      # Before a run is started. A run contains one or more scripts.
      def run_start
      end

      # Before a script is started.
      def script_start(script)
      end

      # Called if a script contains a comment header to load simulator data.
      def load_simulator_data(path)
      end

      # Message printed by UI Automation's logStart.
      def log_start(message)
      end

      # Message printed by UI Automation's logPass.
      def log_pass(message)
      end

      # Message printed by UI Automation's logFail.
      def log_fail(message)
      end

      # Message printed by UI Automation's logIssue.
      def log_issue(message)
      end

      # Message printed by UI Automation's logDebug. Also prints actions such as tap, typeString, etc...
      def log_debug(message)
      end

      # Message printed by UI Automation's logError.
      def log_error(message)
      end

      # Message printed by UI Automation's logMessage.
      def log_default(message)
      end

      # Message printed by UI Automation's logWarning.
      def log_warning(message)
      end

      # An uncategorized log type. Typically uncaught javascript errors.
      def log_none(message)
      end

      # Typically reports a script was stopped by user, but is caused by a failed import
      def log_stopped(message)
      end

      # UI Automation's logElementTree was called. element_tree contains the entire tree.
      def element_tree(element_tree)
      end

      # Before an element tree starts.
      def element_tree_start
      end

      # A line from an element tree.
      def element_tree_line(line)
      end

      # After an element tree is finished.
      def element_tree_finish
      end

      # After a script is finished. Duration and trace location as reported by instruments.
      def script_summary(duration, trace_location)
      end

      # After a script is finished.
      def script_finish(script)
      end

      # Misc lines from instruments that are not called in above methods.
      def unknown(line)
      end

      # Raw instruments output.
      def instruments_line(line)
      end

      # After a run finished.
      def run_finish
      end
    end
  end
end
