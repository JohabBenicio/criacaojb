

find -name "arch*" -mtime +1 -exec du -m {} \;



export VAL1=0
find -name "arch*" -mtime -1 -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb







export VAL1=0
find full* -mtime +0 -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb






export VAL1=0
find *.arc -mtime 0 -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb





export VAL1=0
find * -mtime +130 -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb








export VAL1=0
find *.dmp -mtime 0 -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb










export VAL1=0
find *.dmp -exec du -m {} \; | awk '{print $1}' | while read bkp
do
export VAL=$(echo $bkp+$VAL1 | bc)
export VAL1=$VAL
echo "$VAL1 Mb" >/tmp/last_val.jb
done
cat /tmp/last_val.jb && rm -f /tmp/last_val.jb



