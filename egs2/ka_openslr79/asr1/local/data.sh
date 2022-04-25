#!/bin/bash

# 2nd try

#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

# general configuration da
stage=0       # start from 0 if you need to start from data preparation
stop_stage=1
# inclusive, was 100
SECONDS=0

lang=en

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}


# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

. utils/parse_options.sh

log "data preparation started"

workspace=$PWD

: '
if [ ${lang} == "kn" ]; then
  mkdir -p ${KANNADA}
  if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
      log "sub-stage 0: Download Data to downloads"

     cd ${KANNADA}
      wget https://us.openslr.org/resources/79/kn_in_female.zip
      wget https://us.openslr.org/resources/79/kn_in_male.zip

      unzip -o kn_in_female.zip
      unzip -o kn_in_male.zip

      rm kn_in_female.zip
      rm kn_in_male.zip

      cat kn_in_female/line_index.tsv kn_in_male/line_index.tsv > kn_index.tsv

      cd $workspace
  fi
else
  #mkdir -p ${ENGLISH}
  #if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
  #    log "sub-stage 0: Download Data to downloads"

  #    cd ${ENGLISH}
  #    gdown https://drive.google.com/uc?id=1C8DmfXaVQgtNX3KHfsYDV3rha7
  #    gdown https://drive.google.com/uc?id=15kQYoRJagknTP56FDSNW5iyG6RCFS31K

  #    unzip -o english_kannada.zip
  #    cd $workspace
  pass
  fi

fi
'

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    log "sub-stage 1: Preparing Data for openslr"

    if [ ${lang} == "te" ]; then
      python3 local/data_prep.py -d ${TELUGU}
    else
      python3 local/data_prep.py -d 'data/en' ${ENGLISH}
    fi
    utils/spk2utt_to_utt2spk.pl data/${lang}_train/spk2utt > data/${lang}_train/utt2spk
    utils/spk2utt_to_utt2spk.pl data/${lang}_dev/spk2utt > data/${lang}_dev/utt2spk
    utils/spk2utt_to_utt2spk.pl data/${lang}_test/spk2utt > data/${lang}_test/utt2spk
    utils/fix_data_dir.sh data/${lang}_train
    utils/fix_data_dir.sh data/${lang}_dev
    utils/fix_data_dir.sh data/${lang}_test
fi

log "Successfully finished. [elapsed=${SECONDS}s]"