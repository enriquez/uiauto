# UIAuto Formatters

A formatter is a special type of listener that writes to `STDOUT`. To create a custom formatter, inherit from `UIAuto::Formatters::BaseFormatter` and place it in the `UIAuto::Formatters` namespace. Then override the methods important to your formatter.

Below is an example of a basic progress formatter.

    # progress_formatter.rb
    require 'uiauto/formatters/base_formatter'

    module UIAuto
      module Formatters
        class ProgressFormatter < BaseFormatter
          def log_debug(message)
            output.print "."
          end

          def log_fail(message)
            output.print "F"
          end
        end
      end
    end

This formatter can be used by requiring the script and setting the format.

    $ uiauto exec uiauto/scripts/script_to_run.js --require=./progress_formatter.rb --format=ProgressFormatter

See [lib/uiauto/listeners/base_listener.rb](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/listeners/base_listener.rb) for the available methods and their description.

See [lib/uiauto/formatters/](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/formatters/) for examples of built in formatters.
