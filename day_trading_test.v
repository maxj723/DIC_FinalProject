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

    // Creating a task to check if outp
    task expect;
    input exp_out;
    if(action_out !== exp_out)
        begin 
            $display("TEST FAILED");
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize inputs
        rst = 1;
        stock_in = 16'b0;
        
        // Apply reset
        #10 rst = 0;

        // Test case 1: Stagnant trend, don't own
        // Day 1 = 10, Day 2 = 10, Day 3 = 10, User does not own the stock
        stock_in = 16'b0_01010_01010_01010; // Ownership = 0, values = 10, 10, 10
        #1 expect(7); // expecting buy a little

        // Test case 5: Stagnant trend, owns
        // Day 1 = 12, Day 2 = 12, Day 3 = 12, User owns the stock
        stock_in = 16'b1_01100_01100_01100; // Ownership = 1, values = 12, 12, 12
        #1 expect(8); // expecting Hold

        // Test case 2: Increasing trend, owns
        // Day 1 = 5, Day 2 = 10, Day 3 = 15, User owns the stock
        stock_in = 16'b1_00101_01010_01111; // Ownership = 1, values = 5, 10, 15
        #1 expect(1); // expecting sell all

        // Test case 4: Increasing trend, don't own
        // Day 1 = 7, Day 2 = 8, Day 3 = 9, User does not own the stock
        stock_in = 16'b0_00111_01000_01001; // Ownership = 0, values = 7, 8, 9
        #1 expect(2); // expecting stay out

        // Test case 3: Decreasing trend, don't own
        // Day 1 = 20, Day 2 = 15, Day 3 = 10, User does not own the stock
        stock_in = 16'b0_10100_01111_01010; // Ownership = 0, values = 20, 15, 10
        #1 expect(4); // expecting buy a lot

        // Test case 6: Decreasing trend, owns
        // Day 1 = 18, Day 2 = 10, Day 3 = 5, User owns the stock
        stock_in = 16'b1_10010_01010_00101; // Ownership = 1, values = 18, 10, 5
        #1 expect(3); // expecting buy more

        // Test case: Decreasing some, owns

        // Test case: Decreasing some, don't own

        // Test case: Increasing some, owns

        // Test case: increasing some, don't own


        // Confirm tests all passed
        $display("TEST PASSED");
        $finish;
    end
endmodule

