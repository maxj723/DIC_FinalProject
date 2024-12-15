module day_trading_test;

    reg clk;                   // Clock signal
    reg rst;                   // Reset signal
    reg [15:0] stock_in;       // 16-bit input
    wire [15:0] action_out;    // 16-bit output
    
    // Instantiate the Device Under Test (DUT)
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

    // Creating a task to check if output is equal to expected output
    task expect;
    input exp_out;
    if(action_out !== exp_out)
        begin 
            $display("TEST FAILED");
            $display("time=%0d: output is %b and should be %b",
                 $time, action_out, exp_out);
            $finish;
            // Put something about the time or sum shit when it fails, the case that fails maybe
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize inputs
        //rst = 1;
        //stock_in = 16'b0;
        
        // Apply reset
        #10 rst = 0;

        // Test case: Stagnant trend, don't own
        $display("TESTING STAGNANT TREND, NO OWNERSHIP");
        stock_in = 16'b0_01010_01010_01010; // Ownership = 0, values = 10, 10, 10
        #60 expect(7); // expecting buy a little

        // Test case: Stagnant trend, owns
        $display("TESTING STAGNANT TREND, OWNERSHIP");
        stock_in = 16'b1_01100_01100_01100; // Ownership = 1, values = 12, 12, 12
        #60 expect(8); // expecting Hold

        // Test case: Increasing trend, owns
        $display("TESTING STRONG INCREASING TREND, OWNERSHIP");
        stock_in = 16'b1_00101_01010_01111; // Ownership = 1, values = 5, 10, 15
        #60 expect(1); // expecting sell all

        // Test case: Increasing trend, don't own
        $display("TESTING STRONG INCREASING TREND, NO OWNERSHIP");
        stock_in = 16'b0_00111_01000_01001; // Ownership = 0, values = 7, 8, 9
        #60 expect(2); // expecting stay out

        // Test case: Decreasing trend, don't own
        $display("TESTING STRONG DECREASING TREND, NO OWNERSHIP");
        stock_in = 16'b0_10100_01111_01010; // Ownership = 0, values = 20, 15, 10
        #60 expect(4); // expecting buy a lot

        // Test case: Decreasing trend, owns
        $display("TESTING STRONG DECREASING TREND, OWNERSHIP");
        stock_in = 16'b1_10010_01010_00101; // Ownership = 1, values = 18, 10, 5
        #60 expect(3); // expecting buy more

        // Test case: Decreasing some, owns
        $display("TESTING WEAK DECREASING TREND, OWNERSHIP");
        stock_in = 16'b1_01010_01100_01000  // Ownership = 1, values = 10, 12, 8
        #1
        // Test case: Decreasing some, don't own
        $display("TESTING WEAK DECREASING TREND, NO OWNERSHIP");
        stock_in = 16'b0_01010_01100_01000  // Ownership = 0, values = 10, 12, 8

        // Test case: Increasing some, owns
        $display("TESTING WEAK INCREASING TREND, OWNERSHIP");
        stock_in = 16'b1_01010_00111_01110  // Ownership = 1, values = 10, 7, 14

        // Test case: increasing some, don't own
        $display("TESTING WEAK INCREASING TREND, NO OWNERSHIP");
        stock_in = 16'b0_00101_00011_01010  // Ownership = 0, values = 5, 3, 10


        // Confirm tests all passed
        $display("TEST PASSED");
        $finish;
    end
endmodule

