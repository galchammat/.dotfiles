npm_prefix=$(npm prefix --global)
npm_root=$(npm root --global)
install_v2=(npm install --global --include=optional --allow-scripts=@opencode/cli)

legacy_paths=()
for package in opencode-ai @opencode-ai/cli; do
  if [[ -f "$npm_root/$package/package.json" ]]; then
    legacy_paths+=("$npm_root/$package")
  fi
done

if (( ! ${#legacy_paths[@]} )); then
  "${install_v2[@]}" @opencode/cli@2
  opencode --version | grep -E '^(opencode )?v?2\.'
  exit
fi

# The old stable and preview packages can own opencode and opencode2 respectively.
for name in opencode opencode2; do
  link="$npm_prefix/bin/$name"
  if [[ -e "$link" || -L "$link" ]]; then
    case "${link:A}" in
      "${npm_root:A}"/opencode-ai/* | "${npm_root:A}"/@opencode-ai/cli/* | "${npm_root:A}"/@opencode/cli/*)
        legacy_paths+=("$link")
        ;;
      *)
        print -u2 "Leaving $link in place: it is not owned by an OpenCode npm package."
        exit 1
        ;;
    esac
  fi
done

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
    for legacy_path in "${legacy_paths[@]}"; do
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

# Move the old packages and shims aside together. npm uninstall would delete the
# shared shims, so only discard these backups once the replacement runs from PATH.
for legacy_path in "${legacy_paths[@]}"; do
  mv -- "$legacy_path" "$stage/backup/"
done
npm_config_offline=true "${install_v2[@]}" "@opencode/cli@${staged_version#v}"
opencode --version | grep -E '^(opencode )?v?2\.'
