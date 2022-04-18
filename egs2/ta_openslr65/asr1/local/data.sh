#!/bin/bash

#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

# general configuration
stage=0       # start from 0 if you need to start from data preparation
stop_stage=1
# inclusive, was 100
SECONDS=0

lang=ta

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

if [ ${lang} == "ta" ]; then
  mkdir -p data/ta
  if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
      log "sub-stage 0: Download Data to downloads"

      cd data/ta
      wget https://us.openslr.org/resources/65/ta_in_female.zip
      wget https://us.openslr.org/resources/65/ta_in_male.zip

      unzip -o ta_in_female.zip
      unzip -o ta_in_male.zip

      rm ta_in_female.zip
      rm ta_in_male.zip

      cat ta_in_female/line_index.tsv ta_in_male/line_index.tsv > ta_index.tsv

      cd $workspace
  fi
else
  mkdir -p data/en
  if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
      log "sub-stage 0: Download Data to downloads"

      cd data/en
      gdown 'https://drive.google.com/uc?id=1foS5QODqzaotn6KaSEEdaCynh-PAccOg'

      unzip -o english_tamil.zip
      cd $workspace
  fi

fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    log "sub-stage 1: Preparing Data for openslr"

    if [ ${lang} == "ta" ]; then
      python3 local/data_prep.py -d data/ta
    else
      python3 local/data_prep.py -d data/en
    fi
    utils/spk2utt_to_utt2spk.pl data/${lang}_train/spk2utt > data/${lang}_train/utt2spk
    utils/spk2utt_to_utt2spk.pl data/${lang}_dev/spk2utt > data/${lang}_dev/utt2spk
    utils/spk2utt_to_utt2spk.pl data/${lang}_test/spk2utt > data/${lang}_test/utt2spk
    utils/fix_data_dir.sh data/${lang}_train
    utils/fix_data_dir.sh data/${lang}_dev
    utils/fix_data_dir.sh data/${lang}_test
fi

log "Successfully finished. [elapsed=${SECONDS}s]"