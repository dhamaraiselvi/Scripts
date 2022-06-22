from pydub import AudioSegment

from pydub.utils import make_chunks

import glob


filenames=glob.glob('*/home/armuser/hdd1/dataset/gram-vaani-asr-2022/GV_1000_Part1/Gramvaani_1000hrData_Part1/*/*.wav', recursive=True) # wav files contains in subfolder

dest_path='/home/armuser/hdd1/dataset/gram-vaani-asr-2022/GV_1000_Part1/Gramvaani_1000hrData_Part1/Audio/chunked'



#print(filenames)

for filename in filenames:

    myaudio = AudioSegment.from_file (filename, "wav") 

    chunk_length_ms = 30000 # pydub calculates in millisec

    chunks = make_chunks(myaudio, chunk_length_ms) #Make chunks of one sec

    l=filename.split('\\')

    filename=l[-1][:-4]



    #Export all of the individual chunks as wav files


    for i, chunk in enumerate(chunks):

        chunk_name = "chunk{0}.wav".format(i)

        chunk_name=filename+'_' +chunk_name

        print("exporting", chunk_name)

        chunk.export(chunk_name, format="wav")              
