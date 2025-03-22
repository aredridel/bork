action="$1"
dir="$2"
shift 2

owner="$(arguments get owner "$@")"
group="$(arguments get group "$@")"
mode="$(arguments get mode "$@")"

target_platform="$(get_baking_platform)"

case "$action" in
  desc)
    printf '%s\n' \
      'asserts presence of a directory' \
      '* directory path [options]' \
      '--owner=user-name' \
      '--group=group-name' \
      '--mode=mode' \
      '> directory ~/.ssh --mode=700'
    ;;

  status)
    bake [ -e "${dir}" ] || return "$STATUS_MISSING"
    bake [ -d "${dir}" ] || {
      echo "target exists as non-directory"
      return "$STATUS_CONFLICT_CLOBBER"
    }

    mismatch=false
    if [[ -n "${owner}" || -n "${group}" || -n "${mode}" ]]; then
      bake $(permission_cmd_dir "$target_platform") "${dir}" | read cur_owner cur_group cur_mode
      

      if [[ -n "${owner}" && "${cur_owner}" != "${owner}" ]]; then
        printf '%s owner: %s\n' \
          'expected' "${owner}" \
          'received' "${cur_owner}"
        mismatch=true
      fi

      if [[ -n "${group}" && "${cur_group}" != "${group}" ]]; then
        printf '%s group: %s\n' \
          'expected' "${group}" \
          'received' "${cur_group}"
        mismatch=true
      fi

      if [[ -n "${mode}" && "${cur_mode}" != "${mode}" ]]; then
        printf '%s mode: %s\n' \
          'expected' "${mode}" \
          'received' "${cur_mode}"
        mismatch=true
      fi
    fi

    if ${mismatch}; then
      return "${STATUS_MISMATCH_UPGRADE}"
    fi

    return "${STATUS_OK}"
    ;;

  install|upgrade)
    if baking_platform_is "Darwin"; then
      inst_cmd=( install -d )
    else
      inst_cmd=( install -C -d )
    fi
    [[ -z ${owner} && -z ${group} ]] || inst_cmd=( sudo "${inst_cmd[@]}" )
    [[ -z ${owner} ]] || inst_cmd+=( -o "${owner}" )
    [[ -z ${group} ]] || inst_cmd+=( -g "${group}" )
    [[ -z ${mode} ]] || inst_cmd+=( -m "${mode}" )
    bake "${inst_cmd[@]}" "${dir}"
    ;;

  remove)
    bake "rm -r ${dir}"
    ;;

  *) return 1 ;;
esac
