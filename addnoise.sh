. ./path.sh

steps/data/make_musan.sh --use-vocals true --sampling-rate 8000 musan data_VI
#/home/karthikpandia/vietnamese_training/appen_stereo/musan data

  # Get the duration of the MUSAN recordings.  This will be used by the
  # script augment_data_dir.py.
  for name in speech noise music; do
    utils/data/get_utt2dur.sh data_VI/musan_${name}
    mv data_VI/musan_${name}/utt2dur data_VI/musan_${name}/reco2dur
  done
  utils/data/get_reco2dur.sh data_VI/train
  # Augment with musan_noise
  steps/data/augment_data_dir.py --utt-suffix "noise" --fg-interval 1 --fg-snrs "15:10:5:0" --fg-noise-dir "data_VI/musan_noise" data_VI/train data_VI/train_noise
  # Augment with musan_music
  steps/data/augment_data_dir.py --utt-suffix "music" --bg-snrs "15:10:8:5" --num-bg-noises "1" --bg-noise-dir "data_VI/musan_music" data_VI/train data_VI/train_music
  # Augment with musan_speech
  steps/data/augment_data_dir.py --utt-suffix "babble" --bg-snrs "20:17:15:13" --num-bg-noises "3:4:5:6:7" --bg-noise-dir "data_VI/musan_speech" data_VI/train data_VI/train_babble



foreground_snrs="20:10:15:5:0"
background_snrs="20:10:15:5:0"
num_data_reps=4


  # This is the config for the system using simulated RIRs and point-source noises
  rvb_opts+=(--rir-set-parameters "0.5, RIRS_NOISES/simulated_rirs/smallroom/rir_list")
  rvb_opts+=(--rir-set-parameters "0.5, RIRS_NOISES/simulated_rirs/mediumroom/rir_list")
  #rvb_opts+=(--noise-set-parameters $noise_list)

  steps/data/reverberate_data_dir.py \
    "${rvb_opts[@]}" \
    --prefix "rev" \
    --foreground-snrs $foreground_snrs \
    --background-snrs $background_snrs \
    --speech-rvb-probability 1 \
    --pointsource-noise-addition-probability 1 \
    --isotropic-noise-addition-probability 1 \
    --num-replications $num_data_reps \
    --max-noises-per-minute 1 \
    --source-sampling-rate 8000 \
    data_VI/train data_VI/train_rvb

utils/combine_data.sh data_VI/train_aug data_VI/train_rvb data_VI/train_noise data_VI/train_music data_VI/train_babble
