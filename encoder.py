from PIL import Image
import wave
from scipy.io import wavfile
import time

def get_audio_bits(filename):
    
    # Audio Processing -----------------------------------------------------------------------------------------------------------------------------
    # -> Outputs audio_bitstream
    # Audio_bitstream has the audio in binary and 16-bit depth
    # Open the WAV file

    t_audio0 = time.time()

    wav_file = wave.open("./obiwan.wav", "r")

    # Get the file properties
    num_channels = wav_file.getnchannels()
    sample_width = wav_file.getsampwidth()
    sample_rate = wav_file.getframerate()
    num_frames = wav_file.getnframes()
    duration = num_frames / sample_rate  # Calculate the duration in seconds

    print("Sample rate: ", sample_rate)

    wav_file.close()

    samplerate, data = wavfile.read('./obiwan.wav')

    # Convert audio to single channel
    if num_channels != 1:
        data = data[:, 0]

    # Shift all data samples up by 2^15 to make all samples positive
    data = data + 2**15

    # Writes single channel audio to new file
    # wavfile.write('./obiwan_single_channel.wav', samplerate, data)

    # Convert data to a bitstream 
    audio_bitstream = ""
    for sample in data:
        audio_bitstream += format(sample, '016b')

    # Print audio bitstream
    print("Audio Bit stream:")
    print(audio_bitstream[:50])  
    #print("Total number of audio bits:", len(bitstream))

    # Saves the encoded bit stream to a file
    with open("audio_bitstream.txt", "w") as file:
        for i in range(0, len(audio_bitstream), 8):
            byte = audio_bitstream[i:i+8]  # Extracting 8 bits (1 byte)
            file.write(byte + "\n")

    # Get length of audio_bitstream
    audio_length = len(audio_bitstream)
    audio_length_binary = format(audio_length, '024b')
    print("length of audio", audio_length)
    print("length of audio in binary", audio_length_binary)

    # Attach audio length to the audio bitstream
    a_bitstream = audio_bitstream
    audio_bitstream = audio_length_binary + audio_bitstream

    return audio_bitstream, a_bitstream