# EEE4120F - YODA Project - JEDI - Encoding
# 19/05/2024

# Imports
from PIL import Image
import wave
from scipy.io import wavfile
import time

def encoding(audio,png, LSB_encoding_depth):
    #---------------------------------------------------------------------------------------------------------------------------------------- 
    # Input: audio contains the wav file
    # Input: png contains the image
    # Input: LSB_encoding_depth defines the amount of bits that should be encoded in each RGB colour code
    # Output: A png image that is encoded with the secret message
    #
    # This function will take in an audio (wav) and image (png) and will encode the audio message within the image data using stenography. 
    #------------------------------------------------------------------------------------------------------------------------------------------

    print("Starting encoding...")
    # Open the wav file
    wav_file = wave.open(audio) 
    
    # Get the file properties
    num_channels = wav_file.getnchannels()
    sample_width = wav_file.getsampwidth()
    sample_rate = wav_file.getframerate()
    num_frames = wav_file.getnframes()
    duration = num_frames / sample_rate  

    # Close the file
    wav_file.close()

    # Open the wav file using wavfile
    samplerate, data = wavfile.read(audio)
    
    # Convert audio to single channel
    if num_channels != 1:
        data = data[:, 0]
    
    # Shift all data samples up by 2^15 to make all samples positive
    data = data + 2**15
    
    # Convert data to a bitstream 
    audio_bitstream = ""
    for sample in data:
        audio_bitstream += format(sample, '016b')

    # Uncomment this to produce a txt file containing the original audio bitstream
    # Saves the encoded bit stream to a file
    #with open("OriginalAudioBitstream.txt", "w") as file:
    #    for i in range(0, len(audio_bitstream), 8):
    #        byte = audio_bitstream[i:i+8]  # Extracting 8 bits (1 byte)
    #        file.write(byte + "\n")
    
    # Get length of audio_bitstream
    audio_length = len(audio_bitstream)
    audio_length_binary = format(audio_length, '024b')
    
    # Attach audio length to the audio bitstream
    a_bitstream = audio_bitstream
    audio_bitstream = audio_length_binary + audio_bitstream

    
    # Begin Image processing 
    # Load the PNG image
    image = Image.open(png)
    
    # Get the size of the image
    width, height = image.size
    
    # Checks image to ensure correct size
    if width != 1000 or height != 1000:       
        print("Wrong image size!")
        print("Please try again.")
        exit()
    else:
        # Convert the image to RGB mode 
        image_rgb = image.convert("RGB")
    
        # Get pixel data of image
        pixels = image_rgb.load()
    
        # Convert RGB values to binary and store in a 2D array
        binary_pixels = []
        for y in range(image.height):
            row = []
            for x in range(image.width):
                r, g, b = pixels[x, y]
                binary_r = bin(r)[2:].zfill(8)  # Convert red value to binary with 8 bits
                binary_g = bin(g)[2:].zfill(8)  # Convert green value to binary with 8 bits
                binary_b = bin(b)[2:].zfill(8)  # Convert blue value to binary with 8 bits
                row.append((binary_r, binary_g, binary_b))
            binary_pixels.append(row)

    
    # Begin encoding process 
    encoded_golden_measure = Image.new("RGB", (width, height))
    # Convert binary pixel data back to image and encode the image simultaneously
    encoded_pixels = encoded_golden_measure.load()
    
    # Initialise variables to store the continuous bit stream
    encoded_bitstream = "" # Will contain the encoded image bitstream for sending
    stream_index = 0

    # Iterates through each pixel in the image
    for y in range(image.height):
        row = []
        for x in range(image.width):
            # Get the RGB values of the current pixel
            binary_r, binary_g, binary_b = binary_pixels[y][x]
            # Modifies last two digits of each color component if audio stream has bits left
            if stream_index < len(audio_bitstream) - LSB_encoding_depth:
                r = binary_r[:-LSB_encoding_depth]
                for n in range(LSB_encoding_depth):
                    r += audio_bitstream[stream_index + n]
                stream_index += LSB_encoding_depth
            else:
                r = binary_r
                
            if stream_index < len(audio_bitstream) -  LSB_encoding_depth:
                g = binary_g[:-LSB_encoding_depth]
                for n in range(LSB_encoding_depth):
                    g += audio_bitstream[stream_index + n]
                stream_index += LSB_encoding_depth
            else:
                g = binary_g
                
            if stream_index < len(audio_bitstream) -  LSB_encoding_depth:
                b = binary_b[:-LSB_encoding_depth]
                for n in range(LSB_encoding_depth):
                    b += audio_bitstream[stream_index + n]
                stream_index += LSB_encoding_depth
            else:
                b = binary_b
    
            # Store modified RGB values in the encoded array
            row.append((r, g, b))
    
            # Append the modified bits to the continuous bit stream
            encoded_bitstream += r + g + b
    
            # Convert binary RGB values back to integer
            r_int = int(r, 2)
            g_int = int(g, 2)
            b_int = int(b, 2)
            
            # Set pixel value in the new image
            encoded_pixels[x, y] = (r_int, g_int, b_int)

    # Uncomment this to produce an txt file containing the encoded image bitstream 
    # Saves the encoded bit stream to a file
    #with open("EncodedImageBitstream.txt", "w") as file:
    #    for i in range(0, len(encoded_bitstream), 8):
    #        byte = encoded_bitstream[i:i+8]  # Extracting 8 bits (1 byte)
    #        file.write(byte + "\n")

    # Save the encoded image
    encoded_golden_measure.save("Encoded_Image.png")  
    print("Done!")
    return encoded_bitstream


# Call the encoding function with the image and audio
audio = "./obiwan.wav"
image = "./babyyoda.png"
LSB_encoding_depth = 2
encoding(audio, image, LSB_encoding_depth)