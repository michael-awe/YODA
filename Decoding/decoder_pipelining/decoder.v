module decoder (clk, reset, data_in, data_out, sending, done, rd, received, reading);
    input clk;
    // variables for reading data
    input [7:0] data_in;             // Input data: read in 1 byte at a time
    input rd;
    input reset;
    reg [7:0] buffer [0:255];       // Circular Buffer for storing processed data
    reg [7:0] head = 0;             // Position to read from
    reg [7:0] tail = 0;             // Position to write to
    reg [1:0] read_index = 2'b00;   // index for tracking pos of data in processing
    
    // variables for keeping count of data & metadata
    reg[24:0] size_of_data = 0;     // size of data in bits to be extracted
    reg[24:0] processed_count = 0;  // number of bytes read in
    reg[24:0] sent_count = 0;       // number of bytes sent
    output reg done = 0;
    output reg reading = 0;

    // states
    parameter IDLE = 1'b0;       // IDLE mode for both processes
    parameter ACTIVE = 1'b1;     // ACTIVE mode for both processes
    reg read_state = 0;
    reg send_state = 0;

    // variables for sending data
    output reg [7:0] data_out;
    output reg sending;
    input wire received;



    // READ PROCESS
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tail <= 0;
        end else begin
            
            case (read_state)
                IDLE: begin
                    // TODO: check this code, copied from manual version
                    if (rd) read_state <= ACTIVE; 
                end
                ACTIVE: begin
                    // since it will take 12 input bytes to store 
                    // the total size of data, we have to manually
                    // declare the reading of these bits
                    reading = 1;
                    case (processed_count)
                        // reading metadata (total length of data message)
                        0: size_of_data[23:22] = data_in[1:0];
                        1: size_of_data[21:20] = data_in[1:0];
                        2: size_of_data[19:18] = data_in[1:0];
                        3: size_of_data[17:16] = data_in[1:0];
                        4: size_of_data[15:14] = data_in[1:0];
                        5: size_of_data[13:12] = data_in[1:0];
                        6: size_of_data[11:10] = data_in[1:0];
                        7: size_of_data[9:8] = data_in[1:0];
                        8: size_of_data[7:6] = data_in[1:0];
                        9: size_of_data[5:4] = data_in[1:0];
                        10: size_of_data[3:2] = data_in[1:0];
                        11: size_of_data[1:0] = data_in[1:0];
                        // reading in actual data values
                        // TODO: possibly add XOR logic
                        default: begin
                            $display("data in data_in: %b", data_in[1:0]);

                            case(read_index)
                                2'd0: buffer[tail][7:6] <= data_in[1:0];
                                2'd1: buffer[tail][5:4] <= data_in[1:0];
                                2'd2: buffer[tail][3:2] <= data_in[1:0];
                                2'd3: begin
                                    buffer[tail][1:0] = data_in[1:0];
                                    $display("data in buffer at tail: %b", buffer[tail]);
                                    tail = (tail + 1); // note the use of 256-bit overflow
                                    

                                    // TODO: add in wait condition if tail catches up to head
                                end
                                default: ; // Do nothing
                            endcase
                            read_index = (read_index + 1); // note the use of 2-bit overflow
                            // $display("Data in decoder mod buffer[%b]: %b", tail, buffer[tail]);
                        end
                        
                    endcase
                    processed_count <= processed_count + 1;
                end
                    default: begin
                        reading = 0;
                        read_state <= ACTIVE; 
                    end
            endcase


        end
    end

    // SEND PROCESS
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            head <= 0;
            sending <= 0;
            send_state <= IDLE;
        end else if(head != tail) begin
            case (send_state)
            IDLE: begin
                sending = 0;
                if (processed_count >= 11 && !done) begin
                    send_state <= ACTIVE; 
                end
            end
            ACTIVE: begin
                
                // display buffer[head]

                $display("Data out (decoder) buffer[%b]: %b", head, buffer[head]);

                
                // Send data to output

                data_out <= buffer[head];
                head <= head + 1; // note use of 256-bit overflow
                sent_count <= sent_count + 1;
                sending = 1;
                wait(received);
                sending = 0;
                if (sent_count >= size_of_data/8) begin
                    done = 1;
                    send_state = IDLE;
                end
            end
                default: ;
            endcase

        end
    end

endmodule