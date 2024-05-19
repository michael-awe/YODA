// Decoder Version 1: Sequential 
// Test bench simulator for YODA decoder
// 2 bytes stored, metadata tells us that
// set simulation time:
`timescale 1ns/1ps

module decoder_tb;
    parameter CLK_PERIOD = 10; 
    reg clk;
    reg rd;
    wire dn; 
    reg [7:0] dat_in;
    wire [7:0] dat_out;
    reg sent;
    wire finish;
    wire wt;
    integer file;
    wire id;

    //Instantiate decoder module
    decoder dec (
        .clk(clk),
        .rd(rd),
        .dn(dn),
        .dat_in(dat_in),
        .dat_out(dat_out),
        .finish(finish),
        .wt(wt),
        .sent(sent),
        .id(id)
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
        fdata_in = $fopen("data_in.txt", "r");
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
        if((dn == 0)&&(id==0)) begin
            sent = 0;
            rd=0;
            status = $fscanf(fdata_in, "%b", dat_in);

            // Check if read was successful
            if (status == 0) begin
                $display("Error reading from file");
                $finish;
            end

            $display("Data in: %b", dat_in);
            i=i+1;
            rd = 1;
            wait(wt);
            rd = 0;
        end
        else begin
            //writing output data to txt
            if ((dn == 1)&&(finish == 0)) begin
                sent = 0;
                $fwrite(fdata_out, "%b\n", dat_out);
                $display("Data out: %b",dat_out);
                sent = 1;
                end

            else if ((dn == 1)&&(finish == 1)) begin
                // close the output file
                $display("Done.");
                $fclose(fdata_out);
                $fclose(fdata_in);
                $finish;
            end
            end
        end
    
endmodule
