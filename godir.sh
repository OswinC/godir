function godir ()
{
	if [[ -z "$T" ]]; then
		echo "Please source a devel file"
		return
	fi
	if [[ -z "$1" ]]; then
		echo "Usage: godir <regex> [e]"
		echo "       e: edit one/all matched file"
		return
	fi
	if [[ ! -f $T/.filelist ]]; then
		echo -n "Creating index..."
		(\cd $T; find . -wholename ./release -prune -o -wholename ./.svn -prune -o -wholename *.git -prune -o -type f -print -o -type d -printf "%p/\n" > .filelist)
		echo " Done"
		echo ""
	fi
	local lines
	[[ "$2" != "e" ]] && lines=($(\grep "$1" $T/.filelist | sed -e 's/\/[^/]*$//' | sort | uniq)) || lines=($(\grep -F "$1" $T/.filelist | sort | uniq))
	if [[ ${#lines[@]} = 0 ]]; then
		echo "Not found"
		return
	fi
	local pathname
	local choice
	if [[ ${#lines[@]} > 1 ]]; then
		while [[ -z "$pathname" ]]; do
			local index=1
			local line
			local pathnames
			for line in ${lines[@]}; do
				printf "%6s %s\n" "[$index]" $line
				index=$(($index + 1))
				pathnames="${pathnames} $line"
			done
			echo
			[[ "$2" != "e" ]] && echo -n "Select one: " || echo -n "Select one ([a] -> all): "
			unset choice
			read choice
			if [[ "$2" = "e" && $choice = "a" ]]; then
				pathname=${pathnames}
			elif [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
				echo "Invalid choice"
				continue
			else
				pathname=${lines[$(($choice-1))]}
			fi
		done
	else
		pathname=${lines[0]}
	fi

	[[ "$2" != "e" ]] && \cd $T/$pathname || (cd $T; $EDITOR -p $pathname)
}

function gofile () { godir "$1" e; }

