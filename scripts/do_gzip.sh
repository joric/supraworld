# always the same compression level, sadly. worse than zip with ultra
#env GZIP=-9 tar cvzf file.tar.gz resources
#tar c resources | gzip --best > best.file.tar.gz
#tar cvf - resources | gzip -9 - > new.file.tar.gz

gzip -v9 -c Supraworld.json > Supraworld.gz

