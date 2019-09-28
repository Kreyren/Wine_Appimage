#!/usr/bin/env bash

# shellcheck disable=SC2034
my_name="Wine_appimage"

# KREYPI init
kreypi() {
	# Sanitycheck for fetch
	if ! command -v 'wget' >/dev/null && [ ! -e "/lib/bash/kreypi.bash" ]; then printf "FATAL: This script requires 'wget' to be executable for downloading of kreypi (https://github.com/RXT067/Scripts/tree/kreyren/kreypi) for further sourcing\n" ; exit 1 ; fi

	# Sanitycheck for /lib/bash
	# shellcheck disable=SC2154
	[ ! -e "/lib/bash" ] && { mkdir -p "/lib/bash" || printf "ERROR: Unable to make a new directory in /lib/bash\n" ; exit 1 ;} || { [ -n "$debug" ] && printf "DEBUG: Directory in '/lib/bash' already exists\n" ;}

	# Fetch
	[ ! -e "/lib/bash/kreypi.bash" ] && (wget 'https://raw.githubusercontent.com/RXT067/Scripts/kreyren/kreypi/kreypi.bash' -O '/lib/bash/kreypi.bash') || ([ -n "$debug" ] && printf "DEBUG: File '/lib/bash/kreypi.bash' already exists\n")

	# Source
	if [ -e "/lib/bash/kreypi.bash" ]; then
		source "/lib/bash/kreypi.bash" || { printf "FATAL: Unable to source '/lib/bash/kreypi.bash'\n" ; exit 1 ;}
	  [ -n "$debug" ] && printf "DEBUG: Kreypi in '/lib/bash/kreypi.bash' has been successfully sourced\n"
	elif [ ! -e "/lib/bash/kreypi.bash" ]; then
		printf "FATAL: Unable to source '/lib/bash/kreypi.bash' since path doesn't exists\n"
	fi
}; kreypi

# Attempt to provide shell compatibility
shellcompat 'yes'

action() {
	# Get wine source
	# TODO: Use pro
	target="/home/kreyren/appimage_test"
	[ ! -e "$target" ] && { mkdir "$target" || die 1 "Unable to make '$target'" ;} || debug "Directory '$target' already exists"

	# TODO: Determine source name
	# TODO: check Compound Commands in man
	[ ! -e "$target/build" ] && { mkdir "$target/build" || die 1 "mkdir failed to make a new directory in '$target/build'" ; } || debug "Directory '$target/build' already exists"

	[ ! -e "$HOME/.cache/$my_name/" ] && { mkdir "$HOME/.cache/$my_name/" || die 1 "Unable to make a new directory in '$HOME/.cache/$my_name/'" ;} || debug "Created a new directory in '$HOME/.cache/$my_name/'"

	[ ! -e "$HOME/.cache/$my_name/wine-4.17.tar.xz" ] && (wget 'https://dl.winehq.org/wine/source/4.x/wine-4.17.tar.xz' -O "$HOME/.cache/$my_name/wine-4.17.tar.xz" || die 1 "wget failed to fetch 'https://dl.winehq.org/wine/source/4.x/wine-4.17.tar.xz' in '$target/build/wine-4.17.tar.xz'") || debug 'wine tarball source already exists'

	[ ! -e "$target/build/wine-4.17" ] && { mkdir "$target/build/wine-4.17" || die 1 "failed to make a new directory in '$target/build/wine-4.17" ;} || debug "Directory '$target/build/wine-4.17' already exists"

	[ ! -e "$target/build/wine-4.17/LICENSE" ] && tar -xf "$HOME/.cache/$my_name/wine-4.17.tar.xz" -C "$target/build/"

	# Get appimagetool
	[ ! -e "$HOME/.cache/$my_name/appimagetool-x86_64.AppImage" ] && wget 'https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage' -O "$target/build/appimagetool-x86_64.AppImage"
	[ ! -e "$target/build/appimagetool-x86_64.AppImage" ] && [ -e "$HOME/.cache/$my_name/appimagetool-x86_64.AppImage" ] && cp "$HOME/.cache/$my_name/appimagetool-x86_64.AppImage" "$target/build/"
	[ ! -x "$target/build/appimagetool.AppImage" ] && chmod +x "$target/build/appimagetool-x86_64.AppImage"

	die ping
}

case "$1" in
	test)
		rm -r "$target/build/" ; su 'kreyren' -c "env debug='god' $target/deployscript/kreyrenized.bash"
	;;
	"") #TODO: Capture valid path
		action
	;;
	*) die wtf 'Grabbing arguments'
esac
