bake () {
	str="$(for arg in "$@"; do printf "%q " "$arg"; done)"
	eval "$str";
}
