#!/bin/bash

# install:
# pydub==0.23.1
# srt==3.0.0

path_list=paths

while read line
do

filename=$(echo "$line" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)

mkdir "$filename"

srt_path=$(echo "$line" | sed 's/.wav/.srt/g')

python srt-parse.py "$line" "$srt_path" --output-dir "$filename"

done < $path_list
