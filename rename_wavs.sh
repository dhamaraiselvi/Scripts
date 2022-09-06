folder="KWE3k701-800"
rm -r "$folder"_"renamed"
mkdir -p "$folder"_"renamed"

rm temp3.txt
rm chunk_list

find *.wav | sort -V > chunk_list
#cat chunk_list | sort -n > del
#find . -iname "*.wav" | sort -r > see
#python3 sorted_chunks.py
sed -n '4829,4928p' /media/administrator/hdd/DEEPSPEECH_DATA_PREPARATION/Jeeva/ashwini_english/ashwini_eng_anirban_preparation/Eng_text > temp1.txt

ids=$(sed < temp1.txt -e "s/^(//g" -e "s/ )$//g" | cut -d " " -f 1)
paste -d " " <(echo "${ids}") > temp2.txt
sed 's/(//' temp2.txt > temp3.txt

while IFS= read -r line1 && IFS= read -r line2 <&3; 
do
    utt_id="$(cut -d" " -f1 <<<$line2)"
    #echo $utt_id
    sox $(pwd)/"$line1" -r 16000 -b 16 -t wav $folder"_"renamed/$utt_id.wav norm
    
done < chunk_list 3< temp3.txt










