#!/bin/sh
#st everything a RPM file provides and requires
#


file=$1
basefile=`basename $file`

extname=${basefile##*.}

if ! [ "$extname" = "rpm" ] ;then
        echo "error must a rpm file"
        exit 0
fi

if [ ! -f "${file}" ] ; then
    echo "File ${file} does not exist!"
    exit
fi


RPM_DB_DIR=./db
if ! [ -d ${RPM_DB_DIR} ] ;then
	mkdir $RPM_DB_DIR
fi


AWK=/bin/awk
RM="/bin/rm -f"
RPM=/bin/rpm
SORT=/bin/sort
TOUCH=/bin/touch
UNIQ=/usr/bin/uniq



outfile=${RPM_DB_DIR}/${basefile}.db

$RM ${outfile}
# $TOUCH ${outfile}

echo "Processing: ${file}"


# what does this RPM package provide itself?
provides=`$RPM -qp --provides ${file} | $SORT | $UNIQ`
#echo "provides:" $provides

# what are the requirements of this RPM package?
reqs=`$RPM -qp --requires ${file} | $SORT | $UNIQ`
#echo "reqs:" $reqs


echo "${provides}" | while read line ; do
    echo "prov ${line}" > ${outfile}
done

echo "${reqs}" | while read line ; do
    echo "req ${line}" >> ${outfile}
done

