module UIAuto
  class Reporter
    def initialize
      @listeners = []
      @element_tree = ""
    end

    def add_listener(listener)
      @listeners << listener
    end

    def formatter=(formatter)
      add_listener(formatter)
    end

    def parse_instruments_output(output)
      lines = output.split("\n")
      lines.each do |line|
        notify_listeners(:instruments_line, line)
        case line
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4} (\w+): (.*)$/
          log_type = $1
          message  = $2

          notify_listeners("log_#{log_type.downcase}".to_sym, message)
        when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4} logElementTree:$/
          @element_tree = ""
          notify_listeners(:element_tree_start)
        when /^UIATarget .+$/
          @element_tree << line + "\n"
          notify_listeners(:element_tree_line, line)
        when /^elements: {$/
          @element_tree << line + "\n"
          notify_listeners(:element_tree_line, line)
        when /^\t+.+$/
          @element_tree << line + "\n"
          notify_listeners(:element_tree_line, line)
        when /^}$/
          @element_tree << line

          notify_listeners(:element_tree, @element_tree)
          notify_listeners(:element_tree_line, line)
          notify_listeners(:element_tree_finish)
        when /^Instruments Trace Complete \(Duration : (.+); Output : (.+)$/
          duration       = $1
          trace_location = $2

          notify_listeners(:script_summary, duration, trace_location)
        else
          notify_listeners(:unknown, line)
        end
      end
    end

    def run_start
      notify_listeners(:run_start)
    end

    def run_finish
      notify_listeners(:run_finish)
    end

    def script_start(script)
      notify_listeners(:script_start, script)
    end

    def script_finish(script)
      notify_listeners(:script_finish, script)
    end

    def load_simulator_data(data)
      notify_listeners(:load_simulator_data, data)
    end

    protected

    def notify_listeners(event, *args)
      @listeners.each do |listener|
        listener.send(event, *args)
      end
    end
  end
end
