module day_trading (
    input wire clk,             // Clock signal
    input wire rst,             // Reset signal
    input wire [15:0] stock_in, // 16-bit input data
    output reg [15:0] action_out // 16-bit output message
);
    // State encoding
    typedef enum reg [2:0] {
        IDLE            = 3'b000,
        GET_DAY1        = 3'b001,
        GET_DAY2        = 3'b010,
        GET_DAY3        = 3'b011,
        EVALUATE_TREND  = 3'b100,
        DETERMINE_ACTION = 3'b101
    } state_t;

    state_t current_state, next_state;

    // Registers to store day values and ownership
    reg [4:0] day1, day2, day3;
    reg owned;
    
    reg [2:0] trend; // 000 = stagnant, 001 = increasing a lot, 010 = decreasing a lot, 011 = increasing a little, 100 = decreasing a little

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: next_state = GET_DAY1;
            GET_DAY1: next_state = GET_DAY2;
            GET_DAY2: next_state = GET_DAY3;
            GET_DAY3: next_state = EVALUATE_TREND;
            EVALUATE_TREND: next_state = DETERMINE_ACTION;
            DETERMINE_ACTION: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic and intermediate computations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers and outputs
            day1 <= 5'b0;
            day2 <= 5'b0;
            day3 <= 5'b0;
            owned <= 1'b0;
            trend <= 3'b000;
            action_out <= 16'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    // No action in IDLE
                    action_out <= 16'b0;
                end
                GET_DAY1: begin
                    // Extract day 1 value and ownership bit
                    owned <= stock_in[15];
                    day1 <= stock_in[14:10];
                end
                GET_DAY2: begin
                    // Extract day 2 value
                    day2 <= stock_in[9:5];
                end
                GET_DAY3: begin
                    // Extract day 3 value
                    day3 <= stock_in[4:0];
                end
                EVALUATE_TREND: begin
                    // Determine trend based on day values
                    if (day1 < day2 && day2 < day3)
                        trend <= 3'b001; // Increasing a lot
                    else if (day1 > day2 && day2 > day3)
                        trend <= 3'b010; // Decreasing a lot
                    else if (day1 > day2 && day3 > day1)
                        trend <= 3'b011;  // Increasing slightly
                    else if(day1 < day2 && day3 < day1)
                        trend <= 3'b100;   // decreasing slightly
                    else
                        trend <= 3'b000; // Stagnant
                end
                DETERMINE_ACTION: begin
                    // Determine action based on trend and ownership
                    if (trend == 3'b001) begin // if increasing a lot
                        if (owned)
                            action_out <= 1; // "Sell all"
                        else
                            action_out <= 2; // "Stay out"

                    end else if (trend == 3'b010) begin // if decreasing a lot
                        if (owned)
                            action_out <= 3; // "Buy More"
                        else
                            action_out <= 4; // "Buy a lot"
                    end else if (trend == 3'b011) begin // if increasing some
                        if (owned)
                            action_out <= 5; // "Sell half"
                        else
                            action_out <= 2; // "Stay out"

                    end else if (trend == 3'b100) begin // if decreasing some
                        if (owned)
                            action_out <= 6; // "Buy a little more"
                        else
                            action_out <= 7; // "Buy a little"
                    end else if (trend == 3'b000) begin // stagnant trend
                        if (owned)
                            action_out <= 8; // "Hold"
                        else
                            action_out <= 7; // "Buy a little"
                    end else begin
                            action_out <= 0; // Failed Calculation
                    end
                end
                default: begin
                    // Default state, no action
                    action_out <= 0; // Failed calculation
                end
            endcase
        end
    end
endmodule