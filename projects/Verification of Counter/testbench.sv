class transaction;

    rand bit [7:0] loadin;
    bit load;
    bit rst;
    bit up;
    bit [7:0] y;
endclass

class generator;

    transaction t;
    mailbox mbx
    event done;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        for(int i = 0; i < 200; i++) begin
            t.randomize();
            mbx.put(t);
            @(done);
        end
    endtask

endclass

class driver;
    mailbox mbx;
    transaction t;
    event done;

    virtual counter8_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        forever begin
            mbx.get(t);
            vif.loadin <= t.loadin;
            @(posedge vif.clk);
            ->done;
        end
    endtask
endclass

class monitor;
    virtual counter8_intf vif;
    mailbox mbx;
    transaction t;

    covergroup c;
        option.per_instance = 1;

        coverpoint t.loadin {
            bins lower = {[0:84]};
            bins mid = {[85:169]};
            bins high = {[170:255]};
        }

        coverpoint t.rst {
            bins rst_low = {0};
            bins rst_high = {1};
        }

        coverpoint t.load {
            bins ld_low = {0};
            bins ld_high = {1};
        }

        coverpoint t.y {
            bins lower = {[0:84]};
            bins mid = {[85:169]};
            bins high = {[170:255]};
        }

        cross_ld_loadin: cross t.load, t.loadin{
            ignore_bins unused_ld = binsof(t.load) intersect{0};
        }

        cross_rst_up: cross t.rst, t.up{
            ignore_bins unused_rst = binsof(t.rst) intersect{1};
        }

        cross_rst_y: cross t.rst, t.y{
            ignore_bins unused_rst = binsof(t.rst) intersect{1};
        }
    endgroup

    function new(mailbox mbx);
        this.mbx = mbx;
        c = new();
    endfunction

    task run();
        t = new();
        forever begin
            t.loadin = vif.loadin;
            t.y = vif.y;
            t.rst = vif.rst_lt;
            t.up = vif.up;
            t.load = vif.load;
            c.sample();
            mbx.put(t);
            @(posedge vif.clk);
        end
    endtask
endclass

class scoreboard;
    mailbox mbx;
    transaction t;
    bit [7:0] temp;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction

    task run();
        t = new();
        forever begin
            mbx.get(t);
        end
    endtask
endclass

class environment;
    generator g;
    driver d;
    monitor m;
    scoreboard s;

    virtual counter_8_intf vif;

    mailbox gdmbx;
    mailbox msmbx;

    event gddone;

    function new(mailbox gdmbx, mailbox msmbx);
        this.gdmbx = gdmbx;
        this.msmbx = msmbx;

        g = new(gdmbx);
        d = new(gdmbx);
        m = new(msmbx);
        s = new(msmbx);
    endfunction

    task run();
        g.done = gddone;
        d.done = gddone;

        d.vif = vif;
        m.vif = vif;

        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join
    endtask
endclass

module tb();
 
    environment env;
     
    mailbox gdmbx;
    mailbox msmbx;
     
    counter_8_intf vif();
     
    counter_8 dut ( vif.clk, vif.rst, vif.up, vif.load,  vif.loadin, vif.y );
     
    always #5 vif.clk = ~vif.clk;
      
    initial begin
     vif.clk = 0;
     vif.rst = 1;
     #50; 
     vif.rst = 0;  
    end
     
    initial begin
    #60;
      repeat(20) begin
     vif.load = 1;
     #10;
      vif.load = 0;
     #100;
      end
    end
      
     initial begin
    #60;
      repeat(20) begin
      vif.up = 1;
     #70;
      vif.up = 0;
     #70;
      end
    end 
     
    initial begin
    gdmbx = new();
    msmbx = new();
    env = new(gdmbx, msmbx);
    env.vif = vif;
    env.run();
    #2000;
    $finish;
    end
      
    initial begin
      $dumpfile("dump.vcd"); 
      $dumpvars;  
    end
    endmodule

