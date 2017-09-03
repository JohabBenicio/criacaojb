cp -p /tmp/ebook.html.bkp /tmp/ebook.html
rm -f /tmp/limpa_book.sh
for ((i=0;i<700;i++))
do
echo "sed -i 's/<a name=$i><b>Page $i<\/b><\/a>//' /tmp/ebook.html" >>/tmp/limpa_book.sh
done

sh /tmp/limpa_book.sh

cat /tmp/ebook.html | grep "<b>Page " | wc -l
cat /tmp/ebook.html.bkp | grep "<b>Page " | wc -l



sed -i 's/<a name=142><b>Page 142<\/b><\/a>//' /tmp/ebook.html




rm -f /tmp/limpa_book.sh
cat /tmp/ebook.html | grep "<b>Page " | sed 's/.*<b>Page\(\.*\)//' | sed 's/<\/b>\(.*\)//' | while read i
do
echo "sed -i 's/<a name=$i><b>Page $i<\/b><\/a>//' /tmp/ebook.html" >>/tmp/limpa_book.sh
done

sh /tmp/limpa_book.sh

cat /tmp/ebook.html | grep "<b>Page " | wc -l
cat /tmp/ebook.html.bkp | grep "<b>Page " | wc -l




















rm -f /tmp/limpa_book.sh
for ((i=0;i<700;i++))
do
echo "sed -i 's/<a name=$i><b>Página $i<\/b><\/a>//' /tmp/ebook.html" >>/tmp/limpa_book.sh
done

sh /tmp/limpa_book.sh

cat /tmp/ebook.html | grep "<b>Página " | wc -l
cat /tmp/ebook.html.bkp | grep "<b>Página " | wc -l








rm -f /tmp/limpa_book.sh
cat /tmp/ebook.html | grep "<b>Página " | sed 's/.*<b>Página\(\.*\)//' | sed 's/<\/b>\(.*\)//' | while read i
do
echo "sed -i 's/<a name=$i><b>Page $i<\/b><\/a>//' /tmp/ebook.html" >>/tmp/limpa_book.sh
done

sh /tmp/limpa_book.sh

cat /tmp/ebook.html | grep "<b>Page " | wc -l
cat /tmp/ebook.html.bkp | grep "<b>Page " | wc -l




