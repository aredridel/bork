md5fn() {
  case "$target_platform" in
    Darwin|FreeBSD)
      [ -z "$1" ] && md5 || md5 -q "$1"
      ;;
    Linux)
      ([ -z "$1" ] && md5sum || md5sum "$1") | awk '{print $1}'
      ;;
    *) return 1 ;;
  esac
}

