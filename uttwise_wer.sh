#!/bin/bash
text=$1
hyp=$2
. path.sh
cat $hyp |  while read -r line; do
echo $line > temp
echo -n `cut -d' ' -f1 temp` >> out
echo -n " " >> out
echo $line | sed 's/sil//g' | compute-wer --text --mode=present ark:$text ark,p:- | grep WER | awk '{print $2}' >> out 
done
