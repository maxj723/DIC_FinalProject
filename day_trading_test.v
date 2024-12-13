module day_trading_test;

    reg clk;                   // Clock signal
    reg rst;                   // Reset signal
    reg [15:0] stock_in;       // 16-bit input
    wire [15:0] action_out;    // 16-bit output
    
    // Instantiate the DUT (Device Under Test)
    day_trading dut (
        .clk(clk),
        .rst(rst),
        .stock_in(stock_in),
        .action_out(action_out)
    );

    // Clock generation (50% duty cycle)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units for a full clock cycle
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        rst = 1;
        stock_in = 16'b0;
        
        // Apply reset
        #10 rst = 0;

        // Test case 1: Stagnant trend
        // Day 1 = 10, Day 2 = 10, Day 3 = 10, User does not own the stock
        stock_in = 16'b0_01010_01010_01010; // Ownership = 0, values = 10, 10, 10
        #60; // Wait for FSM to process all states
        $display("Action (Stagnant, Not Owned): %h", action_out);

        // Test case 2: Increasing trend
        // Day 1 = 5, Day 2 = 10, Day 3 = 15, User owns the stock
        stock_in = 16'b1_00101_01010_01111; // Ownership = 1, values = 5, 10, 15
        #60;
        $display("Action (Increasing, Owned): %h", action_out);

        // Test case 3: Decreasing trend
        // Day 1 = 20, Day 2 = 15, Day 3 = 10, User does not own the stock
        stock_in = 16'b0_10100_01111_01010; // Ownership = 0, values = 20, 15, 10
        #60;
        $display("Action (Decreasing, Not Owned): %h", action_out);

        // Test case 4: Increasing trend
        // Day 1 = 7, Day 2 = 8, Day 3 = 9, User does not own the stock
        stock_in = 16'b0_00111_01000_01001; // Ownership = 0, values = 7, 8, 9
        #60;
        $display("Action (Increasing, Not Owned): %h", action_out);

        // Test case 5: Stagnant trend
        // Day 1 = 12, Day 2 = 12, Day 3 = 12, User owns the stock
        stock_in = 16'b1_01100_01100_01100; // Ownership = 1, values = 12, 12, 12
        #60;
        $display("Action (Stagnant, Owned): %h", action_out);

        // Test case 6: Decreasing trend
        // Day 1 = 18, Day 2 = 10, Day 3 = 5, User owns the stock
        stock_in = 16'b1_10010_01010_00101; // Ownership = 1, values = 18, 10, 5
        #60;
        $display("Action (Decreasing, Owned): %h", action_out);

        // End simulation
        $stop;
    end
endmodule

