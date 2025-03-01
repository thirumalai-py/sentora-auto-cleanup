#!/bin/bash

for dir in ~/Downloads/*/; do
    count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    if [ $count -gt 5 ]; then
        echo "Directory to clean: $dir: $count files" >> sample.txt
        # echo "$data" >> sample.txt
    fi
done