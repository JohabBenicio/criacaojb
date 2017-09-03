
unset TEST

while read -r vdir
do
if [ "$vdir" == "log" ] && [ -d "$vdir" ]; then
export TEST="Encontrado"
fi
done < <(ls)

echo $TEST






unset TEST

ls | while read vdir
do
if [ "$vdir" == "log" ] && [ -d "$vdir" ]; then
export TEST="Encontrado"
fi
done

echo $TEST

