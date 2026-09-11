#!/usr/bin/env bash
# Install K-Dense-AI/scientific-agent-skills into this project's agent skills directory.
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
archive_path="$repo_root/scientific-agent-skills-main.zip"
target_root="$repo_root/.agents/skills"
source_url="https://github.com/K-Dense-AI/scientific-agent-skills/archive/refs/heads/main.zip"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--target DIRECTORY] [--archive FILE] [--refresh]

Installs every directory containing a SKILL.md from K-Dense-AI/scientific-agent-skills
into this project's agent skills directory. By default this is $target_root.

Options:
  --target DIRECTORY  Destination skills directory (use a persistent project path in Codex Web).
  --archive FILE      Use a local repository archive instead of downloading it.
  --refresh           Replace an existing K-Dense skill with the same relative path.
  -h, --help          Show this help text.
USAGE
}

refresh=false
while (($#)); do
  case "$1" in
    --target) target_root=${2:?"--target requires a directory"}; shift 2 ;;
    --archive) archive_path=${2:?"--archive requires a file"}; shift 2 ;;
    --refresh) refresh=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

is_zip() { unzip -tqq "$1" >/dev/null 2>&1; }

work_dir=$(mktemp -d)
cleanup() { rm -rf "$work_dir"; }
trap cleanup EXIT

if is_zip "$archive_path"; then
  input_archive=$archive_path
else
  input_archive="$work_dir/scientific-agent-skills.zip"
  printf 'Downloading K-Dense scientific-agent-skills…\n'
  curl --fail --location --retry 3 --output "$input_archive" "$source_url"
  if ! is_zip "$input_archive"; then
    printf 'Downloaded file is not a valid ZIP archive: %s\n' "$input_archive" >&2
    exit 1
  fi
fi

unzip -q "$input_archive" -d "$work_dir/unpacked"
source_root=$(find "$work_dir/unpacked" -mindepth 1 -maxdepth 1 -type d -print -quit)
if [[ -z "$source_root" ]]; then
  printf 'The scientific-agent-skills archive did not contain a repository directory.\n' >&2
  exit 1
fi

mapfile -d '' skill_files < <(find "$source_root" -type f -name SKILL.md -print0)
if ((${#skill_files[@]} == 0)); then
  printf 'No SKILL.md files were found in the scientific-agent-skills archive.\n' >&2
  exit 1
fi

mkdir -p "$target_root"
installed=0
skipped=0
for skill_file in "${skill_files[@]}"; do
  skill_dir=$(dirname "$skill_file")
  relative_path=${skill_dir#"$source_root"/}
  destination="$target_root/$relative_path"

  if [[ -e "$destination" ]]; then
    if ! $refresh; then
      printf 'Skipping existing skill: %s\n' "$relative_path"
      ((skipped += 1))
      continue
    fi
    rm -rf "$destination"
  fi

  mkdir -p "$(dirname "$destination")"
  cp -a "$skill_dir" "$destination"
  ((installed += 1))
done

printf 'Installed %d K-Dense scientific skill(s) in %s' "$installed" "$target_root"
if ((skipped)); then
  printf ' (%d existing skill(s) left unchanged)' "$skipped"
fi
printf '. Restart Codex or begin a new session to load the skills.\n'
