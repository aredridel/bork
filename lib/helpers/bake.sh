bake () {
	str="$(for arg in "$@"; do printf "%q " "$arg"; done)"
	eval "$str";
}
bake_noquote () {
	eval "$@";
}
