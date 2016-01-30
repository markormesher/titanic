#!/bin/bash

# globals and settings
version="1.0"

############
## Config ##
############

configFolder="${HOME}/.titanic"
configFile="${configFolder}/titanic.config"

# check folder/file exists
mkdir -p $configFolder
touch $configFile

# load default config
_machineIdentity="unknown"

# load config from file, overwriting some of the above
. $configFile

# write a config item to the file
writeConfig () { # 1: key; 2: value
	# TODO: actually write to the file
	out "Set $1 as $2"
	exit 0
}

# show all config details
printConfig () { # 1: key
	out "machineIdentity  =  ${_machineIdentity}"
}

#############
## Helpers ##
#############

out () {
	echo "  $1"
}

_help () {
	out "Titanic v$version"
	out ""
	out "Usage: ./titanic.sh [action]"
	out ""
	out "Configuration:"
	out "  --set-config key=value   Set a given configuration option"
	out "  --set-id new-id          Set the identity of this machine (see also: --show-id)"
	out "  --show-config            Show the current local configuration"
	out "  --show-id                Show the identity of this machine (see also: --set-id)"
	out ""
	out "Normal Use:"
	out "  -s --sync                Synchronise settings on this machine"
	out ""
	out "Misc:"
	out "  --help                    Show this help text"
	exit 0
}

##########
## Sync ##
##########

_sync () {
	# todo
	out "Sync"
	exit 0
}

#######################
## Main Control Flow ##
#######################

# no arguments?
if [ $# -eq 0 ]
then
	out "Titanic v$version"
	out "Run './titanic.sh --help' to see usage"
	exit 0
fi

# loop through flags
while test $# -gt 0; do
	case "$1" in

		# configuration

		--set-config)
			shift
			if [ $# -gt 0 ]
			then
				IFS="=" read -r key value <<< "$1"
				writeConfig "${key}" "${value}"
			else
				out "No parameter specified"
				exit 1
			fi
			;;

		--set-id)
			shift
			if [ $# -gt 0 ]
			then
				writeConfig "_machineIdentity" "$1"
			else
				out "No identity specified"
				exit 1
			fi
			;;

		--show-config)
			printConfig
			exit 0
			;;

		--show-id)
			out $_machineIdentity
			exit 0
			;;

		# normal use

		-s|--sync)
			_sync
			;;

		# misc

		--help)
			_help
			;;

		*)
			out "Unrecognised option: $1"
			out "Run './titanic.sh --help' to see usage"
			exit 0
			;;
	esac
done
