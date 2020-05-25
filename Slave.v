module Slave(CPHA, SS, CLK, MOSI, READ_MEMORY, DATA, 
	     MISO, OUT_SHIFT_STATE, OUT_MAIN);

// INPUTS
input CPHA;	//CLOCK PHASE
input CLK;	//CLOCK POLARITY
input SS;	//SLAVE SELECT
input MOSI;	//MASTER OUTPUT SLAVE INPUT
input READ_MEMORY;//READING FROM MEMORY OR WRITING
input [7:0]DATA; //INPUT DATA FOR SLAVE

// OUTPUTS
output MISO;	//MASTER INPUT SLAVE OUTPUT
output [0:7]OUT_SHIFT_STATE; 
output [0:7]OUT_MAIN;

// PARAMETRS
reg [0:7] MAIN_MEMORY = 8'b00000000;
reg [0:7] STATE;
reg DATA_IN;
reg IS_VALID = 0;

assign OUT_SHIFT_STATE = STATE;
assign OUT_MAIN = MAIN_MEMORY;
assign MISO = STATE[7];

// Load Data to The Main Memory
always @(posedge READ_MEMORY) begin 
MAIN_MEMORY = DATA;
end

always @(negedge SS) begin
IS_VALID = 0;
STATE = MAIN_MEMORY;
end

always @(posedge CLK) begin
if(SS == 0) begin
	if(CPHA == 0) begin 
	    DATA_IN = MOSI;
            IS_VALID = 1;
	end
	else if(CPHA == 1 && IS_VALID)begin
	    STATE[0:7] = {DATA_IN, STATE[0:6]}; 
	end
end
end

always @(negedge CLK) begin
if(SS == 0) begin
	if(CPHA == 1) begin 
	    DATA_IN = MOSI;
	    IS_VALID = 1;
	end
	else if(CPHA == 0 && IS_VALID) begin
	    STATE[0:7] = {DATA_IN, STATE[0:6]};
	end
end
end

endmodule


///////////////////////////////////--> SLAVE TESTBENCH <--////////////////////////////////////////////////////////

module Slave_tb();

//SLAVE INPUTS 
reg CPHA;
reg CPOL;
reg CLK;
reg SS;
reg MOSI;
reg READ_MEMORY;
reg [0:7]DATA;

//OUTPUTS 
wire MISO;
wire [0:7]OUT_SHIFT_STATE;
wire [0:7]OUT_MAIN;

integer f;
integer Iterator;

Slave Slave1(CPHA,SS,CLK,MOSI,READ_MEMORY,DATA,MISO,OUT_SHIFT_STATE,OUT_MAIN);

initial begin 
f=$fopen("Slave_tb.txt");
$fdisplay (f,"////////// SLAVE TESTBENCH ///////////////////");
$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// MODE 0 //////////////////////");
$fdisplay (f,"CLK	MOSI	MISO	OUT_SHIFT_STATE	    OUT_MAIN");
$fmonitor (f,"%b	%b	%b	%b		%b",CLK,MOSI,MISO,OUT_SHIFT_STATE,OUT_MAIN);

// MODE 0
SS=0;
CPHA=0;
CPOL=0;
CLK=0;
MOSI=1;
READ_MEMORY=1;
DATA=8'b00000000;

//CLK GENERATION :

for (Iterator=0;Iterator<18;Iterator=Iterator+1) begin 
CLK=~CLK;
#10;
end

#10 READ_MEMORY=0;

//MODE 1

$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// MODE 1 //////////////////////");
$fdisplay (f,"CLK	MOSI	MISO	OUT_SHIFT_STATE	    OUT_MAIN");

CPHA=1;
READ_MEMORY=1;
CLK=0;
MOSI=0;
//CLK GENERATION 

for (Iterator=0;Iterator<18;Iterator=Iterator+1) begin 
CLK=~CLK;
#10;
end

#10 READ_MEMORY=0;


//MODE 2

$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// MODE 2 //////////////////////");
$fdisplay (f,"CLK	MOSI	MISO	OUT_SHIFT_STATE	    OUT_MAIN");

CPHA=1;
CPOL=1;
READ_MEMORY=1;
CLK=0;
MOSI=1;
for (Iterator=0;Iterator<18;Iterator=Iterator+1) begin 
CLK=~CLK;
#10;
end

#10 READ_MEMORY=0;


//MODE 3

$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// MODE 3 //////////////////////");
$fdisplay (f,"CLK	MOSI	MISO	OUT_SHIFT_STATE	    OUT_MAIN");

CPHA=0;
CPOL=1;
READ_MEMORY=1;
CLK=0;
MOSI=0;
for (Iterator=0;Iterator<18;Iterator=Iterator+1) begin 
CLK=~CLK;
#10;
end

#10 READ_MEMORY=0;


//MODE DEACTIVATED

$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// SLAVE IS DEACTIVATED //////////////////////");
$fdisplay (f,"CLK	MOSI	MISO	OUT_SHIFT_STATE	    OUT_MAIN");

SS=1;
CLK=1;
MOSI=1;
for (Iterator=0;Iterator<18;Iterator=Iterator+1) begin 
CLK=~CLK;
#10;
end

#10 READ_MEMORY=0;

$fdisplay (f,"//////////////////////////////////////////////");
$fdisplay (f,"/////////////// END SIMULATION //////////////////////");


$fclose(f);


$stop;
end

endmodule 















