# EEE4120F - YODA Project - JEDI - Golden Measure Decoding
# 19/05/2024

# Imports
from PIL import Image
import wave
from scipy.io import wavfile
import time
import numpy as np

def decoding(encoded_image, LSB_encoding_depth):
    #---------------------------------------------------------------------------------------------------------------------------------------- 
    # Input: encoded png image
    # Input: LSB_encoding_depth defines the amount of bits that are encoded in each RGB colour code
    # Output: A wav file containing the audio message
    #
    # This function will take in an encoded image (png) and the LSB encoding depth and will output the secret message (wav) 
    #------------------------------------------------------------------------------------------------------------------------------------------

    print("Starting decoding...")

    # Load the PNG image
    image = Image.open(encoded_image)
    
    # Get the size of the image
    width, height = image.size

    # Convert the image to RGB mode 
    image_rgb = image.convert("RGB")

    # Get pixel data of image
    pixels = image_rgb.load()

    # Convert RGB values to binary and store in a 2D array
    image_bitstream = ''
    for y in range(image.height):
        for x in range(image.width):
            r, g, b = pixels[x, y]
            binary_r = bin(r)[2:].zfill(8)  # Convert red value to binary with 8 bits
            binary_g = bin(g)[2:].zfill(8)  # Convert green value to binary with 8 bits
            binary_b = bin(b)[2:].zfill(8)  # Convert blue value to binary with 8 bits
            image_bitstream += binary_r + binary_g + binary_b


    # Find length of audio by extracting the first 24 bits
    audio_length_bitstream = ''
    # Calculate how many iterations through the image data are needed to extract the 24-bit audio length
    iterations = (24//LSB_encoding_depth)
    remainder = (24%LSB_encoding_depth)

    # Iterate through each byte of the image and extract the encoded bits
    start = 8
    for n in range(iterations):
        audio_length_bitstream += image_bitstream[start - LSB_encoding_depth : start]
        start = start + 8
    if remainder > 0:
        audio_length_bitstream += image_bitstream[ start - LSB_encoding_depth : start - (LSB_encoding_depth - remainder)]

    # Convert audio length from binary to decimal 
    audio_length = int(audio_length_bitstream, 2)

    # Cycle through the image and extract the secret audio until the number of extracted bits corresponds to the audio length
    decoded_audio_bitstream = ''
    iterations = ((audio_length + 24)//LSB_encoding_depth)
    remainder = ((audio_length + 24) %LSB_encoding_depth)
    start = 8
    for n in range(iterations):
        decoded_audio_bitstream += image_bitstream[start - LSB_encoding_depth : start]
        start = start + 8
    if remainder > 0:
        decoded_audio_bitstream += image_bitstream[ start - LSB_encoding_depth : start - (LSB_encoding_depth - remainder)]
        
    #Remove audio length from the decoded audio bitstream
    decoded_audio_bitstream = decoded_audio_bitstream[24:]

    #Convert audio back to wav file
    decoded_audio = []
    for i in range(0, len(decoded_audio_bitstream), 16):
        sample = decoded_audio_bitstream[i:i+16]
        decoded_audio.append(int(sample, 2) - 2**15)
    decoded_audio_data = np.array(decoded_audio, dtype = np.int16)
    output_file = "Decoded_Audio.wav"  # Specify the output file name
    wavfile.write(output_file, 44100, decoded_audio_data)

    print("Done!")
    return decoded_audio_bitstream


# Call the function
encImage = "./Encoded_Image.png"
LSB_encoding_depth = 2
decoding(encImage, LSB_encoding_depth)