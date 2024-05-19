// Decoder Testbench Version 1: Sequential Implementation
`timescale 1ns/1ps
module decoder (clk, rd, dat_in, dat_out, dn, finish, wt, sent, id);
    input clk;
    input rd; //start READ state, from tb
    input [7:0] dat_in; //read in 1 byte at a time
    input sent; //controller command to start read mode

    reg[7:0] buffer [3:0]; //to store data_in bits
    reg[7:0] ext; //to store extracted bits
    reg[7:0] tail = 0; //tail pointer for buffer
    // reg[7:0] size_of_data = 3; //how much information stored in image, where to stop. Hardcoded for now
    reg[24:0] done_bytes = 0; //how much data has been extracted already
    
    reg[24:0] size_of_data = 0; //size of data in bits to be extracted
    reg[7:0] counter = 0; //counter for size_of_data

    reg[1:0] state; //current state

    output reg [7:0] dat_out; //send out 1 byte at a time
    output reg dn = 0; //done decoding, ready to start outputting data
    output reg finish = 0; //finished writing data to output txt file
    output reg wt; //wait for decoder to get data
    output reg id = 0; //testbench must only be reading from txt file when this is low

    //states
    parameter [1:0] IDLE = 2'b00; //idle mode
    parameter [1:0] READ = 2'b01; //read mode
    parameter [1:0] PROCESS = 2'b10; //process mode
    parameter [1:0] SEND = 2'b11; //send mode

    always @ (posedge clk) begin
        case(state) 
            IDLE: begin
                dn = 0;
                id = 0;
                if (rd) state <= READ; 
                wt = 0;
            end

            READ: begin
                    id = 0;
                    wt = 0;
                    // read in latest data in value
                    buffer[tail] = dat_in;
                    $display("Data in decoder mod buffer[%b]: %b", tail, buffer[tail]);
                    tail = (tail + 1); 
                    wt=1;
                    #10;
 
                   if ((rd==0)&&(tail<=3)) begin
                        state = IDLE;
                    end
                    else if (tail == 4) begin //all 4 bytes received, now extract audio in PROCESS
                        state = PROCESS;
                    end
                end

            PROCESS: begin //extracting audio data from data_in 
                tail = 0;
                id = 1;
                case (counter)
                    0: size_of_data[23:16] = { buffer[0][1:0], buffer[1][1:0], buffer[2][1:0], buffer[3][1:0] };
                    1: size_of_data[15:8] = { buffer[0][1:0], buffer[1][1:0], buffer[2][1:0], buffer[3][1:0] };
                    2: size_of_data[7:0] = { buffer[0][1:0], buffer[1][1:0], buffer[2][1:0], buffer[3][1:0] };
                    default: begin
                        ext = { buffer[0][1:0], buffer[1][1:0], buffer[2][1:0], buffer[3][1:0] };
                        state = SEND;
                        //$display("Processing done.");
                    end
                endcase
                
                if (counter < 3) begin
                    counter = counter + 1;
                    $display("Total length of input @ counter=%d: %b, in bytes=%d", counter, size_of_data, size_of_data/8);
                    state <= IDLE;
                end 
                
            end

            SEND: begin
                id = 1; //tell tb to stop reading new data, but wait to receive dat out
                dn = 0;
                dat_out = ext;
                tail = 0;
                done_bytes = done_bytes + 1; //incrementing count of audio bytes extracted
                dn = 1;
                #10;

                //all bytes extracted:
                 if (done_bytes == size_of_data/8) begin
                    wait(sent);
                    finish = 1;
                end
                else if (done_bytes < size_of_data/8) begin
                    finish = 0;
                    state = IDLE;
                end
                #10;

            end

            default: state <= IDLE;

        endcase
    end

endmodule
