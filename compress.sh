#!/bin/bash

find ./ -type f -regextype posix-extended -regex '.*\.gz' | xargs rm

for file in $(find ./ -type f -regextype posix-extended -regex '.*\.(jpg|png|gif|css|js)'); do 
  echo $file
  gzip -9 -n $file -c > ${file}.gz
done

#find ./ -type f -regextype posix-extended -regex '.*\.(jpg|png|gif|css|js)'
