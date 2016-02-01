#!/bin/bash

# globals and settings
version="1.0"

#############
## Helpers ##
#############

out () {
	echo "  $1"
}

elementIn () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}

printHelp () {
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

############
## Config ##
############

configFolder="${HOME}/.titanic"
configFile="${configFolder}/titanic.config"

# check folder/file exists
mkdir -p "${configFolder}"
touch "${configFile}"

# load default config
configKeys=("machineIdentity")
_machineIdentity="unknown"

# load config from file, overwriting some of the above
. ${configFile}

# write a config item to the file
writeConfig () { # 1: key; 2: value
	# check element name
	if elementIn "${1}" "${configKeys[@]}"
	then
		out "${1} is not a valid configuration key"
		exit 1
	fi

	# make a backup of the config file
	mv "${configFile}" "${configFile}.bak"

	# remove the old key and re-write it
	cat "${configFile}.bak" | grep -v "^_${1}=" > "${configFile}"
	echo "_${1}=${2}" >> "${configFile}"
	exit 0
}

# show all config details
printConfig () { # 1: key
	out "machineIdentity  =  ${_machineIdentity}"
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
				writeConfig "machineIdentity" "$1"
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
			out ${_machineIdentity}
			exit 0
			;;

		# normal use

		-s|--sync)
			_sync
			;;

		# misc

		--help)
			printHelp
			;;

		*)
			out "Unrecognised option: $1"
			out "Run './titanic.sh --help' to see usage"
			exit 0
			;;
	esac
done