. ./path.sh
. ./cmd.sh


train_cmd=run.pl
decode_cmd=run.pl

steps/make_mfcc_pitch.sh --nj 24 --cmd "run.pl" data_VI/train exp/VI_AUG/make_mfcc/train mfcc_aug
steps/compute_cmvn_stats.sh data_VI/train exp/VI_AUG/make_mfcc/train mfcc_aug
utils/fix_data_dir.sh data_VI/trai

steps/make_mfcc_pitch.sh --nj 24 --cmd "run.pl" data_VI/train_aug exp/VI_AUG/make_mfcc/train_aug mfcc_aug
steps/compute_cmvn_stats.sh data_VI/train_aug exp/VI_AUG/make_mfcc/train_aug mfcc_aug
utils/fix_data_dir.sh data_VI/train_aug

steps/make_mfcc_pitch.sh --nj 24 --cmd "$train_cmd" data_VI/test exp/VI_AUG/make_mfcc/test mfcc
steps/compute_cmvn_stats.sh data_VI/test exp/VI_AUG/make_mfcc/test mfcc
utils/fix_data_dir.sh data_VI/test


steps/train_mono.sh --nj 24 data_VI/train_aug data_VI/lang exp/VI_AUG/mono
utils/mkgraph.sh data_VI/lang exp/VI_AUG/mono exp/VI_AUG/mono/graph
steps/decode.sh --nj 24 --cmd "$decode_cmd" exp/VI_AUG/mono/graph data_VI/test/ exp/VI_AUG/mono/decode_test

steps/align_si.sh --boost-silence 1.25 --nj 24 --cmd "$train_cmd" data_VI/train_aug data_VI/lang exp/VI_AUG/mono exp/VI_AUG/mono_ali
steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" 2000 10000 data_VI/train_aug data_VI/lang exp/VI_AUG/mono_ali exp/VI_AUG/tri1
utils/mkgraph.sh data_VI/lang exp/VI_AUG/tri1 exp/VI_AUG/tri1/graph
steps/decode.sh --nj 24 --cmd "$decode_cmd" exp/VI_AUG/tri1/graph data_VI/test exp/VI_AUG/tri1/decode_test

steps/align_si.sh --nj 24 --cmd "$train_cmd" data_VI/train_aug data_VI/lang exp/VI_AUG/tri1 exp/VI_AUG/tri1_ali
steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=3 --right-context=3" 2500 15000 data_VI/train_aug data_VI/lang exp/VI_AUG/tri1_ali exp/VI_AUG/tri2
utils/mkgraph.sh data_VI/lang exp/VI_AUG/tri2 exp/VI_AUG/tri2/graph
steps/decode.sh --nj 24 --cmd "$decode_cmd" exp/VI_AUG/tri2/graph data_VI/test exp/VI_AUG/tri2/decode_test

steps/align_si.sh --nj 24 --cmd "$train_cmd" data_VI/train_aug data_VI/lang exp/VI_AUG/tri2 exp/VI_AUG/tri2_ali
steps/train_sat.sh --cmd "$train_cmd" 4200 40000 data_VI/train_aug data_VI/lang exp/VI_AUG/tri2_ali exp/VI_AUG/tri3
utils/mkgraph.sh data_VI/lang exp/VI_AUG/tri3 exp/VI_AUG/tri3/graph
steps/decode_fmllr.sh --nj 24 --cmd "$decode_cmd" exp/VI_AUG/tri3/graph data_VI/test exp/VI_AUG/tri3/decode_test


steps/cleanup/clean_and_segment_data.sh --nj 24 --cmd run.pl  --segmentation-opts "--min-segment-length 0.3 --min-new-segment-length 0.6"  data_VI/train_aug data_VI/lang exp/VI_AUG/tri3 exp/VI_AUG/tri3_cleaned data_VI/train_aug_cleaned

steps/align_si.sh --nj 24 --cmd "$train_cmd" data_VI/train_aug_cleaned data_VI/lang exp/VI_AUG/tri3 exp/VI_AUG/tri3_cleaned_ali
steps/train_sat.sh --cmd "$train_cmd" 4200 40000 data_VI/train_aug_cleaned data_VI/lang exp/VI_AUG/tri3_cleaned_ali exp/VI_AUG/tri3_cleaned_new
utils/mkgraph.sh data_VI/lang exp/VI_AUG/tri3_cleaned_new exp/VI_AUG/tri3_cleaned_new/graph
steps/align_si.sh --nj 24 --cmd "$train_cmd" data_VI/train_aug_cleaned data_VI/lang exp/VI_AUG/tri3_cleaned_new exp/VI_AUG/tri3_cleaned_new_ali
~                                                                                                                                                

