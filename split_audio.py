#Importing library and thir function
from pydub import AudioSegment
from pydub.silence import split_on_silence
from glob import glob
import os
#reading from audio wav file
wav_files = glob("*.wav")
for wav_file in wav_files:
   folder_name = wav_file.split(".wav")[0]
   print(wav_file, folder_name)
   try:
      os.mkdir(folder_name)
   except:
      pass



   sound = AudioSegment.from_wav(wav_file)
   # spliting audio files
   audio_chunks = split_on_silence(sound, min_silence_len=2500, silence_thresh=-50, keep_silence=500)

   #loop is used to iterate over the output list
   for i, chunk in enumerate(audio_chunks):
      output_file = folder_name+"/chunk{0}.wav".format(i)
      print("Exporting file", output_file)
      chunk.export(output_file, format="wav")

   # chunk files saved as Output
