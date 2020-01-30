`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2019 11:03:22 AM
// Design Name: 
// Module Name: cache_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_tb;

    reg clk;
    reg rst;

    reg PRead_request;
    reg PWrite_request;
    wire PRead_ready;
    wire PWrite_done;
    reg [7:0] PWrite_data;
    wire [7:0] PRead_data;
    reg [7:0] PAddress;
    //memory side
    wire MRead_request;
    wire MWrite_request;
    reg MRead_ready;
    reg MWrite_done;
    wire[7:0] MWrite_data;//output wire input reg
    reg [31:0] MRead_data;
    wire [7:0] MAddress;


    cache dut(
        .clk(clk),
        .rst(rst),
        //processor side
        .PRead_request(PRead_request),
        .PRead_ready(PRead_ready),
        .PRead_data(PRead_data),
        .PAddress(PAddress),
        .PWrite_request(PWrite_request),
         .PWrite_data(PWrite_data),
         .PWrite_done(PWrite_done),
        //memory side
        .MRead_request(MRead_request),
        .MWrite_request(MWrite_request),
        .MRead_ready(MRead_ready),
        .MRead_data(MRead_data),
        .MWrite_data(MWrite_data),
        .MAddress(MAddress),
         .MWrite_done(MWrite_done)
        );

initial
begin
    clk = 0;
    rst = 1;
    
PRead_request=0;
PAddress=0;
MRead_data=0;
MRead_ready=0;
PWrite_request=0;
PWrite_data=0;
MWrite_done<=0;

#10;
    
   
    @(posedge clk);
    rst = 0;
     
  #10 ;
    //test logic for cache miss read
    
    @(posedge clk);
    PAddress = 3;
    PRead_request = 1;
   #10;
   
    @(posedge clk);
    MRead_data=3;// MRead_data==3 and PAddress=3 would mean cache_memory[000][31:23]=8'b0, 
    MRead_ready = 1;
    
    @(posedge clk);
    MRead_ready = 0;
    wait(PRead_ready);
   
    @(posedge clk);
    PRead_request = 0;
    
  #10;
    //test logic for cache hit read
    @(posedge clk);
    PAddress = 0;// cache_memory[000][7:0]=31'd3, PAddress=0 would mean cache_memory[000][31:23]=8'd3, 
    PRead_request = 1;
    @(posedge clk);
    wait(PRead_ready);
    @(posedge clk);
    PRead_request = 0;
   #10;
   
   //test logic for cache miss write
    @(posedge clk);
    PAddress =10;
    PWrite_data =10;//0a is written to memory
    PWrite_request =1;
     #10;
    @(posedge clk);
    
    MWrite_done=1;
    
    @(posedge clk);
    MWrite_done=0;
    
    @(posedge clk);
    PWrite_request =0;
#10;

    //test logic for cache hit write
    @(posedge clk);
    PAddress =9;
    PWrite_data =9;//09 is written to memory and cache memory
    PWrite_request =1;
     #10;
      @(posedge clk);
    
    MWrite_done=1;

     @(posedge clk);
    MWrite_done=0;
    
    @(posedge clk);
    PWrite_request =0;
#10;
  

end
always clk = #1 ~clk;

endmodule