# based on http://mikepultz.com/2011/03/accessing-google-speech-api-chrome-11/
# needs pyaudio package http://people.csail.mit.edu/hubert/pyaudio/
# Linux based, sox commands to convert from way to flac format.

import pyaudio
import wave
import subprocess, shlex

CHUNK = 1024
FORMAT = pyaudio.paInt16
CHANNELS = 2
RATE = 44100
RECORD_SECONDS = 5
WAVE_OUTPUT_FILENAME = "output.wav"

p = pyaudio.PyAudio()

inputKey = ''
while inputKey != 'q':
    frames = []
    stream = p.open(format=FORMAT,
                    channels=CHANNELS,
                    rate=RATE,
                    input=True,
                    frames_per_buffer=CHUNK)
    print("* recording")

    for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        data = stream.read(CHUNK)
        frames.append(data)

    print("* done recording")

    stream.stop_stream()
    stream.close()
    # p.terminate()

    wf = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b''.join(frames))
    wf.close()

    # sox command
    commandLine = 'sox output.wav output.flac'
    args = shlex.split(commandLine)
    proc = subprocess.call(args)

    # google wget...
    commandLine = 'wget --post-file output.flac --header="Content-Type: audio/x-flac; rate=44100" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium"'
    args = shlex.split(commandLine)
    proc = subprocess.call(args)

    print 'want to record next sentence? press q to exit any other key to continue...', 
    inputKey = raw_input()

p.terminate()
