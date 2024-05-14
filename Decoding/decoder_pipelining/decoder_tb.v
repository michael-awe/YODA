// Test bench simulator for YODA decoder
// 2 bytes stored, metadata tells us that
// set simulation time:
`timescale 1ns/1ps

module decoder_tb;
    parameter CLK_PERIOD = 10; 
    reg clk;
    reg rd;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire done;
    wire sending;
    reg reset;
    reg received;
    wire reading;
 
    integer file;

    //Instantiate decoder module
    decoder dec (
        .clk(clk),
        .rd(rd),
        .data_in(data_in),
        .data_out(data_out),
        .done(done),
        .sending(sending),
        .reset(reset),
        .received(received),
        .reading(reading)
    );

    reg [31:0] fdata_out;
    reg [31:0] fdata_in;
    integer i = 0; //index for reading in data from txt
    integer status = 0;

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Clock generation
    initial begin         
        // setting up waveform simulation:
        $dumpfile("waveform.vcd");
        $dumpvars(0, decoder_tb);

        $display("Starting...");

        // opening file in read mode:
        fdata_in = $fopen("encoded_bitstream.txt", "r");
        #5;

        // Check if file opened successfully
        if (fdata_in == 0) begin
            $display("Error opening file");
            $finish;
        end

        #5;

        // opening file in write mode:
        fdata_out = $fopen("data_out.txt", "w");
        clk=0;
    end

    always @(posedge clk) begin
        if(done != 1) begin
            $display("reading file...");
            rd = 0;
            status = $fscanf(fdata_in, "%b", data_in);

            // Check if read was successful
            if (status == 0) begin
                $display("Error reading from file");
                $finish;
            end

            $display("Data in: %b", data_in);
            i=i+1;
            rd = 1;
            wait(reading);
        end
    end
      always @(posedge clk) begin
        received <= 0;
        //writing output data to txt
        if (done == 0 && sending == 1) begin
            $fwrite(fdata_out, "%b\n", data_out);
            $display("Data out: %b\n",data_out);
            received <= 1;
            end

        if (done == 1) begin
            // close the output file
            $display("Done.");
            $fclose(fdata_out);
            $fclose(fdata_in);
            $finish;
        end
    end

    
endmodule
