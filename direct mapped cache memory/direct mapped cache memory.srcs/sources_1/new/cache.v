`timescale 1ns / 1ps

module cache(
PRead_request,PWrite_request,PWrite_data,PAddress,PRead_data,PRead_ready,PWrite_done,MRead_request,MWrite_request,MWrite_data,MAddress,MRead_data,MRead_ready,MWrite_done,clk,rst
    );
input PRead_request;
input PWrite_request;
input [7:0] PWrite_data;
input [7:0] PAddress;
output reg [7:0] PRead_data;
output reg PRead_ready;
output reg PWrite_done;

output reg MRead_request;
output reg MWrite_request;
output reg [7:0] MWrite_data;
output reg [7:0] MAddress;
input [31:0] MRead_data;
input MRead_ready;
input MWrite_done;
input clk,rst; 
    reg valid_bit [7:0];//one bit of valid data for each cache memory block
    reg [2:0] tag;//tag bits
    reg [2:0] index;//defines which block is selected in the cache memory
    reg [1:0] byte_offset;//defines which byte of a specific block is selected in cache memory
    reg [2:0] cache_tag_table [7:0];//cache tag table 
    reg [31:0] cache_memory [7:0];//cache memory 
    integer i =0;
    initial begin
   
   
    end
    reg [3:0] state=0;//states initialised
   
    always @(posedge clk)
    begin
    
    if(rst)//when we give reset signal
    begin
    for(i=0;i<8;i=i+1)begin//valid bits
     valid_bit[i]<=0;
    end
     MAddress<=0;
     MWrite_data<=0;
     MWrite_request<=0;
     MRead_request<=0;
     PRead_data<=0;
     PWrite_done<=0;
     PRead_ready<=0;
        
    end
    else begin// when reset is made zero
    case (state)
    0: begin
     for(i=0;i<8;i=i+1)begin
       valid_bit[i]<=1;//valid bits are made 8'hff
       end
           
    state<=1;
      end
    1:begin
      if(PRead_request==1)begin//when processor requests to read data
    tag=PAddress[7:5];//decomposing address into tag,index and byte_offset bits
    index=PAddress[4:2];
    byte_offset=PAddress[1:0];

    if(cache_tag_table[index]== tag)//checking for hit
    state<=2;//for hit read
    else
    state<=3;//for miss read
     
    end
    if(PWrite_request==1)begin//when processor requests to write data
    tag=PAddress[7:5];//decomposing address into tag,index and byte_offset bits
    index=PAddress[4:2];
    byte_offset=PAddress[1:0];

    if(cache_tag_table[index]== tag)//checking for hit
    state<=12;//for hit write
    else
    state<=7;//for miss write
      
      
    end
    end
    2: begin
  
  
    if(cache_tag_table[index]== tag && PRead_request==1)//when it is read hit
    begin
    if(byte_offset==2'd0)begin PRead_data<=cache_memory[index][7:0]; end//depending upon the byte_offset,PRead_data is updated according to the byte selected of a specific block in cache memory
    if(byte_offset==2'd1) begin PRead_data<=cache_memory[index][15:8]; end
    if(byte_offset==2'd2) begin PRead_data<=cache_memory[index][23:16]; end
    if(byte_offset==2'd3) begin PRead_data<=cache_memory[index][31:24];end
    PRead_ready<=1;//PRead_ready is made 1
    state<=6;
    end
  else 
    state<=2;
    end
    3:begin
    
    if(PRead_request==1)//when it is a read miss
    begin
   
    MAddress<=PAddress;//update MAddress with PAddress
    MRead_request<=1;//Now MRead_request is made 1
    state<=4;
    end
  else
    state<=3;
    end
    4: begin
    if(MRead_ready == 1)//waits for data to be available from main memory and when MRead_ready is 1 this block is evaluated
    begin
    cache_memory[index]<=MRead_data;//the data from memory is given into a specific block of cache_memory
    cache_tag_table[index]<=MAddress[7:5];//the specific block of cache tag table is updated using the tag bits of MAddress
    MRead_request<=0;//MRead_request is made zero after every memory access
    state<=5;
    
    end
  else
    state<=4;
   end
   5: begin
   if (MRead_ready==0)begin//once data has been transferred to cache memory from main memory, depending upon the byte offset,PRead_data is updated
         if(byte_offset==2'd0)begin PRead_data<=cache_memory[index][7:0]; end
    if(byte_offset==2'd1) begin PRead_data<=cache_memory[index][15:8]; end
    if(byte_offset==2'd2) begin PRead_data<=cache_memory[index][23:16]; end
    if(byte_offset==2'd3) begin PRead_data<=cache_memory[index][31:24];end
     PRead_ready<=1;//once PRead_data is updated, PRead_ready is set to 1
   state<=6;
   end
 else
  state<=5;
   end
    6: begin
    if(PRead_request==0)//waits for data to get transferred to PRead_data, ONce we get PRead_request as 0 we evaluate this block 
    begin
    PRead_ready<=0;//PRead_ready made to 0
    state<=0;
    end
    else
    state<=6;
    end
    
      7:begin//when it is write miss
      if(PWrite_request==1)begin//when PWrite_request is set to 1
      MWrite_request<=1;//as it is a miss, only memory is updated so MWrite_request is set to 1
      cache_tag_table[index]<=PAddress[7:5];  //tag bits are given to cache tag table
      state<=8;
      end
      else
      state<=7;
      end
      8:  begin
      if(MWrite_request==1)begin//to write to memory,MWrite_request is made to 1
        MAddress<=PAddress;//PAddress is given to MAddress
        MWrite_data<=PWrite_data;//PWrite_data is given to MWrite_data
        MWrite_request<=0;//once MWrite_data is updated,MWrite_request is cleared
        state<=9;
        end
        else 
          state<=8;
          
        end
       9:begin
         
       if(MWrite_done==1)begin// when MWrite_data is updated, it waits for MWrite_done
         PWrite_done<=1;//PWrite_done is cleared
         state<=10;
         end
         else 
           state<=9;
         end
       10:  begin
         if(MWrite_done==0)begin
         PWrite_done<=0;//PWrite_done is cleared
           state<=11;
           end
           else
           state<=10;
       end 
       11:begin
         if(PWrite_request==0)begin
           state<=0;
           end
           else
           state<=11;
         end
         12:begin
           if(PWrite_request==1 && cache_tag_table[index]== tag)//when it is a write hit
             begin//we need to write to both cache and memory
             MWrite_request<=1;//for memory write 
             if(byte_offset==2'd0)begin cache_memory[index][7:0]<=PWrite_data; end//depending upon the byte_offset, specific block of cache memory id updated with PWrite_data
             if(byte_offset==2'd1) begin cache_memory[index][15:8]<=PWrite_data; end
             if(byte_offset==2'd2) begin cache_memory[index][23:16]<=PWrite_data; end
             if(byte_offset==2'd3) begin cache_memory[index][31:24]<=PWrite_data;end
            
             
             state<=8;
             end
             else
               state<=12;
           end
endcase
end
end   
endmodule