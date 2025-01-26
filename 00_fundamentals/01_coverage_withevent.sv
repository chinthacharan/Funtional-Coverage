//////////////////////Design Code

module top
    (
      input  [1:0]  a,
      output [1:0]  b  
    );
    
  assign b = a;
    
    
  endmodule
  //////////////Testbench Code
  
  
  
  module tb;
   
    reg  [1:0]  a;
    wire [1:0]  b;
    integer i = 0;
    
    top dut (.a(a), .b(b));

    covergroup cvr_a @(a);
        coverpoint a;
        coverpoint b;
    endgroup

    cvr_a ci = new();

    initial begin
        for(int i = 0; i < 10; i++) begin
            a = $urandom();
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
    
    
    /////////////////////////////run.do
    
    vsim +access+r;
    run -all;
    acdb save;
    acdb report -db  fcover.acdb -txt -o cov.txt -verbose  
    exec cat cov.txt;
    exit