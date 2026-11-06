module top (
    input wire clk,       // 27 MHz onboard clock
    input wire s1,        // Increment button (active-low)
    input wire s2,        // Clear / Reset button (active-low)
    output wire [5:0] led // 6 onboard LEDs (active-low)
);

    // 3-stage synchronizers for metastable filtering
    reg [2:0] s1_sync = 3'b111;
    reg [2:0] s2_sync = 3'b111;

    always @(posedge clk) begin
        s1_sync <= {s1_sync[1:0], s1};
        s2_sync <= {s2_sync[1:0], s2};
    end

    // Detect falling edges (button press transitions from high to low)
    wire s1_pressed = (s1_sync[2:1] == 2'b10);
    wire s2_pressed = (s2_sync[2:1] == 2'b10);

    // 6-bit binary counter logic
    reg [5:0] counter = 6'b000000;

    always @(posedge clk) begin
        if (s2_pressed) begin
            counter <= 6'b000000;         // Clear counter on S2 press
        end else if (s1_pressed) begin
            counter <= counter + 1'b1;    // Increment counter on S1 press
        end
    end

    // Invert counter bits because Tang Nano 20K LEDs are active-low
    assign led = ~counter;

endmodule