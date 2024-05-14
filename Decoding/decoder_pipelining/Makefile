# Define the Icarus Verilog compiler
IV = iverilog
# Define the Icarus Verilog runtime
VVP = vvp
# Define the flags for the Icarus Verilog compiler. In this case, enable SystemVerilog features
IVFLAGS = -g2005-sv
# Define the output file for the Icarilog Verilog compiler
OUTFILE = output

# Define your source files
SRC = decoder.v decoder_tb.v

all: compile run

compile:
	$(IV) $(IVFLAGS) -o $(OUTFILE) $(SRC)

run:
	$(VVP) $(OUTFILE)

clean:
	rm $(OUTFILE)