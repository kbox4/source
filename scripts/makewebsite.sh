function process_html 
  {
  htmlfile=$1;
  echo Process $htmlfile
  basename=`basename "$htmlfile"`
  output_file=$output_dir/$basename
  cp $top_template $output_file
  cat $htmlfile >> $output_file
  cat $bottom_template >> $output_file
  }


####
# START HERE
####

####
# Work out where we are, and locate the env.sh file, which contains the
#  file locations we need 
####

rm -f $htmlfile
me=`realpath $0`
up1=`dirname $me`
top=`dirname $up1`
. $top/env.sh

output_dir=$DIST
html_dir=$top/docs/public_html
top_template=$html_dir/_top.html
bottom_template=$html_dir/_bottom.html
mkdir -p $output_dir
echo $top_template

####
# Enumarate the packages directory and construct the packages.html file.
# Note that not everything in the packages/ directory corresponds to an
#  installable DEB pacakge -- some entries are libraries. In addition, at
#  any given time there might be packages that are works in progress, and
#  should not be documented. These should not have a packageinfo.html
#  file, so they get skipped.
#
#  Note also that (um...) there are some inconsistencies in the package
#   naming, such that .deb names do not match directory names. These cases
#   have to be handled specifically in this script :/
####

packagehtmlfile=/tmp/kbox_packages.html
echo "<h1>Installable packages</h1>" > $packagehtmlfile
packages=$top/packages
for x in $packages/* ; do
  packagename=`basename $x`
  packageinfo=$x/packageinfo.html
  if [ -f $packageinfo ] ; then
    echo "<h3>$packagename</h3>" >> $packagehtmlfile
    cat $packageinfo >> $packagehtmlfile
    echo "<p/>" >> $packagehtmlfile
    echo "<ul>" >> $packagehtmlfile
    depends=" "
    # Special handling for packages whose names do not
    #  match their .deb files, for whatever reason
    if [[ $packagename =~ python ]] ; then
      packagename="Python"
    fi
    if [[ $packagename =~ dropbear ]] ; then
      packagename="sshclient"
    fi
    if [[ $packagename =~ solunar ]] ; then
      packagename="solunar"
    fi
    for y in $DIST/$packagename*.deb ; do
      depends=`ar p $y control.tar.gz | tar xfz - -O | grep Depends:`
      deb=`basename $y`
      echo "<li><a href=\"$deb\">$deb</a></li>" >> $packagehtmlfile
    done
    echo "</ul>" >> $packagehtmlfile
    depends=`echo "$depends" | tr -d '\n'`
    depends=`echo "$depends" | cut -f 2- -d ' '`
    if [[ $depends =~ ^\ *$ ]] ; then
     true 
    else
      echo "<i>" >> $packagehtmlfile
      echo "Dependencies: " >> $packagehtmlfile
      echo $depends >> $packagehtmlfile
      echo "</i>" >> $packagehtmlfile
    fi
  else
    echo "Warning: no packageinfo file in $x"
  fi
done

process_html $packagehtmlfile;

####
# Do a plain copy of image and CSS files to the output directory
####

#cp $html_dir/*.png $output_dir
cp $html_dir/*.css $output_dir

 
####
# Apply templates to HTML files, apart from those starting with _
####

for x in $html_dir/*.html ; do
  bn=`basename "$x"`
  if [[ $bn =~ ^\_ ]] ; then
    true # skip it 
  else
    process_html $x
  fi
done








