# Crun

command run is a simple command runner

### Usage

a file with the name of CRUN must be located in the dir you ran the command in

then run `crun command-name`

any args you supply after the command name will be given to the orignal command

```dart
flags = -release -O -std=C++20
files = main.cpp something_else.cpp "spaced filename.cpp"

print:
    // @args will be the runtime arguments
    echo crun args @args 

build:
    // the '?' operator will call a function if the process does not return 0

    gcc @flags @files ? $error => could not build project

    $print => build has been completed 

// will loop until the script has an error
py-script:

    $loop 

    python "some script.py" ? $end_loop 

    $print => script has completed

// default will be called if no command name is provided
default:

    $display_commands 


```

new lines are used for termination

and quotes are used for escaping and grouping symbols 

it treats emulates the command line envoiroment as well it can

## Functions 

* `print` prints the input 

* `error` will print the input and exit the command

* `loop` will make the command loop

* `end_loop` ends the loop

* `display_commands` will display existing commands

