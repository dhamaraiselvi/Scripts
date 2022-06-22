source path.sh

rm /home/uniphore/Experiments/data_iitm_hindi/local/dict/lexiconp.txt
rm -rf /home/uniphore/Experiments/data_iitm_hindi/lang_mandi
mkdir /home/uniphore/Experiments/data_iitm_hindi/lang_mandi

utils/prepare_lang.sh /home/uniphore/Experiments/data_iitm_hindi/local/dict '!SIL' /home/uniphore/Experiments/data_iitm_hindi/local/lang /home/uniphore/Experiments/data_iitm_hindi/lang_mandi
rm lm.*
rm dummy_hindi
awk '{$1="";print $0}' /home/uniphore/Experiments/data_iitm_hindi/train_3hr/text |  sed -e 's:^:<s> :' -e 's:$: </s>:' > dummy_hindi

build-lm.sh -i dummy_hindi -o lm.gz -n 3
compile-lm lm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > lm.arpa.gz
gunzip -c lm.arpa.gz | arpa2fst - | fstprint | eps2disambig.pl | s2eps.pl | fstcompile --isymbols=/home/uniphore/Experiments/data_iitm_hindi/lang_mandi/words.txt --osymbols=/home/uniphore/Experiments/data_iitm_hindi/lang/words.txt  | fstrmepsilon > /home/uniphore/Experiments/data_iitm_hindi/lang/G.fst

echo " Succesfull"

