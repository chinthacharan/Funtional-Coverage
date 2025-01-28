/////////////////////////////////////Design Code

module top
    (
      input  [1:0]  a,
      output [1:0]  b  
    );
    
  assign b = a;
    
    
  endmodule
  
  
  ///////////////////////Testbench Code
  
  
  
  module tb;
   
    reg  [1:0]  a; //00 01 10 11
    wire [1:0]  b;
    integer i = 0;
    
    top dut (.a(a), .b(b));

    covergroup cvr_a;
        option.per_instance = 1;
        option.name = "COVER_A_B";
        option.goal = 70;
        option.at_least = 4;
        option.auto_bin_max = 2;

        coverpoint a;
        coverpoint b;
    endgroup

    cvr_a ci = new();

    initial begin
        for(int i = 0; i < 10; i++) begin
            a = $urandom();
            ci.sample();
            #10;
        end
    end

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
        #500;
        $finish();
      end
      
    endmodule    