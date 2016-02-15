#!/bin/bash

# globals and settings
version="0.1"

############
## Config ##
############

configFolder="${HOME}/.titanic"
configFile="${configFolder}/titanic.config"
scriptsFile="${configFolder}/titanic-scripts"

# check folder/file exists
mkdir -p "${configFolder}"
touch "${configFile}"
touch "${scriptsFile}"

# load default config
configKeys=("serverPath" "machineIdentity" "hookFile" "hostsFile")
_serverPath="unknown"
_machineIdentity="unknown"
_hookFile="${HOME}/.bashrc"
_hostsFile="/etc/hosts"

# load config from file, overwriting some of the above
. ${configFile}

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
	out "  --init                      Set up the initial files and this machine's identity"
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

# check init
checkInit () {
	if [ ! -e "${_hookFile}" ] || ! grep -Fxq "# START TITANIC" "${_hookFile}";
	then
		out "ERROR: Titanic has not been initialised"
		exit 1
	fi
}

#################
## More Config ##
#################

init () {
	# check whether an init file exists
	if [ -e "${_hookFile}" ] && grep -Fxq "# START TITANIC" "${_hookFile}";
	then
		out "WARNING: init has already been done"
		exit 1
	fi

	# intro
	out "Welcome to Titanic v${version}"
	out "Please answer the following questions to complete setup:"
	out ""

	# get the server path
	read -p "  Titanic server path: " tmpInput
	writeConfig "serverPath" "${tmpInput}"

	# get the machine identity
	read -p "  Machine identity: " tmpInput
	writeConfig "machineIdentity" "${tmpInput}"

	# get the hook file
	read -p "  Hook file: (${_hookFile}) " tmpInput
	if [ -z "${tmpInput}" ];
	then
		tmpInput="${_hookFile}"
	fi
	writeConfig "hookFile" "${tmpInput}"

	# get the hosts file
	read -p "  Hosts file: (${_hostsFile}) " tmpInput
	if [ -z "${tmpInput}" ];
	then
		tmpInput="${_hostsFile}"
	fi
	writeConfig "hostsFile" "${tmpInput}"

	# set up hook files
	printf "\n\n# START TITANIC\n. ${scriptsFile}\n# END TITANIC\n" >> "${_hookFile}"
	. "${scriptsFile}"

	# done
	out "Done!"
	exit 0
}

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

	# reload the config
	. "${configFile}"
}

# show all config details
printConfig () { # 1: key (optional)
	checkInit

	if [ $# -eq 0 ]
	then
		# print entire config
		out "serverPath       =  ${_serverPath}"
		out "machineIdentity  =  ${_machineIdentity}"
		out "hookFile         =  ${_hookFile}"
		out "hostsFile        =  ${_hostsFile}"
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
}

##########
## Sync ##
##########

sync () {
	checkInit

	# TODO: download aliases
	out "NOTE: This version of Titanic does not support aliases yet"

	# download shortcuts
	out "Downloading Bash shortcuts..."
	shortcuts=$(wget -qO- "${_serverPath}/api/bash-shortcuts?format=bash&for_device_name=${_machineIdentity}" | tr -d '\r')
	if [ "${shortcuts}" == "ERROR" ]
	then
		out "ERROR: Could not download Bash shortcuts"
	fi

	# download functions
	out "Downloading Bash functions..."
	functions=$(wget -qO- "${_serverPath}/api/bash-functions?format=bash&for_device_name=${_machineIdentity}" | tr -d '\r')
	if [ "${functions}" == "ERROR" ]
	then
		out "ERROR: Could not download Bash shortcuts"
	fi

	# write to file
	echo "${shortcuts}" > "${scriptsFile}"
	echo "${functions}" >> "${scriptsFile}"

	out "Done! Please re-start your shell, or run this command:"
	out ""
	out "  source \"${_hookFile}\""
	out ""
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

		init)
			init
			exit 0
		;;

		set-config)
			shift
			if [ $# -gt 1 ]
			then
				writeConfig "${1}" "${2}"
				exit 0
			else
				out "You must specify a key and a parameter"
				exit 1
			fi
			;;

		show-config)
			shift
			if [ $# -eq 1 ]
			then
				printConfig "${1}"
				exit 0
			else
				printConfig
				exit 0
			fi
			;;

		# normal use

		s|sync)
			sync
			exit 0
			;;

		# misc

		-?|help)
			printHelp
			exit 0
			;;

		*)
			out "Unrecognised option: $1"
			out "Run './titanic.sh --help' to see usage"
			exit 0
			;;
	esac
done