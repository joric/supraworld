# always the same compression level, sadly. worse than zip with ultra
#env GZIP=-9 tar cvzf file.tar.gz resources
#tar c resources | gzip --best > best.file.tar.gz
#tar cvf - resources | gzip -9 - > new.file.tar.gz

build=7925
gzip -v9 -c /mnt/c/Temp/Exports/Supraworld/Plugins/GameFeatures/Supraworld/Supraworld/Content/Maps/Supraworld.json > Supraworld.$build.json.gz

