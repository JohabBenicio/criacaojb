






for i in {23..99}
wget http://www.wuxiaworld.com/desolate-era-index/de-book-23-chapter-11 -O chapter11.txt




Book 1 (Chapters 1-95)
Book 2 (Chapters 96-204)
Book 3 (Chapters 205-313)
Book 4 (Chapters 314-628)
Book 5 (Chapters 629-800)
Book 6 (Chapters 801-1004)
Book 7 (Chapters 1005-1211)






629..800
801..1004
1005..1211

| sed 's/;;/;/g'

;sup class='footnote';
;a href='#fn-26693-1' id='fnref-26693-1' onclick='return fdfootnote_show(26693)';
1
;;
a
;;
;sup;







mga-capitulo-




################################################################################################################
################################################################################################################
################################################################################################################

1 - 1-18
Battle of Dignity

Volume 1 - Battle of Dignity (1–264)
Martial God Asura


for i in {1..18}
do
wget http://www.wuxiaworld.com/desolate-era-index/de-book-1-chapter-$i -O de-book_1_capitulo-$i
done



FILE_OK=chapter_DE_book.txt
rm -f $FILE_OK
for i in {1..18}
do
FILE=de-book_1_capitulo-$i
ls $FILE
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" >> $FILE_OK
done


rm -f file.txt
cat $FILE_OK > file.txt
rm -f $FILE_OK
cat file.txt | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/–/ /g" | sed "s/, /, /g" | sed "s/ / /g" | sed "s/‘/'/g" | sed "s/Chapter/Capitulo/g" >> $FILE_OK





function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}





f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK





cat $FILE_OK




################################################################################################################
################################################################################################################
################################################################################################################


Battle of Dignity

Volume 1 - Battle of Dignity (1–264)
Martial God Asura


for i in {1..264}
do
wget http://www.wuxiaworld.com/mga-index/mga-chapter-$i -O mga-capitulo-$i
done



FILE_OK=chapter_mga_book.txt
rm -f $FILE_OK
for i in {1..264}
do
FILE=mga-capitulo-$i
ls $FILE
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" >> $FILE_OK
done


rm -f file.txt
cat $FILE_OK > file.txt
rm -f $FILE_OK
cat file.txt | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/–/ /g" | sed "s/, /, /g" | sed "s/ / /g" | sed "s/Chapter/Capitulo/g" >> $FILE_OK





function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}





f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK





cat $FILE_OK





################################################################################################################
################################################################################################################
################################################################################################################





for i in {301..321}
do
wget http://www.wuxiaworld.com/sr-index/sr-chapter-$i -O sr-capitulo-$i
done



FILE_OK=chapter_sr_book.txt
rm -f $FILE_OK
for i in {301..321}
do
FILE=sr-capitulo-$i
ls -l $FILE
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" >> $FILE_OK
done






rm -f file.txt
cat $FILE_OK > file.txt
rm -f $FILE_OK
cat file.txt | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/–/ /g" | sed "s/, /, /g" | sed "s/ / /g" | sed "s/Chapter/Capitulo/g" >> $FILE_OK








function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}





f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK










################################################################################################################
################################################################################################################
################################################################################################################




for i in {1200..1202}
do
wget http://www.wuxiaworld.com/mga-index/mga-chapter-$i -O mga-capitulo-$i
done



FILE_OK=chapter_mga_book.txt
rm -f $FILE_OK
for i in {1394..1400}
do
FILE=mga-capitulo-$i
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" >> $FILE_OK
done


function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}


f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK





################################################################################################################
################################################################################################################
################################################################################################################


for i in {149..152}
do
wget http://www.wuxiaworld.com/rebirth-index/rebirth-chapter-$i -O rebirth-capitulo-$i
done





FILE_OK=chapter_rebirth_book.txt
rm -f $FILE_OK
for i in {149..152}
do
FILE=rebirth-capitulo-$i
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" | sed "s/(//g"  >> $FILE_OK
done


function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}






f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK


cat $TMP_OUT.sh





################################################################################################################
################################################################################################################
################################################################################################################












FILE_OK=chapter_issth_book_2.txt

rm -f $FILE_OK
for i in {130..629}
do
FILE=chapter_issth_$i.txt
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/\//;/g' | sed 's/</;/g' | sed 's/>/;/g' | sed 's/;;/;/g' >> $FILE_OK

done



while read line
do

VALID=$(echo $line | grep ";" | wc -l)

if [ $VALID -gt 0 ]; then
VAL1=$(echo $line | cut -d ";" -f 2)
sed -i "s/;$VAL1;//g" $FILE_OK
fi

done < $FILE_OK








FILE_OK=chapter_issth.txt

rm -f $FILE_OK
for i in {130..629}
do
FILE=chapter_issth_$i.txt
HEAD="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ">Previous Chapter<" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/\//;/g' | sed 's/</;/g' | sed 's/>/;/g' | sed 's/;;/;/g' >> $FILE_OK

done



while read line
do

VALID=$(echo $line | grep ";" | wc -l)

if [ $VALID -gt 0 ]; then
VAL1=$(echo $line | cut -d ";" -f 2)
sed -i "s/;$VAL1;//g" $FILE_OK
fi

done < $FILE_OK




cat $FILE.ok








168


for i in {130..629}
do

if [ $i -gt 120 ] && [ $i -lt 205 ]; then
wget http://www.wuxiaworld.com/issth-index/issth-book-2-chapter-$i -O chapter_issth_$i.txt

elif [ $i -gt 204 ] && [ $i -lt 314 ]; then
wget http://www.wuxiaworld.com/issth-index/issth-book-3-chapter-$i -O chapter_issth_$i.txt

elif [ $i -gt 313 ] && [ $i -lt 629 ]; then
wget http://www.wuxiaworld.com/issth-index/issth-book-4-chapter-$i -O chapter_issth_$i.txt
fi

done





for i in {53..300}
do
rm -f chapter_$i.txt
done




rm -f chapter_*ok.txt

for i in {53..129}
do
FILE=chapter_$i.txt
HEAD="$(grep -n ISSTH $FILE | grep ANTERIOR | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n ISSTH $FILE | grep ANTERIOR | cut -d ":" -f 1 | tail -1)"

cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g"  | sed "s/&#8220;//g" | sed "s/&#8230;//g" | sed "s/&#8221;//g" | sed "s/&#8216;//g" | sed "s/&#8217;//g" | sed "s/<\/a>//g" | sed "s/<hr \/>//g" | sed "s/<br \/>//g" | sed "s/<em>stela<\/em>//g" | sed 's/<.*>//g' | sed 's/&nbsp;//g' >chapter_$i\_ok.txt
done





grep "&" chapter_*ok.txt | cut -d ":" -f 2





for i in {53..129}
do
cat chapter_$i\_ok.txt >> primcipal.txt
done




cat primcipal.txt






for i in {115..129}
do
wget http://novelmania.com.br/chinesa/issth-indice/issth-capitulo-$i -O issth-capitulo-$i
done










for i in {1..50}
do
wget http://novelmania.com.br/chinesa/mga-indice/mga-capitulo-$i -O mga-capitulo-$i
done










Martial-God-Asura.txt




FILE_OK=Martial-God-Asura.txt
rm -f $FILE_OK
for i in {1..50}
do
FILE=mga-capitulo-$i
HEAD="$(grep -n "MGA – Capitulo" $FILE | grep header | cut -d ":" -f 1 | head -1)d"
TAIL="$(grep -n "CAPÍTULO ANTERIOR" $FILE | cut -d ":" -f 1 | tail -1)"
cat $FILE | sed "$TAIL,3333d" | sed "1,$HEAD" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g" | sed 's/<p>//g' | sed 's/<\/p>//g' | sed "s/<hr\/>//g" | sed "s/<strong>//g" | sed "s/<\/strong>//g" | sed "s/<\/span>//g"  | sed "s/&#8220;//g" | sed "s/&#8230;//g" | sed "s/&#8221;//g" | sed "s/&#8216;//g" | sed "s/&#8217;//g" | sed "s/<\/a>//g" | sed "s/<hr \/>//g" | sed "s/<br \/>//g" | sed "s/<em>stela<\/em>//g" | sed 's/&nbsp;//g' | sed 's/&#8212;//g' | sed 's/&#8211;//g' | sed 's/&#8217;//g' | sed 's/<\/hr>//g' | sed 's/<hr>//g' | sed 's/<\/sup>//g'| sed 's/<\/a>//g'| sed 's/<\/sup>//g'| sed 's/<br\/>//g'  | sed "s/<\/em>//g" | sed "s/<em>//g" | sed "s/<sup class='footnote'>//g" | sed 's/\//;/g' | sed 's/>/</g' | sed "s/\"/'/g" | sed "s/;//g" | sed "s/://g" | sed "s/='//g" | sed "s/'</</g" | sed "s/#//g" | sed 's/&8220//g' | sed 's/&8221//g' | sed 's/&8230//g' | sed 's/“/"/g' | sed 's/”/"/g' | sed "s/’/'/g" | sed "s/…/.../g" | sed "s/</ < /g" | sed "/CAPÍTULO ANTERIOR/d" | sed "s/‘/'/g"  >> $FILE_OK
done




less $FILE_OK

function f_encontra_sugera () {
TMP_OUT=/tmp/out_files
rm -f $TMP_OUT
while read line
do

VAL1=$(echo $line | cut -d "<" -f 2)
echo "<$VAL1<" >> $TMP_OUT
done < <(grep "<" $FILE_OK)

cat $TMP_OUT

}


function f_limpa_sugera () {
rm -f $TMP_OUT.sh
while read line
do
cat <<EOF>>$TMP_OUT.sh
sed -i "s/$line//g" $FILE_OK
EOF
done < <(cat $TMP_OUT | sort | uniq)

chmod +x $TMP_OUT.sh
$TMP_OUT.sh

}


f_encontra_sugera
f_limpa_sugera
grep "<\|>" $FILE_OK









for i in {1..50}
do
ls mga-capitulo-$i
done







http://www.wuxiaworld.com/mga-index/mga-chapter-1291/

1376



for i in {1394..1400}
do
wget http://www.wuxiaworld.com/mga-index/mga-chapter-$i -O mga-capitulo-$i
done





for i in {1200..1202}
do
wget http://www.wuxiaworld.com/mga-index/mga-chapter-$i -O mga-capitulo-$i
done


for i in {149..152}
do
wget http://www.wuxiaworld.com/rebirth-index/rebirth-chapter-$i -O rebirth-capitulo-$i
done




############################################################################################################


curl -O http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz

tar -zxvf wget-1.15.tar.gz
cd wget-1.15/













