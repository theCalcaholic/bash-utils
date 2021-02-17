# bash args

*Producing quality scripts with ease.*

## Description

bash-args is a small library which does the heavy-lifting for all (if not: [create a feature request :P][gh-issues]) your argument parsing needs for your bash scripts.
Written originally for my own [bash-utils][bash-utils-repo].

## How do I use it?

Source the library, then define keyword and required arguments and call the `parse_args` function.

```bash
# Define a description which will be used in the --help message
DESCRIPTION="A dummy function to showcase the bash-args library"
# Define a usage message which will be used in the --help message and during argument parsing errors
USAGE="my_example_func [OPTIONS] username

  username
    Your username
  
  Options
    --config file        Read configuration from a file
    -i, --interactive    Ask before doing anything dangerous
    -s, --sleep duration Sleep <duration> seconds before doing anything"

# Define the keywords to use for (optional keyword arguments
KEYWORDS=("--config" "--interactive;bool" "-i;bool" "--sleep;int" "-s;int")
# Define required positional arguments
REQUIRED=("username")
# Source the library
. ./parse_args.sh
# Parse all arguments in "$@"
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

# Show the usage message on specific exit codes
set_trap 1 2

# Retrieve the arguments

echo "Your arguments:"
echo "username: ${NAMED_ARGS['username']}"
echo "config: ${KW_ARGS['--config']}"
echo "interactive: ${KW_ARGS['--interactive']-${KW_ARGS['-i']}}"

# Set a default value for the sleep argument
sleep="${KW_ARGS['--sleep']-${KW_ARGS['-s']}}"
sleep="${sleep-0}"
echo "sleep: $sleep"
echo "any other args you provided: ${ARGS[@]}"
```

### What does this get me?

Let's say, you saved the example above as `example.sh` (don't forget adding a shebang and making it executable). Now, you'd get the following behavior:

1. If you to call your script with `--help`, you get your usage instructions:

  ```sh
  $ ./example.sh --help
  A dummy function to showcase the bash-args library

  USAGE:
    my_example_func [OPTIONS] username

    username
      Your username

    Options
      --config file        Read configuration from a file
      -i, --interactive    Ask before doing anything dangerous
      -s, --sleep duration Sleep <duration> seconds before doing anything
  ```

2. If you call it without the required positional argument `username`, you get an error:

  ```sh
  $ ./example.sh 
  ERROR: The following required arguments are missing: username
  USAGE:
    my_example_func [OPTIONS] username

    username
      Your username

    Options
      --config file        Read configuration from a file
      -i, --interactive    Ask before doing anything dangerous
      -s, --sleep duration Sleep <duration> seconds before doing anything
  ```

3. If you call it with an invalid (non-int) argument for `-s` or `--sleep`, you get an error:

  ```sh
  $ ./example.sh thecalcaholic -s notanumber
  ERROR: Expected a number but got 'notanumber'!

  USAGE:
    my_example_func [OPTIONS] username

    username
      Your username

    Options
      --config file        Read configuration from a file
      -i, --interactive    Ask before doing anything dangerous
      -s, --sleep duration Sleep <duration> seconds before doing anything
  ```

4. If you call it with proper arguments, it does what it's supposed to:

  ```sh
  $ ./example.sh thecalcaholic -s 5 extra --config /home/thecalcaholic/example_config.json -i
  Your arguments:
  username: thecalcaholic
  config: /home/thecalcaholic/example_config.json
  interactive: true
  sleep: 5
  any other args you provided: extra
  ```

[gh-issues]: https://github.com/theCalcaholic/bash-args/issues
[bash-utils-repo]: https://github.com/theCalcaholic/bash-utils
