#!/env/bin/bash

# script to rename/copy files in a folder, replacing 
# spaces with '_'
#
# @argument : the path to the folder to process
# @option   : '-c' : copy files instead of renaming them
# @option   : '-t' : the token to replace (defaults to whitespace)
# @option   : '-r' : the replacement token (with which to replace) 
#                    token with which to perform the replacements
# @option   : '-o' : directory to copy/move the renamed files to


# *********************** base functions *********************** #
# help
usage() {
    echo ""
    echo "USAGE: bash filename_formatter.sh /path/to/directory [-c|-t|-r|-h]"
    echo ""
    echo "  script to change filenames in a folder, replacing one character"
    echo "  with anoter (by default, replacing spaces with '_'). files are"
    echo "  moved (the file with the old name is deleted) or copied (the)"
    echo "  file with the old name is kept"
    echo ""
    echo "  argument  : the path to the folder to process"
    echo "  -h        : show help and exit"
    echo "  -c        : copy files instead of renaming them"
    echo "  -o PATH   : the output directory where to move/copy the renamed files"
    echo "  -t STRING : the token to replace (defaults to ' ')"
    echo "  -r STRING : the replacement token (with which to replace)" 
    echo "                token with which to perform the replacements"
    echo "                (defaults to '_')"
    echo ""
}

# check if the path is correct
check_path() {
    if [ "$indir" = "" ]; then
        usage
        echo "ERROR : please provide the directory to process as an argument";
        exit 1;
    else if [ ! -d "$indir" ]; then
        usage
        echo "ERROR : input directory '$dir' doesn't exist";
        exit 1;
    fi;
    fi;
}

# *********************** parse the arguments *********************** #
unset OPTARG  # undefine OPTARG wich could be used as an ENV variable

# what happens right below: shift moves all numbered options by -1 
# ($1 becomes $0) so that getopts can process only options, and not
# the first positionnal argument
indir=$1 && shift && check_path;

# define defaults
cwd=$(pwd | sed -e "s/\/*\s*$//g");  # remove trailing slashes
copy=0;
srctoken=" ";
rpltoken="_";
outdir="./"

# getopts is used in a while loop; it takes a string argument
# which is a list of allowed options: 'abc' means that the
# only allowed options are 'a', 'b' and 'c'. 
# - if an option is prefixed with ':', the error messages will
#   ignored for that option ('ab:c')
# - if an option should be used with a user-inputted value,
#   this option must be followed by ':' ('abc:')
# - '$OPTARG' defines an option's argument
while getopts "hct:r:o:" option; do
    # get each option, assign them to `$option` and process them
    # the double semi-colon is REQUIRED for each `case` option
    case $option in
        h) 
            usage && exit;;
        c) 
            copy=1;;  # bool indicating to copy or to move
        o)
            outdir=$(echo "$OPTARG" | sed -e "s/\/*\s*$//g")  # remove trailing '/' in the output directory
            if [ ! -d "$outdir" ]; then
                echo "output directory '$outdir' doesn't exist. create it before running the script!";
                exit 1;  
            fi;;  
        t)
            srctoken="$OPTARG";;  # the token to replace
        r)
            rpltoken="$OPTARG";;  # the replacement token
        ?)
            usage && exit;;
        *)
            usage && exit;;
    esac;
done;

# echo "ARG '$indir' SRCTOKEN '$srctoken' REPLTOKEN '$repltoken' OUTDIR='$outdir'"

# ******************* process the replacements ********************** #

# if an output directory is specified, build the path to 
# the output from the current directory and not 'indir'
if [[ "$outdir" != "." ]];  then
    outdir="$cwd/$outdir"
fi;

cd "$indir";

for f in *; do
    if [ -f "$f" ]; then
        newname=${f//$srctoken/$rpltoken};
        if [[ "$copy" = 1 ]]; then
            cp "$f" "$outdir/$newname";
        else
            mv "$f" "$outdir/$newname";
        fi;
    fi;
done;

cd ..
