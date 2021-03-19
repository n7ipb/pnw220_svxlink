# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

#
# Useful aliases
#
# display UPS status
alias picostat='/usr/local/bin/pico_status_hv3.0.py'
#

# ChangeBack - Return to previous directory
# Usage: cb
alias cb='cd $OLDPWD'

#List only directory names
# Usage: lsd
alias lsd='ls -d */'

# Short alias for 'pushd'.  pushd places the current directory on a directory
# stack and lets you return thru the sequence using 'popd'
# Usage: p <directorypath>
alias p='pushd $*'

# The following aliases (save & show) are for saving frequently used directory locations
# You can save a directory using an abbreviation of your choosing. Eg. save here
# You can subsequently move to one of the saved directories by using cd with
# the abbreviation you chose. Eg. cd here  (Note that no '$' is necessary.)

# setup the environment with the last list of names
alias sdirs='source ~/.dirs' 

# Show the list of saved directories
# Usage: show
alias show='cat ~/.dirs'

# Save location with name
# Usage: save <name>
save () { sed "/$@/d" ~/.dirs > ~/.dirs1; \mv ~/.dirs1 ~/.dirs; echo "$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ; }
# To use the saved name type cd <savedname>

# Support for show/save not normally used directly
# Initialization for the above 'save' facility:
# source the .sdirs file:
if [ -f $HOME/.dirs ]; then
        source ~/.dirs
else
        touch ~/.dirs
fi
# set the bash option so that no '$' is required when using the above facility
shopt -s cdable_vars
# end Support

#
# Find functions
#

# Find File,  searches from your current directory on down for the named file.
# Case sensitive
# Usage: ff <filename>
ff () { find . -name "$@" ; }

# Find File String, find a file whose name starts with a given string
# Case sensitive
# Usage: ffs <string>
ffs () { find . -name "$@"'*' ; }

# Find File Ending, find a file whose name ends with a given string
# Case sensitive
# Usage: ffe <string>
ffe () { find . -name '*'"$@" ; }

# Find File Containing: grep through files found by find, e.g. grepf pattern '*.c'
# Case sensitive, requires single quotes around the regexp
# Usage: ffc <pattern> 'regexp'
# Example:  ffc foobar '*.c'   - Finds all files ending in .c containing foobar
ffc () { find . -type f -name "$2" -print0 | xargs -0 grep "$1" ; }

# Find File From; search for a given file in a different path
# Usage: fff <path> 'regexp'
# Example: fff /usr nice
fff () { find "$1" -name "$2" ; }
#
# Display an ascii tree listing of directory structure
# Usage: tree <path>
tree () { ls -R "$1" | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//–/g' -e 's/^/ /' -e 's/-/|/' ;}

# Check for Juha's git prompting
# This adds the git branch name to your prompt when you're in a git managed source tree
if [ -f $HOME/.bash_git ]; then
        . $HOME/.bash_git
fi
