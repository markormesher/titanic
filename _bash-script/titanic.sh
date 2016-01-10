#!/bin/bash

# globals and settings
version="1.0"

#############
## Helpers ##
#############

out () {
	echo "  $1"
}

#####################
## Inner Functions ##
#####################

# config

_config () {
	# todo
	out "Show config"
	exit 0
}

_id () {
	# todo
	out "Show ID"
	exit 0
}

_set () { # 1: key; 2: value
	# todo
	out "Set $1 as $2"
	exit 0
}

_set-id () { # 1: new ID
	# todo
	out "Set ID to $1"
	exit 0
}

# normal use

_sync () {
	# todo
	out "Sync"
	exit 0
}

# misc

_help () {
	out "Titanic v$version"
	out ""
	out "Usage: ./titanic.sh [action]"
	out ""
	out "Configuration:"
	out "  --config          Show the current local configuration"
	out "  --id              Show the identity of this machine (see also: --set-id)"
	out "  --set key=value   Set a given configuration option"
	out "  --set-id new-id   Show the identity of this machine (see also: --id)"
	out ""
	out "Normal Use:"
	out "  -s --sync         Synchronise settings on this machine"
	out ""
	out "Misc:"
	out "  --help            Show this help text"
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

		--config)
			_config
			;;

		--id)
			_id
			;;

		--set)
			shift
			if [ $# -gt 0 ]
			then
				IFS="=" read -r key value <<< "$1"
				_set "${key}" "${value}"
			else
				out "No parameter specified"
				exit 1
			fi
			;;

		--set-id)
			shift
			if [ $# -gt 0 ]
			then
				_set-id "$1"
			else
				out "No identity specified"
				exit 1
			fi
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