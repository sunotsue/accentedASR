import glob
import os

# 2nd try

#os.mkdir('line_index.tsv')
file1 = open('line_index.tsv','w')
file1.close()

entire_folders = [f.path for f in os.scandir('telugu_txt')]
#print(entire_folders)

for i in entire_folders:
    #print('dir',i)
    #/Users/yerin/accentedASR/egs2/ka_openslr79/telugu_txt/G0
    idx = i.split('telugu_txt/')[1]
    #print('idx',idx)

    speaker = idx.split('S')[0]
    utter = idx.split('S')[1][:-4]
    print('utter_speaker',utter,speaker)
    
    #with open(i,'r') as file:
    #    data = file.read()
    data = open(i,'r').read()
    file1 = open('line_index.tsv','a')
    file1.writelines(speaker + 'S' + utter + '\t' + data + '\n')
    file1.close()

   
