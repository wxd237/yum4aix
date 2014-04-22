#!/bin/sh
#
# try to recursively list all dependencies of a RPM file
#



file=$1

extname=${file##*.}

if ! [ "$extname" = "rpm" ] ;then
	echo "error must a rpm file"
	exit 0
fi

RPM_DB_DIR=./db


AWK=/bin/awk
CAT=/bin/cat
GREP=/bin/grep
LS=/bin/ls
SED=/bin/sed


f=${RPM_DB_DIR}/${file}.db

if [ ! -f "${f}" ] ; then
    echo "File ${f} does not exist!"
    exit
fi


# what does this RPM package provide itself?
provides=`$CAT ${f} | $GREP 'prov '`

#echo "$provides"
#echo "---------------------------------------"

# what are the requirements of this RPM package?
reqs=`$CAT ${f} | $GREP -v "/bin/sh" | \
                  $GREP -v "/bin/env" | \
                  $GREP -v "/usr/bin/awk" | \
                  $GREP -v "/usr/bin/env" | \
                  $GREP -v "/usr/bin/ksh" | \
                  $GREP -v "/usr/bin/ssh" | \
                  $GREP -v "rpmlib(VersionedDependencies)" | \
                  $GREP -v "libC.a(shr.o)" | \
                  $GREP -v "libC.a(ansi_32.o)" | \
                  $GREP -v "libX11.a(shr4.o)" | \
                  $GREP -v "libc.a(shr.o)" | \
                  $GREP -v "libcurses.a(shr42.o)" | \
                  $GREP -v "libnsl.a(shr.o)" | \
                  $GREP -v "libodm.a(shr.o)" | \
                  $GREP -v "libperfstat.a(shr.o)" | \
                  $GREP -v "libpthreads.a(shr_comm.o)" | \
                  $GREP -v "libpthreads.a(shr_xpg5.o)" | \
                  $GREP -v "librtl.a(shr.o)" | \
                  $GREP -v "req AIX-rpm" | \
                  $GREP -v "req /usr/opt/perl5/bin/perl" | \
                  $GREP -v "req tla" | \
                  $GREP -E -v "[lib]*\(*[.so]*\)" | \
                  $GREP -E -v "[lib]*\(*\)" | \
                  $GREP -E -v "[lib]*.so" | \
                  $GREP -E -v "[lib]*.so.[0-9]*" | \
                  $GREP -v "${provides}" | \
                  $SED "s|/sbin/install-info|info|g" | \
                  $SED "s|/usr/bin/bash|bash|g" | \
                  $SED "s|/usr/bin/lua|lua|g" | \
                  $SED "s|/usr/bin/perl|perl|g" | \
                  $SED "s|/usr/bin/python|python|g" | \
                  $SED "s|/usr/bin/wish|tk|g" | \
                  $SED "s|/usr/bin/xmlcatalog|libxml2|g" | \
                  $SED "s|/opt/freeware/bin/bash|bash|g" | \
                  $SED "s|/opt/freeware/bin/guile|guile|g" | \
                  $SED "s|/opt/freeware/bin/perl|perl|g" | \
                  $SED "s|/opt/freeware/bin/python|python|g" | \
                  $SED "s|/opt/freeware/bin/python2.6|python|g" | \
                  $SED "s|/opt/freeware/bin/rrdcgi|rrdtool|g" | \
                  $SED "s|/opt/freeware/bin/zsh|zsh|g" | \
                  $SED "s|/bin/bash|bash|g" | \
                  $SED "s|/bin/perl|perl|g" | \
                  $SED "s|/bin/tcsh|tcsh|g" | \
                  $SED "s|/bin/zsh|zsh|g" | \
                  $SED "s|docbook-dtd-xml|docbook-dtds|g" | \
                  $SED "s|python2.6|python|g" | \
                  $SED "s|python_64|python|g" | \
                  $SED "s|xft|libXft|g" | \
                  $SED "s|nss-system-init|nss-sysinit|g"| \
		  sort| uniq`

#echo "${reqs}"
#echo "---------------------------------------"

echo "${reqs}" | while read line ; do
    x=`echo "${line}" | $GREP -v -e "[*\(*\)*]" | $AWK '{ print $2 }'`
    if [ "${x}" != "" ] ; then
	cd rpmfile
        searchFile="`$LS -1 ${x}-[0-9]*`"
        if [ -f ${searchFile} ] ; then
            if [ "${searchFile}" != "${file}"  ] ; then
            	echo "${searchFile}"
	    fi
        fi
	cd ..
    fi
done
