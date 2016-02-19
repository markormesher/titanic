# Titanic Bash Script

This Bash script lies at the heart of Titanic, allowing the aliases, shortcuts and functions created through the web interface to by synchronised to a machine.

## Installation

1. Copy the `.sh` file to a location on your machine; I keep mine in `~/.titanic/titanic.sh`, but it could be anywhere.

2. Make sure it is executable, with `chmod +x {path to file}`.

3. Run it with the command `./{path to file}`, as you would for any other Bash executable.

4. Optional: you could create an alias for the script, either through Titanic itself or manually with `alias titanic='./{path to file}'`.

**Note:** in the future, there should be a more automatic way to install the script.

## Usage

**Note:** all instructions here assume that an alias has been set up, allowing the script to be run with the command `titanic`.

### Initialisation

The script must first be ran with `titanic init` to set up the necessary files and folders, and to collect some initial details.

### Synchronising

Run the script with `titanic sync` to synchronise content from the web interface to your machine.

### Settings

The commands `titanic set-config` and `titanic show-config` can be used to alter settings any time after `titanic init` has been run.

Run `titanic help` for full details on how these two options work.

### Help

Run `titanic help` for an explanation of all actions and arguments.
