#!/bin/bash
set -Eeuo pipefail

declare -A r_versions=(
    [3.4]='3.4.4'
    [3.5]='3.5.2'
)

declare -A os_identifiers=(
    [xenial]='ubuntu-1604'
    [bionic]='ubuntu-1804'
)

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

for version in "${!r_versions[@]}"; do
    for v in \
        "${!os_identifiers[@]}" \
    ; do
        dir="$version/$v"
        variant="$(basename "$v")"

        [ -d "$dir" ] || continue

        case "$variant" in
            xenial|bionic) template='ubuntu'
            ;;
        esac

        template="Dockerfile-${template}.template"

        { generated_warning; cat "$template"; } > "$dir/Dockerfile"

        sed -ri \
            -e "s/%%VARIANT%%/${variant}/" \
            -e "s/%%R_VERSION%%/${r_versions[$version]}/" \
            -e "s/%%OS_IDENTIFIER%%/${os_identifiers[$variant]}/" \
            "$dir/Dockerfile"
    done
done
