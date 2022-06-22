#!/bin/bash

# Copyright 2013  Bagher BabaAli

. ./cmd.sh 
[ -f path.sh ] && . ./path.sh

# Acoustic model parameters
numGaussUBM=84  # 400, 286
numLeavesSGMM=380   # 1000
numGaussSGMM=6*380    # 400 450 5000
data=$1
decode_nj=20
train_nj=30
train_cmd=run.pl
decode_cmd=run.pl
#train_cmd=queue_cpu.pl
#decode_cmd=queue_cpu.pl
dict_prep=0
mfcc=1
mono=1
tri1=1
tri2=1
tri3=1
decode=1
TDNN=0
train=train
lang=lang

if [ $dict_prep -eq 1 ]; then
utils/prepare_lang.sh $data/local/dict "!சில்" \
               $data/local/lang_tmp $data/$lang || exit 1;
echo "Successfully created Dictionary and Language Models"
fi


if [ $mfcc -eq 1 ]; then
echo ============================================================================
echo "         MFCC Feature Extration & CMVN for Training and train_7K set           "
echo ============================================================================

# Now make MFCC features.
mfccdir=mfcc_$data

#for x in new_test; do
for x in $train; do
  steps/make_mfcc.sh --cmd "$train_cmd" --nj 10 $data/$x exp/make_mfcc/$x $mfccdir || exit 1;
  steps/compute_cmvn_stats.sh $data/$x exp/make_mfcc/$x $mfccdir || exit 1;
done
fi

if [ $mono -eq 1 ]; then
echo ============================================================================
echo "                     MonoPhone Training & Decoding                        "
echo ============================================================================
mono=exp/mono
steps/train_mono.sh  --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang $mono || exit 1;

fi

if [ $tri1 -eq 1 ]; then
echo ============================================================================
echo "           tri1 : Deltas + Delta-Deltas Training & Decoding               "
echo ============================================================================

steps/align_si.sh --boost-silence 1.28 --nj "$train_nj" --cmd "$train_cmd" $data/$train $data/$lang exp/mono exp/mono_ali || exit 1;

# Train tri1, which is deltas + delta-deltas, on train data.

for sen in 1950; do
for gauss in 16; do
gauss=$(($sen * $gauss))
steps/train_deltas.sh --cmd "$train_cmd" $sen $gauss $data/$train $data/$lang exp/mono_ali exp/tri1_${sen}_${gauss} || exit 1;
done
done
fi


if [ $tri2 -eq 1 ];then
echo ============================================================================
echo "                 tri2 : LDA + MLLT Training & Decoding                    "
echo ============================================================================

for sen in  1950; do
for gauss2 in 16; do
gauss2=$(($sen * $gauss2))
steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
 $data/$train $data/$lang exp/tri1_${sen}_${gauss2} exp/tri1_${sen}_${gauss2}_ali  || exit 1;

steps/train_lda_mllt.sh --cmd "$train_cmd" \
 --splice-opts "--left-context=3 --right-context=3" \
 $sen $gauss2 $data/$train $data/$lang exp/tri1_${sen}_${gauss2}_ali exp/tri2_${sen}_${gauss2} || exit 1;

steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
 $data/$train $data/$lang exp/tri2_${sen}_${gauss2} exp/tri2_${sen}_${gauss2}_ali  || exit 1;

#cp -r exp/tri2_${sen}_${gauss2} exp/tri2
#cp -r exp/tri2_${sen}_${gauss2}_ali exp/tri2_ali


done
done
fi


if [ $tri3 -eq 1 ];then
echo ============================================================================
echo "                 tri3 : LDA + MLLT + SAT                   "
echo ============================================================================

for sen in  1950; do
for gauss2 in 16; do
gauss2=$(($sen * $gauss2))

steps/train_sat.sh --cmd $train_cmd \
	--splice-opts "--left-context=3 --right-context=3" \
	$sen $gauss2 $data/$train $data/$lang exp/tri2_${sen}_${gauss2}_ali exp/tri3_${sen}_${gauss2} || exit 1;

steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" \
 $data/$train $data/$lang exp/tri3_${sen}_${gauss2} exp/tri3_${sen}_${gauss2}_ali  || exit 1;

steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
 $data/$train $data/$lang exp/tri3_${sen}_${gauss2} exp/tri3_${sen}_${gauss2}_ali  || exit 1;


done
done
fi

if [ $decode -eq 1 ]; then
echo ============================================================================
echo "Finished successfully on" `date`
echo ============================================================================

utils/mkgraph.sh --mono $data/$lang_train exp/mono exp/mono/graph || exit 1;
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
    exp/mono/graph $data/test exp/mono/decode || exit 1;
for sen in  1950; do
for gauss2 in 16; do
gauss2=$(($sen * $gauss2))
gauss=$gauss2
utils/mkgraph.sh $data/$lang_train exp/tri1_${sen}_${gauss} exp/tri1_${sen}_${gauss}/graph || exit 1;
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
 exp/tri1_${sen}_${gauss}/graph $data/test exp/tri1_${sen}_${gauss}/decode || exit 1;

utils/mkgraph.sh $data/$lang_train exp/tri2_${sen}_${gauss2} exp/tri2_${sen}_${gauss2}/graph || exit 1;
steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
  exp/tri2_${sen}_${gauss2}/graph $data/test exp/tri2_${sen}_${gauss2}/decode

utils/mkgraph.sh $data/$lang_train exp/tri3_${sen}_${gauss2} exp/tri3_${sen}_${gauss2}/graph || exit 1;
steps/decode_fmllr.sh --nj "$decode_nj" --cmd "$decode_cmd" \
  exp/tri3_${sen}_${gauss2}/graph $data/test exp/tri3_${sen}_${gauss2}/decode

done
done

fi


if [ $TDNN -e 1 ]; then
echo ============================================================================
echo "TDNN Training" 
echo ============================================================================
local/chain/run_tdnn.sh


exit 0
