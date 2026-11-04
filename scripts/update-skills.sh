#!/usr/bin/env bash

# Script to update skills used in the repository from upstream releases.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default configurations
DEFAULT_SKILLS=("caveman" "grill-me" "tdd" "codebase-design" "grilling")
DEST_DIR="${UPDATE_DEST_DIR:-"$REPO_ROOT/.agents/skills"}"

# 1. Repositories (owner/repo format)
# Add new repositories here.
REPO_mattpocock="mattpocock/skills"
REPO_JuliusBrussee="JuliusBrussee/caveman"

# 2. Skill mappings to repositories and paths inside them.
# To add a new skill, define REPO_<skill>, SUBDIR_<skill>, and optionally REF_<skill> here.
# Note: hyphens in skill names are replaced with underscores in variable names.

# caveman
REPO_caveman="JuliusBrussee"
SUBDIR_caveman="skills/caveman"
REF_caveman="latest"

# grill-me
REPO_grill_me="mattpocock"
SUBDIR_grill_me="skills/productivity/grill-me"
REF_grill_me="latest"

# grilling
REPO_grilling="mattpocock"
SUBDIR_grilling="skills/productivity/grilling"
REF_grilling="latest"

# tdd
REPO_tdd="mattpocock"
SUBDIR_tdd="skills/engineering/tdd"
REF_tdd="latest"

# codebase-design
REPO_codebase_design="mattpocock"
SUBDIR_codebase_design="skills/engineering/codebase-design"
REF_codebase_design="latest"

# Helper to fetch latest GitHub release tag (handles redirect parsing)
get_latest_github_tag() {
  local owner="$1"
  local repo="$2"
  local tag=""
  
  if command -v curl >/dev/null 2>&1; then
    tag=$(curl -sI "https://github.com/$owner/$repo/releases/latest" | grep -Fi "location:" | awk -F'/' '{print $NF}' | tr -d '\r\n')
  elif command -v wget >/dev/null 2>&1; then
    tag=$(wget --max-redirect=0 "https://github.com/$owner/$repo/releases/latest" 2>&1 | grep -Fi "location:" | awk -F'/' '{print $NF}' | tr -d '\r\n')
  fi
  
  # Fallback to scrape the release page directly if API/redirect was blocked
  if [[ -z "$tag" ]]; then
    if command -v curl >/dev/null 2>&1; then
      tag=$(curl -s "https://github.com/$owner/$repo/releases" | grep -oE '/releases/tag/[^"]+' | head -n 1 | awk -F'/' '{print $NF}' | tr -d '\r\n')
    fi
  fi
  
  # Default fallback if tag detection fails
  if [[ -z "$tag" ]]; then
    tag="main"
  fi
  
  echo "$tag"
}

# Determine which skills to update
SKILLS_TO_UPDATE=("${@:-"${DEFAULT_SKILLS[@]}"}")

# Setup temporary workspace
TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

echo "Updating skills: ${SKILLS_TO_UPDATE[*]}"
echo "Destination: $DEST_DIR"

for skill in "${SKILLS_TO_UPDATE[@]}"; do
  # Normalize skill name to variable-friendly format (replace '-' with '_')
  var_name=$(echo "$skill" | tr '-' '_')
  # Uppercase format for environment overrides
  env_name=$(echo "$var_name" | tr '[:lower:]' '[:upper:]')
  
  repo_key_var="REPO_$var_name"
  repo_key="${!repo_key_var:-}"
  
  if [[ -z "$repo_key" ]]; then
    echo "Error: Skill '$skill' is not configured." >&2
    exit 1
  fi
  
  repo_name_var="REPO_$repo_key"
  repo_val="${!repo_name_var}"
  
  subdir_var="SUBDIR_$var_name"
  subdir="${!subdir_var}"
  
  ref_var="REF_$var_name"
  ref="${!ref_var:-latest}"
  
  # Generate cache key for repository and ref to group requests
  cache_key=$(echo "${repo_val}_${ref}" | tr -cd '[:alnum:]_')
  cache_var="CACHE_$cache_key"
  extracted_dir="${!cache_var:-}"
  
  if [[ -z "$extracted_dir" ]]; then
    extracted_dir="$TMP_DIR/$cache_key"
    mkdir -p "$extracted_dir"
    
    # Check for test/env override for URL
    override_var="UPDATE_URL_$env_name"
    if [[ -n "${!override_var:-}" ]]; then
      url="${!override_var}"
    else
      owner=$(echo "$repo_val" | cut -d'/' -f1)
      repo_name=$(echo "$repo_val" | cut -d'/' -f2)
      
      if [[ "$ref" == "latest" ]]; then
        echo "Resolving latest tag for $repo_val..."
        resolved_tag=$(get_latest_github_tag "$owner" "$repo_name")
        echo "Resolved: $resolved_tag"
        url="https://github.com/$owner/$repo_name/archive/refs/tags/$resolved_tag.tar.gz"
      else
        url="https://github.com/$owner/$repo_name/archive/refs/tags/$ref.tar.gz"
      fi
    fi
    
    tar_file="$TMP_DIR/${cache_key}.tar.gz"
    
    if [[ -f "$url" ]]; then
      # Local file copy for offline/tests
      cp "$url" "$tar_file"
    else
      echo "Downloading $url..."
      if command -v curl >/dev/null 2>&1; then
        curl -sSL "$url" -o "$tar_file"
      elif command -v wget >/dev/null 2>&1; then
        wget -qO "$tar_file" "$url"
      else
        echo "Error: curl or wget required" >&2
        exit 1
      fi
    fi
    
    tar -xzf "$tar_file" -C "$extracted_dir"
    
    # Store path in cache
    eval "$cache_var=\"\$extracted_dir\""
  else
    echo "Using cached archive for $repo_val ($ref)"
  fi
  
  # Extract archive root name (e.g. skills-1.0.1) dynamically
  archive_root=$(ls -1 "$extracted_dir" | head -n 1)
  src_path="$extracted_dir/$archive_root/$subdir"
  dest_path="$DEST_DIR/$skill"
  
  if [[ ! -d "$src_path" ]]; then
    echo "Error: Path '$subdir' not found under '$archive_root' in $repo_val archive" >&2
    exit 1
  fi
  
  echo "Replacing skill '$skill' at '$dest_path'..."
  rm -rf "$dest_path"
  mkdir -p "$dest_path"
  cp -R "$src_path"/. "$dest_path"/

  # Omit proprietary, non-skill, and hidden metadata files
  find "$dest_path" -mindepth 1 -name ".*" -exec rm -rf {} + 2>/dev/null || true
  find "$dest_path" -iname "*claude*" -exec rm -rf {} + 2>/dev/null || true
  find "$dest_path" \( -name "copilot-instructions.md" -o -name "package-lock.json" -o -name "yarn.lock" -o -name "pnpm-lock.yaml" \) -exec rm -rf {} + 2>/dev/null || true
done

echo "Skills update complete!"
