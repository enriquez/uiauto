# UIAuto Listeners

Listeners receive events from instruments. Listeners may be used for anything other than writing to `STDOUT`. Use a formatter if you plan on writing to `STDOUT`. To create a custom listener, inherit from `UIAuto::Formatters::BaseListener` and place it in the `UIAuto::Listeners` namespace. Then override the methods important to your listener.

A custom listener can be used by requiring the script and setting the listener.

    $ uiauto exec uiauto/scripts/script_to_run.js --require=./custom_listener.rb --listeners=CustomListener

More than one listener may be used, but you can only require one file. That file must implement multiple listeners or require other files.

    $ uiauto exec uiauto/scripts/script_to_run.js --require=./listeners.rb --listeners=CustomListener1 CustomListener2

See [lib/uiauto/listeners/base_listener.rb](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/listeners/base_listener.rb) for the available methods and their description.

See [lib/uiauto/listeners/](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/listeners/) for examples of built in listeners.
