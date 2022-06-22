!/usr/bin/env bash 

. ./cmd.sh
. ./path.sh
set -e # exit on error



utils/prepare_lang.sh data_VI/local/dict "<unk>" data_VI/local/lang_tmp data_VI/lang

cut -d' ' -f2- data_VI/train/text |sed 's:^:<s> :' |sed 's:$: </s>:' > temp_text
build-lm.sh -i temp_text -o lm.gz -n 4
compile-lm lm.gz -t=yes /dev/stdout | grep -v "<UNK>" | gzip -c > lm.arpa.gz

gunzip -c lm.gz | arpa2fst --disambig-symbol=#0 --read-symbol-table=data_VI/lang/words.txt - data_VI/lang/G.fst


