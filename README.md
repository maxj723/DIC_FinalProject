# Trading Signal Generator   
   
Names: Kieran Cosden, Eric Foreman, Max Johnson, Ryan Nahm
   
emails:   mjohns79@nd.edu, eforeman@nd.edu, kcosden@nd.edu, rnahm@nd.edu
   
CSE 30342 - Digital Integrated Circuits - University of Notre Dame   
   
## Project Overview
The Trading Signal Generator is a digital circuit designed in Verilog. This project aims to demonstrate a hardware-based solution for interpreting trading data and producing actionable signals. The “Buy,” “Sell,” and “Hold” indicators also demonstrate the confidence or quantity at which one should act. Despite its algorithmic naivety, this implementation exemplifies the advantages of hardware acceleration for trading decision processes, including, but not limited to, efficiency, low latency, and reliability.   
   
The Trading Signal Generator processes a 16-bit input representing trading data over three consecutive time units of trading. Next, the module analyzes the price trend and ownership status to output a trading action.   
   
### Input
The 16-bit input is structured as follows:   
**Bit 15 (Ownership Flag):**   
	- **0:** Not owned   
	- **1:** Owned   
**Bit [14:10] (Time 1 Price):**   
	- Represents Price at time 1   
	- Price range: 0 to 31 (5 bits)   
**Bit [9:5] (Time 2 Price):**   
	- Represents Price at time 2   
	- Price range: 0 to 31 (5 bits)   
**Bit [4:0] (Time 3 Price):**   
	- Represents Price at time 3   
	- Price range: 0 to 31 (5 bits)   
   
### Output
The 16-bit output translates to decimal integers which map as follows:
  - **1:** SELL ALL
  - **2:** STAY AWAY
  - **3:** Buy more
  - **4:** BUY A LOT
  - **5:** Sell some
  - **6:** Buy a little more
  - **7:** Buy a little
  - **8:** HOLD
  - **0:** FAILED CALCULATION   
The remaining bits are left available for future expansion beyond current implementation.   
   
### Code Description
  - The input vector defined above is taken into the module as `stock_in`, and the output is defined as `action_out`. Our finite state machine has 6 states. The first `IDLE`, is the resting state, waiting for an input to arrive. Next, there are 3 states for separating stock price data for the 3 days respectively: `GET_DAY1`, `GET_DAY2`, and `GET_DAY3`. The fifth state is `EVALUATE_TREND` which uses a series of logic to determine the general trend of the data and store the value in an intermediate register `trend`. The final state, `DETERMINE_ACTION`, evaluates the trend and the ownership bit to output to the user whether they should buy, sell, or hold their stock.


### Finite State Machine:   
  -**IDLE:**
    - No action while in idle 
    - `action_out <= 16’b0;`
  -**GET_DAY1:**
    - Extracts both the day 1 value as well as the ownership bit
    - `owned <= stock_in[15];`
    - `day1 <= stock_in[14:10];`
  -**GET_DAY2:**
    - Extracts the day 2 value
    - `day2 <= stock_in[9:5];`	
  -**GET_DAY3:**
    - Extracts the day 3 value
    - `1day3 <= stock_in[4:0];`
  -**EVALUATE_TREND:**
    - Determine the trend based on the given day values
  -**DETERMINE_ACTION:**
    - Define output given the trend and ownership status
