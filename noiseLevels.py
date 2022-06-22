import sys
import audioop
try:
    import pyaudio
except ImportError:
    sys.exit('You need to install pyaudio to installed to run this demo.')

SAMPLING_RATE = 22050
NUM_SAMPLES = 1024
line = None
_stream = None

def getRMS():
    global _stream
    if _stream is None:
        pa = pyaudio.PyAudio()
        _stream = pa.open(format=pyaudio.paInt16, channels=2, rate=SAMPLING_RATE,
                          input=True, frames_per_buffer=NUM_SAMPLES)
    try:
        data = _stream.read(NUM_SAMPLES)
        audio_data = array('i', data)
        rms = audioop.rms(audio_data, 2)
        return rms
    except Exception, e:
        # print 'Exception occurred %s' % traceback.format_exc(e)
        return -1

if __name__ == "__main__":
    while True:
        getRMS()
