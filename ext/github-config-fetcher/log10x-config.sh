#!/bin/sh

# default values
dest_root="/data"
dest_config="config"
dest_symbols="data/shared/symbols"

config_repo=""
config_branch=""
symbols_repo=""
symbols_branch=""
symbols_path=""

print_usage() {
	echo "Usage: $0 [options]"
	echo "Options:"
	echo "  --config-repo <repository>   Pipeline config repo. Use full url, including access token if needed (i.e. https://<TOKEN>@github.com/owner/my-config-repo.git)"
	echo "  --config-branch <branch>     Config branch name to checkout. If omitted, will use default repo branch."
	echo "  --symbols-repo <repository>  Compiled symbols repo. Use full url, including access token if needed (i.e. https://<TOKEN>@github.com/owner/my-symbols-repo.git)"
	echo "  --symbols-branch <branch>    Symbols branch name to checkout. If omitted, will use default repo branch."
	echo "  --symbols-path <path>        Absolute path in the symbols repo where symbols reside. If omitted, entire repo is used"
	echo "  -h, --help                   Show this help message."
}

# Parse arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		--config-repo)
			config_repo="$2"
			shift
			;;
		--config-branch)
			config_branch="$2"
			shift
			;;
		--symbols-repo)
			symbols_repo="$2"
			shift
			;;
		--symbols-branch)
			symbols_branch="$2"
			shift
			;;
		--symbols-path)
			symbols_path="$2"
			shift
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		*)
			echo "Unknown argument $key"
			print_usage
			exit 1
			;;
	esac

	if ! shift; then
		echo "Missing value for $key"
		exit 1
	fi
done

if [[ -z "$config_repo" ]]; then
	if [[ -z "$symbols_repo" ]]; then
		echo "At least one of --config-repo / --symbols-repo must be specified"
		print_usage
		exit 1
	fi
fi

git_clone() {
	local repo=$1
	local branch=$2
	local dest=$3

	if [[ -z "$branch" ]]; then
		git clone --single-branch "$repo" "$dest"
	else
		git clone --single-branch --branch "$branch" "$repo" "$dest"
	fi
}

if [[ -n "$config_repo" ]]; then
	config_clone_path="$dest_root/$dest_config"
	mkdir -p "$config_clone_path"

	git_clone "$config_repo" "$config_branch" "$config_clone_path"
fi

if [[ -n "$symbols_repo" ]]; then
	symbols_clone_path="$dest_root/$dest_config/$dest_symbols"

	mkdir -p "$symbols_clone_path"

	if [[ -z "$symbols_path" ]]; then
		git_clone "$symbols_repo" "$symbols_branch" "$symbols_clone_path"
	else
		tmp_symbols="/tmp/log10x-symbols"

		git_clone "$symbols_repo" "$symbols_branch" "$tmp_symbols"

		symbols_subfolder="$tmp_symbols/$symbols_path"

		if [[ -d "$symbols_subfolder" && -n "$(ls -A "$symbols_subfolder")" ]]; then
			mv "$symbols_subfolder"/* "$symbols_clone_path"
		else
			echo "Warn - symbols subfolder $symbols_folder doesn't exist, or is empty"
		fi

		rm -rf "$tmp_symbols"
	fi
fi
