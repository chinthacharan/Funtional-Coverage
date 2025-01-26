module tb;
 
    reg  [1:0]  a;
    reg [1:0]  b;
    integer i = 0;

    covergroup cvr_a;
        option.per_instance = 1;
        option.goal = 62;
        type_option.goal = 62;

        coverpoint a{
            option.goal = 50;
        }

        coverpoint b{
            option.goal = 75;
        }
    endgroup

    cvr_a ci = new();

    initial begin
        for(i = 0; i < 5; i++) begin
            a = $urandom();
            b = $urandom();
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