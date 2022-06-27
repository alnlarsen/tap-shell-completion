#compdef tap

trace(){
  return
  local nicecounter=0
  local l
  for l in "${(@f)@}"
  do 
    echo "$nicecounter: $l" >> $HOME/tapcomp.log
    nicecounter=$((nicecounter + 1))
  done
}

_portable_get_real_dirname() {
  if [[ $(uname) == Darwin ]]; then
    # Mac uses BSD readlink which supports different flags

    # relativePath is empty if this is a regular file
    # Otherwise it is a relative path from the link to the real file
    path="$1"
    relativePath="$(readlink "$path")"
    # Keep looping until the file is resolved to a regular file
    while [[ "$relativePath" ]]; do
      # File is a link; follow it
      pushd "$(dirname "$path")" >/dev/null
      pushd "$(dirname "$relativePath")" >/dev/null
      path="$(pwd)/$(basename "$0")"
      popd >/dev/null
      popd >/dev/null
      relativePath="$(readlink "$path")"
    done

    echo "$(dirname "$path")"
  else
    # We are on linux -- Use GNU Readline normally
    echo "$(dirname "$(readlink -f "$(which "$1")")")"
  fi

}

_tap_subcommands(){
  trace "current = $CURRENT"
  local binary="$words[1]"
  local tapdir="`_portable_get_real_dirname "$binary"`"
  local scriptPath="$tapdir/Packages/ShellCompletion/completer.py"

  if ! test -f "$scriptPath"; then
    # plugin is not installed. fail quickly
    return
  fi

  trace "binary = $binary"
  trace "tapdir = $tapdir"

  local line
  local context
  trace "context = $contex"
  # hack to populate line
  _arguments '*::arg:->args'
  trace "line = $line"
  local -a array_of_lines
  array_of_lines=("${(@f)$(python "$scriptPath" "$tapdir" zsh $CURRENT $line)}")
  trace "${(@f)array_of_lines}"
  _describe 'command' array_of_lines 

}
_tap(){
  # always suggest files 
  _alternative "files:complete files:_files"
  _arguments '*:args:_tap_subcommands'
}

