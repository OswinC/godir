# file: godir.sh
# godir completion

_godir_test_filenames()
{
	for f in "${COMPREPLY[@]}"; do
		if [ -n "`echo \"$f\" | grep /$`" ]; then
			return 1
		fi
	done 
	return 0
}

_godir()
{
	[ -z "$T" ] && return 0
	[ ! -f "$T/.filelist" ] && return 0

	local cur
	if [ "`type -t _get_comp_words_by_ref`" = "function" ]; then
		_get_comp_words_by_ref cur
	else
		cur=${COMP_WORDS[COMP_CWORD]}
	fi
	COMPREPLY=()
	# Escape dots by prefixing a backslash
	cur_esc=${cur/\./\\\.}
	#cur_esc="`echo \"$cur\" | sed 's/\\\\\?\./\\\./g'`"

	COMPREPLY=($(grep "/$cur_esc[^/]*/\?$" "$T/.filelist" | perl -pe "s,.*?/$cur_esc,$cur,"))

	_godir_test_filenames
	if [ $? -eq 0 ]; then
		# If a file name is completed, let the completion trail a space
		compopt -o filenames
	else
		compopt -o nospace
	fi

	return 0
}

complete -F _godir godir gofile
