//Example structure

//sampling on Event (Method 1)

covergroup c @(posedge clk);
    option.per_instance = 1;
    coverpoint a;
endgroup

//Sampling with sample() method (Method 2)
covergroup c;
    option.per_instance = 1;
    coverpoint a;
endgroup

c ci= new();
for(int i = 0; i < 40; i++) begin
    @(posedge clk);
    a = $urandom();
    ci.sample();
end

//User defined sampling (Method 3)

covergroup c with function sample (input opstate cin);
    option.per_instance = 1;
    coverpoint cin;
endgroup

c ci = sample();

function check_cover (input rd, wr, en);
    o1 = detect_state(rd, wr, en);
    din = decode_state(o1);
    ci.sample();
endfunction