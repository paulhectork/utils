#!/env/bin/bash

# USAGE: bash filename_formatter.sh /path/to/directory [-c|-p|-r|-h]

#   ABOUT: formfilename is a script to change filenames in a folder, 
#   using a regular-expression search and replace system. files are 
#   either moved (the file with the old name is deleted) or copied 
#   (the file with the old name is kept).
#   
#   BY DEFAULT, the files are moved in the same folder and the white 
#   spaces ('\s') are replaced with underscores ('_').
#   
#   ABOUT REGULAR EXPRESSIONS: string permutations are done using
#   'sed -r ...'. the regexes must be written using bash's extended
#   regular expressions (ERE) syntax ('[0-9]' must be used instead of 
#   '\d', '[a-zA-Z]' instead of '\w'). subgroups can be captured and
#   reused in the replacement string with: '\index-of-the-subgroup'
#   ('\0' is the whole captured string, '\1' the first subgroup...). 
#   slashes ('\') must be escaped with a backslash ('\/'). 
#   for more information, see:
#   - https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html
#   - https://www.gnu.org/software/sed/manual/sed.html#sed-regular-expressions

#   argument  : the path to the folder to process
#   -h        : show help and exit
#   -c        : copy files instead of renaming them
#   -o PATH   : the output directory where to move/copy the renamed files
#   -p STRING : the pattern to replace (defaults to ' ')
#   -r STRING : the replacement pattern (with which to replace) 
#               with which to perform the replacements (defaults 
#               to '_')


# *********************** functions *********************** #
# help
usage() {

    cat<<EOF

USAGE: bash filename_formatter.sh PATH/TO/DIR [-c|-p|-r|-h]

  ABOUT: formfilename is a script to change filenames in a folder, 
  using a regular-expression search and replace system. files are 
  either moved (the file with the old name is deleted) or copied 
  (the file with the old name is kept).
  
  BY DEFAULT, the files are moved in the same folder and the white 
  spaces ('\s') are replaced with underscores ('_').
  
  ABOUT REGULAR EXPRESSIONS: string permutations are done using
  'sed -r ...'. the regexes must be written using bash's extended
  regular expressions (ERE) syntax ('[0-9]' must be used instead of 
  '\d', '[a-zA-Z]' instead of '\w'). subgroups can be captured and
  reused in the replacement string with: '\index-of-the-subgroup'
  ('\0' is the whole captured string, '\1' the first subgroup...). 
  slashes ('\') must be escaped with a backslash ('\/'). 
  for more information, see:
  - https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html
  - https://www.gnu.org/software/sed/manual/sed.html#sed-regular-expressions

  argument  : the path to the folder to process
  -h        : show help and exit
  -c        : copy files instead of renaming them
  -o PATH   : the output directory where to move/copy the renamed files
  -p STRING : the pattern to replace (defaults to ' ')
  -r STRING : the replacement pattern (with which to replace) 
              with which to perform the replacements (defaults 
              to '_')

EOF
}

# check if a path is valid
check_path() {
    # $1: the directory to process
    # $2: boolean flag argument to exit if the directory doesn't exist
    if [ "$1" = "" ] && [ "$2" -eq 1 ]; then
        usage
        echo "ERROR : please provide the directory to process as an argument. exiting...";
        exit;
    elif [ ! -d "$1" ]; then
        usage
        echo "ERROR : directory '$1' doesn't exist. exiting...";
        exit;
    fi;
}

# to avoid code redundancy. move or copy $1 to $1
mover() {
    # $1: the file to process
    # $2: the output directory
    # $3: a flag boolean indicating if the file should be moved/copied
    if [ "$3" -eq 1 ]; then
        #echo "copy" "$1" "$2" "$3";
        cp "$1" "$2";
    else
        #echo "move" "$1" "$2" "$3";
        mv "$1" "$2";
    fi;
}


# *********************** parse the arguments *********************** #
unset OPTARG  # undefine OPTARG wich could be used as an ENV variable

# define defaults
cwd=$(pwd | sed -e "s/\/*\s*$//g");  # remove trailing slashes
copy=0;
src="\s";
rpl="_";
outdir="."

# shift moves the script's option by -1 so the options aren't scrambled 
indir="$1" && shift;

# getopts is used in a while loop; it takes a string argument
# which is a list of allowed options: 'abc' means that the
# only allowed options are 'a', 'b' and 'c'. 
# - if an option is prefixed with ':', the error messages will
#   ignored for that option ('ab:c')
# - if an option should be used with a user-inputted value,
#   this option must be followed by ':' ('abc:')
# - '$OPTARG' defines an option's argument
while getopts "hcp:r:o:" option; do
    # get each option, assign them to `$option` and process them
    # the double semi-colon is REQUIRED for each `case` option
    case $option in
        h) 
            # help message
            usage && exit 10;;
        c) 
            # copy instead of moving. defines a bool indicating to copy or to move
            copy=1;;
        o)
            # output directory. # check if it exists and remove trailing '/'
            outdir=$(echo "$OPTARG" | sed -r "s/\/*\s*$//g");;  
        p)
            # the pattern to replace
            src="$OPTARG";;
        r)
            # the replacement pattern
            rpl="$OPTARG";;
        ?)
            usage && exit;;
    esac;
done;

# validate the directories
check_path "$indir" 1;
check_path "$outdir" 0;


# ******************* process the replacements ********************** #

# if an output directory other than the source directory is 
# specified, check if the path is absolute or relative. if 
# it is relative, build the path to the output from the 
# current directory and not 'indir'
if [[ ! "$outdir" = /* ]] && [[ "$outdir" != "." ]];  then
    outdir="$cwd/$outdir"
fi;

echo "ARG '$indir' SRCTOKEN '$src' RPLTOKEN '$rpl' OUTDIR='$outdir'"

cd "$indir";

for f in *; do
    if [ -f "$f" ]; then
        newname="$outdir/"$(echo "$f" | sed -r "s/$src/$rpl/g");
        #mover "$f" "$newname" "$copy";
    fi;
done;

cd "$cwd";
