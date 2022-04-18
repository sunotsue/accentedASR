import os
import sys
import re
import argparse

from indic_transliteration import sanscript
from indic_transliteration.sanscript import transliterate

from google.transliteration import transliterate_text

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", help="downloads directory", type=str, default="downloads")
    args = parser.parse_args()

    with open(os.path.join(os.environ['ENGLISH'], 'line_index.tsv'), 'w', encoding='utf-8') as f:
        for file in os.listdir(args.d):
            if file.endswith(".txt"):
                path = os.path.join(args.d, file)
                with open(path, 'r') as fp:
                    fid = file[0:-4]
                    text = fp.read().strip()
                    text = re.sub('\.|,', '', text)
                    text = re.sub('\s+', ' ', text)
                    try:
                        text_transliterated = transliterate_text(text, lang_code='te')
                    except:
                        text_transliterated = transliterate(text, sanscript.ITRANS, sanscript.TELUGU)

                    f.write(fid + '\t' + text_transliterated + '\n')





