#!/bin/bash

# Copyright 2013  Bagher BabaAli

. ./cmd.sh 
[ -f path.sh ] && . ./path.sh

# Acoustic model parameters
decode_nj=20
train_nj=30
train_cmd=run.pl
decode_cmd=run.pl
data=data
train=train
test=test
lang=lang_2gram

mfccdir=mfcc_$data
for x in $train $test; do
  utils/fix_data_dir.sh $data/$x
  steps/make_mfcc.sh --cmd "$train_cmd" --nj 10 $data/$x exp/make_mfcc/$x $mfccdir 
  steps/compute_cmvn_stats.sh $data/$x exp/make_mfcc/$x $mfccdir 
  utils/validate_data_dir.sh $data/$x
done
#Monophone Training
mono=exp/mono
steps/train_mono.sh  --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang $mono 
utils/mkgraph.sh --mono $data/$lang_train exp/mono exp/mono/graph
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" exp/mono/graph $data/test exp/mono/decode
steps/align_si.sh --boost-silence 1.28 --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang exp/mono exp/mono_ali 

#Triphone 1 Training tri1, which is deltas + delta-deltas, on train data.
sen=1950
gauss=$(1950 * 16)
steps/train_deltas.sh --cmd "$train_cmd" $sen $gauss $data/$train $data/$lang exp/mono_ali exp/tri1_${sen}_${gauss}
utils/mkgraph.sh $data/$lang_train exp/tri1_${sen}_${gauss} exp/tri1_${sen}_${gauss}/graph
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd"  exp/tri1_${sen}_${gauss}/graph $data/test exp/tri1_${sen}_${gauss}/decode 

#Triphone 2 Training tri2, which is lda + mllt, on train data 
steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang exp/tri1_${sen}_${gauss} exp/tri1_${sen}_${gauss}_ali  
steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=3 --right-context=3" $sen $gauss $data/$train $data/$lang exp/tri1_${sen}_${gauss}_ali exp/tri2_${sen}_${gauss} 
utils/mkgraph.sh $data/$lang_train exp/tri2_${sen}_${gauss} exp/tri2_${sen}_${gauss}/graph 
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" exp/tri2_${sen}_${gauss}/graph $data/test exp/tri2_${sen}_${gauss}/decode
steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang exp/tri2_${sen}_${gauss} exp/tri2_${sen}_${gauss}_ali  

#clean and Segmentation od data
steps/cleanup/clean_and_segment_data.sh --nj "$train_nj" --cmd "$train_cmd" --segmentation-opts "--min-segment-length 0.3 --min-new-segment-length 0.6" $data/$train $data/$lang exp/tri2_${sen}_${gauss} exp/tri2_cleaned $data/${train}_cleaned

# TDNN Training
  local/chain/run_tdnn.sh --nj "$train_nj" --train-set ${train}_cleaned --test-sets "$test_sets" --gmm tri2_cleaned --nnet3-affix _${train}_cleaned

