# UIAuto

UIAuto is a command line tool for running UI Automation scripts. It improves Apple's `instruments` command by assuming reasonable defaults specific to UI Automation.

UIAuto also facilitates the setup of simulator data for running scripts in a repeatable and known state.

## Prerequisites

* Xcode command line tools

## Installation

    $ gem install uiauto

## Usage

First, you need to build your app. By default, `uiauto` will look for the most recently built app bundle in derived data based on your current working directory. UIAuto also provides commands and can read speical comment headers to setup simulator data. More details below.

### Build your project

UIAuto does not build your app. You can use Xcode or `xcodebuild`.

#### With Xcode

The easiest way to build your app for UIAuto is to use Xcode. Open your app in Xcode then build your project (command+b). This builds your app and places the resulting bundle in derived data.

#### With xcodebuild

You can build from the command line using `xcodebuild`. The following examples show how to build your iOS 6.1 app for the simulator.

    # Example using xcodebuild to build a workspace
    $ xcodebuild -workspace MyApp.xcworkspace -scheme MyApp -sdk iphonesimulator6.1

    # Example using xcodebuild to build a project
    $ xcodebuild -project MyApp.xcodeproj -sdk iphonesimulator6.1

By building with the commands above, the resulting bundle is placed in derived data. Replace `iphonesimulator6.1` with `iphoneos6.1` if you want to build for the device.

### Run UI Automation scripts

The command to run automation scripts is simplified if the built app is in derived data and the defaults are used. For special use cases, these defaults may be overridden.

#### Default options

In the same directory as your project's .xcworkspace or .xcodeproj run the following.

    $ uiauto exec path_to_your_script.js

This will run `path_to_your_script.js` using the app bundle located in derivated data that you just built. The results and trace file are placed in `./uiauto/results` and `./uiauto/results/trace`.

#### Advanced options

Running `uiauto help exec` prints the following message.

    Usage:
      uiauto exec [FILE_OR_DIRECTORY]

    Options:
      [--results=RESULTS]      # Location where results should be saved. A directory named "Run ##" is created in here.
                               # Default: ./uiauto/results
      [--trace=TRACE]          # Location of trace file. Created if it doesn't exist.
                               # Default: ./uiauto/results/trace
      [--app=APP]              # Location of your application bundle. Defaults to your project's most recent build located in the standard location.
      [--device=DEVICE]        # Run scripts on a connected device. Specify a UDID to target a specific device.
      [--format=FORMAT]        # Formatter to use for output. Combine with --require to include a custom formatter. Built-in Formatters:
                               # ColorIndentFormatter: Adds readability to instruments output by filtering noise and adding color and indents.
                               # InstrumentsFormatter: Unmodified instruments output.
                               # Default: ColorIndentFormatter
      [--listeners=LISTENERS]  # Space separated list of class names used to listen to instruments output events. Combine with --require to include custom listeners.
      [--require=REQUIRE]      # Path to a ruby file. Used to require custom formatters or listeners.

##### `--app` option

If you build your app outside of derived data, then you can specify the `--app` flag to tell uiauto where to find the `*.app`. You can also override the default locations for the trace file and results. For example, if your build your app in a build directory you can run the following

    uiauto exec uiauto/scripts/script_to_run.js --app=build/MyApp.app

##### `--device` option

Pass the `--device` flag to run on the device.

    # Run on a connected device
    $ uiauto exec uiauto/scripts/script_to_run.js --device

    # Run on a connected device with a specific udid
    $ uiauto exec uiauto/scripts/script_to_run.js --device=UDID

##### Custom formatters and listeners

UIAuto supports custom formats and custom listeners. They can be made available with the `--require` option. The difference between a formatter and listener is that a formatter is a specific kind of listener that writes to `STDOUT`. There can only be one formatter active at a time. There may be more than one listener active at a time, and a listener must not write to `STDOUT`.

See [lib/uiauto/formatters/README.md](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/formatters/) for details on how to implement a custom formatter.

See [lib/uiauto/listeners/README.md](https://github.com/enriquez/uiauto/tree/master/lib/uiauto/listeners/) for details on how to implement a custom listener.

### Simulator data

UIAuto's `simulator` subcommand allows you to setup the simulator's applications, settings, and data. This is done by taking a "snapshot" of the simulator's current data by saving the `~/Library/Application Support/iPhone Simulator/(SDK VERSION)/` directory somewhere, then loading it back in when needed.

This is useful for getting the simulator into a known state before running automation scripts.

#### uiauto simulator command

Running `uiauto simulator` prints the following message

    Commands:
      uiauto simulator close           # Closes the simulator
      uiauto simulator help [COMMAND]  # Describe subcommands or one specific subcommand
      uiauto simulator load DATA       # Loads previously saved simulator data
      uiauto simulator open            # Opens the simulator
      uiauto simulator reset           # Deletes all applications and settings
      uiauto simulator save DATA       # Saves simulator data

#### Script comment headers

By placing a special comment header at the top of your script, `uiauto exec` will automatically load in a previously saved simulator data dump before running the script.

Let's say you have a TODO list application. You want to script the delete feature, but the problem is that you need tasks to delete first. With UIAuto, you can add a comment header that loads the simulator with your app with its tasks already there. Therefore, your script can safely make this assumption every time that it is ran.

The steps below explain how to do this.

##### 1. Manually add tasks to your app in the simulator

Get data into your app up to the point where you want your script to start. In this case, you want to add some tasks so that your script can delete them later.

##### 2. Save the simulator's current state

    $ uiauto simulator save uiauto/simulator_data/with_tasks

This command will save ALL of the data in the simulator including your application's data (and therefore, it'll save the tasks you just created). It is stored in the directory you specified.

##### 3. Add the comment header

Add the following to the top of `uiauto/scripts/delete_tasks.js`

    // setup_simulator_data "../simulator_data/with_tasks"

Inside the quotes is where you specify the location of the simulator data you want loaded in before running the script. It may be a path relative to the script.

##### 4. Run the script

Build if needed, then run:

    $ uiauto exec uiauto/scripts/delete_tasks.js

This will load in the simulator data that was saved in step 2 before running the script.

## License

MIT License. See LICENSE.txt
