#!/bin/bash

# Change log
# CDC: 2017-03-09 rewrote to work on either Xubuntu or MacOS
# CDC: 2016-10-21 updated from version attempted (and failed) in 2014

# Description

# After installation of TeXLive-2016, attempt to compile files using htlatex failed during
## pdflatex --output=dvi 
# with messages whose key content was that there were problems with
## '\:temp{rm}'

# Google search found a solution at http://tex.stackexchange.com/questions/161229/htlatex-interrupted-at-temprm

## Steps:
#   -- Download script found there to file ./downloads/koma-new.patch
#   -- Download tex4ht-4ht.tex revision 129 from
## http://svn.gnu.org.ua/viewvc/tex4ht/trunk/lit/tex4ht-4ht.tex?view=markup&pathrev=129
#   -- Run this script

# Could not figure out how to make MacOS create a universally available environment variable
# Best guess is that Apple has done its best to prevent users from doing that
# Alternative is to manually source the dotbashrc file to bring in environment variables

source /Methods/Tools/Config/tool/bash/dotbashrc-all

cd $METH_INSTALL/Software/TeXLive/Patches/scr-htlatex-bug

# If script has been run before, remove results in tmp directory
if [ -e ./tmp ]; then
    sudo rm -Rf ./tmp
fi

# create tmp directory to contain all the files generated by the patch
mkdir tmp

# copy the tools into the tmp directory 
cp -p ./downloaded/tex4ht-4ht.tex tmp
cp -p ./downloaded/koma-new.patch tmp

cd tmp

# Run the patch, which should apply to tex4ht-4ht.tex version 129
# (which should be the version downloaded from the page mentioned above)

patch --ignore-whitespace --verbose tex4ht-4ht.tex < koma-new.patch

# With the patchfile originally obtained in 2014, this command did not work, generating an error message indicating a
# 'malformed patch' in various lines.  Google search suggested this is likely due to the downloaded file having a different
# pattern of spacing (maybe beginning-of-line spacing) than the original upload by the author of the patch.  Confirmed
# this by redownloading koma-patch.new taking care to make sure spaces were preserved.  The recommended

# patch tex4ht-4ht.tex < koma-new.patch

# command still generated an error; adding the --verbose option indicated that

#  Hunk #2 FAILED at 17219.

# and further investigation found that the patchfile had a different number of spaces in a line beginning \csname o:
#
# Finally, adding the --ignore-whitespace option allowed the patch to work

# Now get the two key files that need patching 
sudo cp `kpsewhich scrartcl.4ht` .
sudo cp `kpsewhich article.4ht`  .

# Generate a whole new suite of .4ht files, using the (patched) tex4ht-4ht.tex
tex tex4ht-4ht.tex

patch ./scrartcl.4ht < ../koma-cdc.patch
# Copy the files to the appropriate location and set permissions 
sudo cp ./scr*.4ht  /usr/local/texlive/texmf-dist/tex/generic/tex4ht/
sudo chmod a+r /usr/local/texlive/texmf-dist/tex/generic/tex4ht/scr*.4ht

if [ `uname` == "Darwin" ]; then # MacOS and Linux want different ownership
    sudo chown root:wheel  /usr/local/texlive/texmf-dist/tex/generic/tex4ht/scr*.4ht
else
    sudo chown root:root   /usr/local/texlive/texmf-dist/tex/generic/tex4ht/scr*.4ht
fi

sudo chmod a+r         /usr/local/texlive/texmf-dist/tex/generic/tex4ht/scr*.4ht 
sudo chmod g-w         /usr/local/texlive/texmf-dist/tex/generic/tex4ht/scr*.4ht 


