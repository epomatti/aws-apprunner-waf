
for i in {1..10000}
do
    # "number: $i"
    curl $1
    echo $i
done
