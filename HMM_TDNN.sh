. ./path.sh
. ./cmd.sh


train_cmd=run.pl
decode_cmd=run.pl

#feature Extraction
steps/make_mfcc_pitch.sh --nj 24 --cmd "run.pl" data/train_v1_21_05_22 exp_v1/make_mfcc/train mfcc
steps/compute_cmvn_stats.sh data/train_v1_21_05_22 exp_v1/make_mfcc/train mfcc
utils/fix_data_dir.sh data/train_v1_21_05_22

#training Mono
steps/train_mono.sh --nj 24 data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/mono

#Alignment and Tri1 training
steps/align_si.sh --boost-silence 1.25 --nj 24 --cmd "$train_cmd" data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/mono exp_v1/mono_ali
steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" 2000 10000 data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/mono_ali exp_v1/tri1

#Alignment and Tri2 LDA + MLLT training
steps/align_si.sh --nj 24 --cmd "$train_cmd" data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/tri1 exp_v1/tri1_ali
steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=3 --right-context=3" 2500 15000 data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/tri1_ali exp_v1/tri2

#Alignment and Tri3 LDA + MLLT + SAT training
steps/align_si.sh --nj 24 --cmd "$train_cmd" data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/tri2 exp_v1/tri2_ali
steps/train_sat.sh --cmd "$train_cmd" 4200 40000 data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/tri2_ali exp_v1/tri3

#Clean and segment data
steps/cleanup/clean_and_segment_data.sh --nj 24 --cmd run.pl  --segmentation-opts "--min-segment-length 0.3 --min-new-segment-length 0.6"  data/train_v1_21_05_22  data/lang_ngram_v1 exp_v1/tri3 exp_v1/tri3_cleaned data/train_v1_21_05_22_cleaned

#Alignment for cleaned and segmented data
steps/align_si.sh --nj 24 --cmd "$train_cmd" data/train_v1_21_05_22_cleaned data/lang_ngram_v1 exp_v1/tri3 exp_v1/tri3_cleaned_ali
steps/train_sat.sh --cmd "$train_cmd" 4200 40000 data/train_v1_21_05_22_cleaned data/lang_ngram_v1 exp_v1/tri3_cleaned_ali exp_v1/tri3_cleaned_new
utils/mkgraph.sh data/lang_ngram_v1 exp_v1/tri3_cleaned_new exp_v1/tri3_cleaned_new/graph
steps/align_si.sh --nj 24 --cmd "$train_cmd" data/train_v1_21_05_22_cleaned data/lang_ngram_v1 exp_v1/tri3_cleaned_new exp_v1/tri3_cleaned_new_ali

# TDNN Training
  local/chain/run_tdnn.sh --nj 24 --train-set data/train_v1_21_05_22_cleaned --gmm exp_v1/tri3_cleaned_new 
                                                                                                                                                

