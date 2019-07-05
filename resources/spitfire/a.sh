for f in *.jpeg; do 
    mv -- "$f" "${f%.jpeg}.jpg"
done
