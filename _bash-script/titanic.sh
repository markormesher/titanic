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
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

printHelp () {
	out "Titanic v$version"
	out ""
	out "Usage: titanic [action]"
	out ""
	out "Configuration:"
	out "  --set-config {key} {value}  Set a given configuration option"
	out "  --show-config {key}         Show a specific value from the current local configuration"
	out "  --show-config               Show the entire current local configuration"
	out ""
	out "Normal Use:"
	out "  -s --sync                   Synchronise settings on this machine"
	out ""
	out "Misc:"
	out "  -? --help                   Show this help text"
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
	if ! elementIn "${1}" "${configKeys[@]}"
	then
		out "ERROR: ${1} is not a valid configuration key"
		exit 1
	fi

	# make a backup of the config file
	mv "${configFile}" "${configFile}.bak"

	# remove the old key and re-write it
	cat "${configFile}.bak" | grep -v "^_${1}=" > "${configFile}"
	echo "_${1}=${2}" >> "${configFile}"

	# finish
	exit 0
}

# show all config details
printConfig () { # 1: key (optional)
	if [ $# -eq 0 ]
	then
		# print entire config
		out "machineIdentity  =  ${_machineIdentity}"
	else
		# check the key given is valid
		if ! elementIn "${1}" "${configKeys[@]}"
		then
			out "ERROR: '${1}' is not a valid configuration key"
			exit 1
		fi

		# print specific config item
		key="_${1}"
		out "${!key}"
	fi

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
	out "Run 'titanic --help' to see usage"
	exit 0
fi

# loop through flags
while test $# -gt 0; do
	case "$1" in

		# configuration

		--set-config)
			shift
			if [ $# -gt 1 ]
			then
				writeConfig "${1}" "${2}"
			else
				out "You must specify a key and a parameter"
				exit 1
			fi
			;;

		--show-config)
			shift
			if [ $# -eq 1 ]
			then
				printConfig "${1}"
			else
				printConfig
			fi
			;;

		# normal use

		-s|--sync)
			_sync
			;;

		# misc

		-?|--help)
			printHelp
			;;

		*)
			out "Unrecognised option: $1"
			out "Run './titanic.sh --help' to see usage"
			exit 0
			;;
	esac
done