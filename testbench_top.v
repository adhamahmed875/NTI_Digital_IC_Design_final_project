module testbench;
wire access, alarm, frozen;
wire [2:0] trials;
wire [1:0] state;
reg [31:0] in;
reg set_en, reset, clk;

password_top p0(
    .i_input(in),
    .i_set_en(set_en),
    .i_reset(reset),
    .i_clk(clk),
    .o_access(access),
    .o_alarm(alarm),
    .o_frozen(frozen),
    .o_trials(trials),
    .o_state(state)
);

initial begin
    $monitor($time," State=%b,Access=%b,Alarm=%b,Frozen=%b,Trials=%d,Input=%h,Set=%b,Reset=%b",
             state,access,alarm,frozen,trials,in,set_en,reset);
end

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset=1; set_en=0; in='h00000000;   // power-up reset

    #10 reset=0;                        // start in INITIAL

    #10 set_en=1; in='hdeadbeef;        // program the first password
    #10 set_en=0; in='h12345678;        // wrong guess 1
    #10 in='h14343542;                  // wrong guess 2
    #10 in='h1242adcb;                  // wrong guess 3
    #10 in='h12acfe38;                  // wrong guess 4 -> should reach FREEZE
    #10 in='hdeadbeef;                  // correct password, but frozen so no access

    #10 reset=1;                        // reset clears the freeze and the saved password
    #10 reset=0;
    #10 set_en=1; in='hdeadbeef;        // back in INITIAL, program the password again
    #10 set_en=0; in='hdeadbeef;        // correct password -> access

    #10 $stop;
end
endmodule
