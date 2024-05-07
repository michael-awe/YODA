# JEDI: Just Extracting Data Inconspicuously (Steganography Decoder)

This repository contains the code for a steganography decoder implemented in Verilog. The decoder module (`decoder.v`) takes in image data sent over an 8-bit buffer and extracts the hidden audio file. The functionality of the decoder is verified using the testbench module (`decoder_tb.v`), which reads the provided input text file and streams the data to the decoder module for simulation.

## Verilog Modules

### decoder.v

The `decoder.v` module is responsible for decoding the steganography data. It takes in image data sent over an 8-bit buffer and extracts the hidden audio file. The module is designed to be integrated into a larger system for steganography decoding.

### decoder_tb.v

The `decoder_tb.v` module is a testbench used to verify the functionality of the `decoder.v` module. It reads the provided input text file and streams the data to the `decoder.v` module for simulation. The testbench module helps ensure that the decoder module is working correctly.

## Python Notebook

The `data_verification.ipynb` Python notebook is provided to verify the functionality of the Verilog modules. 

### Example Process

It performs the following steps:
1. Checks the provided image.
2. Decodes the image using the make tools and iverilog.
3. Plays the output audio file.
4. Verifies the output with the expected output line-by-line to ensure the correct functioning of the module.

### Additional Script

An additional script is included in this repository to check the output of the decoder module with the expected output line-by-line. This script helps verify the correct functioning of the module.
