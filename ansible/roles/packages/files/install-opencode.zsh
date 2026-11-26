npm_prefix=$(npm prefix --global)
npm_root=$(npm root --global)
install_v2=(npm install --global --include=optional --allow-scripts=@opencode/cli)

# Serialize migrations that use the same npm prefix.
mkdir -p -- "$npm_prefix"
zmodload zsh/system
touch -- "$npm_prefix/.opencode-install.lock"
zsystem flock -t 60 "$npm_prefix/.opencode-install.lock"

legacy_packages=()
for package in opencode-ai @opencode-ai/cli; do
  if [[ -f "$npm_root/$package/package.json" ]]; then
    legacy_packages+=("$npm_root/$package")
  fi
done

# The old stable and preview packages can own opencode and opencode2 respectively.
legacy_links=()
for name in opencode opencode2; do
  link="$npm_prefix/bin/$name"
  if [[ -e "$link" || -L "$link" ]]; then
    target="$link"
    if [[ -L "$link" ]]; then
      # Resolve the original target even if an interrupted install left it dangling.
      target=$(readlink "$link")
      [[ "$target" == /* ]] || target="${link:h}/$target"
    fi
    case "${target:A}" in
      "${npm_root:A}"/opencode-ai/* | "${npm_root:A}"/@opencode-ai/cli/* | "${npm_root:A}"/@opencode/cli/*)
        legacy_links+=("$link")
        ;;
      *)
        print -u2 "Leaving $link in place: it is not owned by an OpenCode npm package."
        exit 1
        ;;
    esac
  fi
done

if (( ! ${#legacy_packages[@]} && ! ${#legacy_links[@]} )); then
  "${install_v2[@]}" @opencode/cli@2
  opencode --version | grep -E '^(opencode )?v?2\.'
  exit
fi

# Cache and verify the replacement before changing the current installation.
stage=$(mktemp -d "$npm_prefix/.opencode-v2.XXXXXX")
trap 'rm -rf -- "$stage"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
"${install_v2[@]}" --prefix "$stage" @opencode/cli@2
staged_version=$("$stage/bin/opencode" --version | grep -E '^(opencode )?v?2\.')
staged_version=${staged_version##* }
mkdir -- "$stage/backup"

finish_migration() {
  local result=$? legacy_path saved
  if (( result != 0 )); then
    for legacy_path in "${legacy_packages[@]}" "${legacy_links[@]}"; do
      saved="$stage/backup/${legacy_path:t}"
      if [[ -e "$saved" || -L "$saved" ]]; then
        if ! mv -f -- "$saved" "$legacy_path"; then
          print -u2 "OpenCode rollback needs attention; backup retained at $stage/backup."
          return "$result"
        fi
      fi
    done
  fi
  rm -rf -- "$stage"
  return "$result"
}
trap finish_migration EXIT

# Move shims first so even a hard stop cannot strand links to moved packages.
# Keep both until the replacement runs from PATH.
for legacy_path in "${legacy_links[@]}" "${legacy_packages[@]}"; do
  mv -- "$legacy_path" "$stage/backup/"
done
npm_config_offline=true "${install_v2[@]}" "@opencode/cli@${staged_version#v}"
opencode --version | grep -E '^(opencode )?v?2\.'
