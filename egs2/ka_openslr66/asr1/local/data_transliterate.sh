#!/bin/bash

#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

#. ./path.sh || exit 1;
#. ./cmd.sh || exit 1;
#. ./db.sh || exit 1;

# general configuration
stage=0       # start from 0 if you need to start from data preparation
stop_stage=1
# inclusive, was 100
SECONDS=0

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

#mkdir -p "data/en" #${ENGLISH}
if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    log "sub-stage 0: Download Data to downloads"

    cd "data/en" #${ENGLISH}
    #gdown 'https://drive.google.com/uc?id=1foS5QODqzaotn6KaSEEdaCynh-PAccOg'

    #unzip -o datatang.zip

    #rm datatang.zip #done
    #mv 'Datatang-English/data/Indian English Speech Data' ./indian_english #done
    #rm -r Datatang-English #done
    #find indian_english -type f -iname "*.wav" -print0 | xargs -0 -J % mv % . #done
    #find indian_english -type f -iname "*.txt" -print0 | xargs -0 -J % mv % . #done

    #rm -r indian_english #done

    #for file in *; do
    #  mv -- "$file" "${file//S/_}"
    #done

    cd $workspace

    python3 local/data_prep_transliterate.py -d "data/en" #${ENGLISH}

    find english_data -name "*.txt" -print0 | xargs rm -r

fi

