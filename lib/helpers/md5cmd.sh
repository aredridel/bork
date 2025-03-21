md5cmd () {
  case $1 in
    Darwin|FreeBSD)
      [ -z "$2" ] && echo "md5" || echo "md5 -q $(printf '%q' "$2")"
      ;;
    Linux)
      echo "md5sum $(printf '%q' "$2") | cut -d ' ' -f 1"
      ;;
    *) return 1 ;;
  esac
}

