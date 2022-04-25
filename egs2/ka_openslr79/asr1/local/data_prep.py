import argparse
import os
import random
import re

# 2nd try


def preprocess(text):
    text = re.sub(r'\n', '', text.strip())
    text = re.sub('[.,\/#!$%\^&\*;:{}=\-_`~()]', '', text)
    return text.strip()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", help="downloads directory", type=str, default="downloads")
    args = parser.parse_args()

    tsv_path = "/home/ubuntu/accentedASR/egs2/ka_openslr79/line_index.tsv"
    #tsv_path = "%s/line_index.tsv" % args.d

    with open(tsv_path, "r") as inf:
        tsv_lines = inf.readlines()
    tsv_lines = [line.strip() for line in tsv_lines]
    #sdf
    spk2utt = {}
    utt2text = {}
    for line in tsv_lines:
        l_list = line.split("\t")
        fid = l_list[0].split('S')[1]
        #print("FID  ",fid)
        spk = l_list[0].split('S')[0]
        #print("SPK  ",spk)
        text = l_list[1]
        path = "/home/ubuntu/accentedASR/egs2/ka_openslr79/asr1/data/en/%s%s.wav" % ('G'+spk,fid)
        print(path)
        if os.path.exists(path):
            utt2text[fid] = text
            if spk in spk2utt:
                spk2utt[spk].append(fid)
            else:
                spk2utt[spk] = [fid]

    spks = sorted(list(spk2utt.keys()))
    print(spks)
    num_fids = 0
    num_test_spks = 0
    for spk in spks:
        num_test_spks += 1
        fids = sorted(list(set(spk2utt[spk])))
        num_fids += len(fids)
        if num_fids >= 500:
            break

    test_spks = spks[:num_test_spks]
    train_dev_spks = spks[num_test_spks:]
    random.Random(0).shuffle(train_dev_spks)
    num_train = int(len(train_dev_spks) * 0.9)
    train_spks = train_dev_spks[:num_train]
    dev_spks = train_dev_spks[num_train:]

    spks_by_phase = {"train": train_spks, "dev": dev_spks, "test": test_spks}
    flac_dir = "/home/ubuntu/accentedASR/egs2/ka_openslr79/asr1/data/en/" #% args.d
    sr = 16000
    for phase in spks_by_phase:
        spks = spks_by_phase[phase]
        text_strs = []
        wav_scp_strs = []
        spk2utt_strs = []
        num_fids = 0
        for spk in spks:
            fids = sorted(list(set(spk2utt[spk])))
            num_fids += len(fids)
            if phase == "test" and num_fids > 2000:
                curr_num_fids = num_fids - 2000
                random.Random(1).shuffle(fids)
                fids = fids[:curr_num_fids]
            utts = [spk + "-" + f for f in fids]
            utts_str = " ".join(utts)
            spk2utt_strs.append("%s %s" % (spk, utts_str))
            for fid, utt in zip(fids, utts):
                cmd = "ffmpeg -i %s/%s.wav -f wav -ar %d -ab 16 -ac 1 - |" % (
                    flac_dir,
                    fid,
                    sr,
                )
                text = preprocess(utt2text[fid])
                text_strs.append("%s %s" % (utt, text))
                wav_scp_strs.append("%s %s" % (utt, cmd))
        phase_dir = "data/en_%s" % phase
        os.makedirs(phase_dir)
        text_strs = sorted(text_strs)
        wav_scp_strs = sorted(wav_scp_strs)
        spk2utt_strs = sorted(spk2utt_strs)
        with open(os.path.join(phase_dir, "text"), "w+") as ouf:
            for s in text_strs:
                ouf.write("%s\n" % s)
        with open(os.path.join(phase_dir, "wav.scp"), "w+") as ouf:
            for s in wav_scp_strs:
                ouf.write("%s\n" % s)
        with open(os.path.join(phase_dir, "spk2utt"), "w+") as ouf:
            for s in spk2utt_strs:
                ouf.write("%s\n" % s)
