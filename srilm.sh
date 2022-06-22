export KALDI_ROOT=/home/uniphore/Software/kaldi-master
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/src/fstbin/:$KALDI_ROOT/src/nnet3bin:$KALDI_ROOT/src/gmmbin/:$KALDI_ROOT/src/featbin/:$KALDI_ROOT/src/lm/:$KALDI_ROOT/src/sgmmbin/:$KALDI_ROOT/src/sgmm2bin/:$KALDI_ROOT/src/fgmmbin/:$KALDI_ROOT/src/latbin/:$KALDI_ROOT/src/nnetbin:$KALDI_ROOT/src/nnet2bin/:$KALDI_ROOT/src/kwsbin:$KALDI_ROOT/src/online2bin/:$KALDI_ROOT/src/ivectorbin/:$KALDI_ROOT/src/lmbin/:$PWD:$PATH
#export IRSTLM=/home/uniphore/Software/kaldi-master/tools/irstlm-5.80.08
#export PATH=$PATH:$KALDI_ROOT/tools/irstlm-5.80.08/bin
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
export MKL_NUM_THREADS=16
export LD_LIBRARY_PATH=/usr/bin/gcc-4.8/
export SRILM=/home/uniphore/Software/kaldi-master/tools/srilm-1.7.2
export PYTHONPATH=/usr/local/lib/python2.7/site-packages
export PATH=$SRILM/bin/i686-m64
export PATH=$SRILM/bin
export MANPATH=$SRILM/man

#/speech1/software/GCC/install/gmp/lib:/speech1/software/GCC/install/mpfr/lib:/speech1/software/GCC/install/mpc/lib:/speech1/software/GCC/install/gcc-4.7.3/lib:/speech1/software/GCC/install/gcc-4.7.3/lib64:/speech1/software/kaldi-trunk/tools/openfst/lib:
