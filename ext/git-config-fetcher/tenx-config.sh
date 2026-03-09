#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# default values
dest_root="/data"
dest_config="config"
dest_symbols="data/shared/symbols"
default_host="github.com"

config_repo=""
config_branch=""
symbols_repo=""
symbols_branch=""
symbols_path=""

print_usage() {
	echo "Usage: $0 [options]"
	echo "Options:"
	echo "  --config-repo <repository>   Pipeline config repo. Accepts:"
	echo "                                 - owner/repo (defaults to github.com)"
	echo "                                 - host/owner/repo"
	echo "                                 - https://host/owner/repo.git"
	echo "                               Token can be provided via GIT_TOKEN env var or embedded in URL (https://user:token@host/...)"
	echo "  --config-branch <branch>     Config branch name to checkout. If omitted, will use default repo branch."
	echo "  --symbols-repo <repository>  Compiled symbols repo. Same formats as --config-repo."
	echo "                               Token can be provided via GIT_TOKEN env var or embedded in URL (https://user:token@host/...)"
	echo "  --symbols-branch <branch>    Symbols branch name to checkout. If omitted, will use default repo branch."
	echo "  --symbols-path <path>        Absolute path in the symbols repo where symbols reside. If omitted, entire repo is used"
	echo "  -h, --help                   Show this help message."
	echo ""
	echo "Environment Variables:"
	echo "  GIT_TOKEN                    Git access token. Will be automatically injected into repository URLs if not already present."
}

# Normalize a repo string into a full https URL.
#
# Supports:
#   owner/repo                      -> https://github.com/owner/repo.git
#   host.com/owner/repo             -> https://host.com/owner/repo.git
#   https://host.com/owner/repo     -> https://host.com/owner/repo.git
#   https://host.com/owner/repo.git -> https://host.com/owner/repo.git
#
normalize_repo_url() {
	local repo=$1

	# Already a full URL
	if echo "$repo" | grep -q '^https\?://'; then
		# Append .git if missing
		if ! echo "$repo" | grep -q '\.git$'; then
			repo="${repo}.git"
		fi
		echo "$repo"
		return
	fi

	# Count slashes to distinguish owner/repo from host/owner/repo
	local slash_count
	slash_count=$(echo "$repo" | tr -cd '/' | wc -c | tr -d ' ')

	if [ "$slash_count" -eq 1 ]; then
		# owner/repo -> default host
		repo="https://${default_host}/${repo}.git"
	elif [ "$slash_count" -ge 2 ]; then
		# host/owner/repo (or deeper paths)
		if ! echo "$repo" | grep -q '\.git$'; then
			repo="https://${repo}.git"
		else
			repo="https://${repo}"
		fi
	else
		echo "Error: invalid repo format '$repo'. Expected owner/repo, host/owner/repo, or full URL."
		exit 1
	fi

	echo "$repo"
}

# Parse arguments
while [ $# -gt 0 ]; do
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

if [ -z "$config_repo" ] && [ -z "$symbols_repo" ]; then
	echo "At least one of --config-repo / --symbols-repo must be specified"
	print_usage
	exit 1
fi

echo "===== Git Config Fetcher v__VERSION__ ====="
echo "Starting repository fetch operation..."

if [ -n "$config_repo" ]; then
	config_repo=$(normalize_repo_url "$config_repo")
	echo "Config repository: $config_repo"
	if [ -n "$config_branch" ]; then
		echo "  Branch: $config_branch"
	else
		echo "  Branch: (default)"
	fi
fi

if [ -n "$symbols_repo" ]; then
	symbols_repo=$(normalize_repo_url "$symbols_repo")
	echo "Symbols repository: $symbols_repo"
	if [ -n "$symbols_branch" ]; then
		echo "  Branch: $symbols_branch"
	else
		echo "  Branch: (default)"
	fi
	if [ -n "$symbols_path" ]; then
		echo "  Path: $symbols_path"
	fi
fi
echo ""

git_clone() {
	local repo=$1
	local branch=$2
	local dest=$3

	# If GIT_TOKEN is set and URL doesn't already have credentials embedded
	# (i.e., no user:pass@ or token@ in the URL), inject git:TOKEN into the URL
	if [ -n "$GIT_TOKEN" ]; then
		# Check if URL already has credentials (contains @ before the host)
		if ! echo "$repo" | grep -q 'https://[^/]*@'; then
			repo=$(echo "$repo" | sed "s|https://|https://git:${GIT_TOKEN}@|")
		fi
	fi

	if [ -z "$branch" ]; then
		git clone --depth 1 --single-branch "$repo" "$dest" || { echo "Error cloning into $dest"; exit 1; }
	else
		git clone --depth 1 --single-branch --branch "$branch" "$repo" "$dest" || { echo "Error cloning into $dest (branch: $branch)"; exit 1; }
	fi
}

if [ -n "$config_repo" ]; then
	config_clone_path="$dest_root/$dest_config"

	echo "Cloning config repository..."
	echo "  Destination: $config_clone_path"

	mkdir -p "$config_clone_path" || { echo "Error creating directory $config_clone_path"; exit 1; }

	git_clone "$config_repo" "$config_branch" "$config_clone_path"

	echo "Config repository cloned successfully"
	echo ""
fi

if [ -n "$symbols_repo" ]; then
	symbols_clone_path="$dest_root/$dest_config/$dest_symbols"

	echo "Cloning symbols repository..."
	echo "  Destination: $symbols_clone_path"

	mkdir -p "$symbols_clone_path" || { echo "Error creating directory $symbols_clone_path"; exit 1; }

	if [ -z "$symbols_path" ]; then
		git_clone "$symbols_repo" "$symbols_branch" "$symbols_clone_path"
		echo "Symbols repository cloned successfully"
	else
		tmp_symbols="/tmp/tenx-symbols"
		echo "  Extracting from subfolder: $symbols_path"

		git_clone "$symbols_repo" "$symbols_branch" "$tmp_symbols"

		symbols_subfolder="$tmp_symbols/$symbols_path"

		if [ -d "$symbols_subfolder" ] && [ -n "$(ls -A "$symbols_subfolder")" ]; then
			echo "  Moving symbols from subfolder to destination..."
			mv "$symbols_subfolder"/* "$symbols_clone_path" || { echo "Error moving symbols from $symbols_subfolder to $symbols_clone_path"; exit 1; }
			echo "Symbols extracted and moved successfully"
		else
			echo "Warning - symbols subfolder $symbols_subfolder doesn't exist or is empty"
		fi

		rm -rf "$tmp_symbols"
	fi
	echo ""
fi

echo "===== Fetch operation completed successfully ====="
