Some useful info:
1. Code is done in a Jupyter notebook because it seems to run better.
2. The audio_bitstream.txt has the audio bitstream with each byte on a newline. This txt file only contains the audio_bitstream.
3. The encoded_bitstream.txt has the encoded image information with each byte on a newline.
4. The encoded_bitstream has the length of the audio stored in the last two LSBs of the of the RGB codes for the first 4 pixels. This will give 24-bits to represent the length of the audio. 
