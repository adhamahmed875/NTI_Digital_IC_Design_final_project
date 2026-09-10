module password_top(
    i_input,
    i_set_en,
    i_reset,
    i_clk,
    o_access,
    o_alarm,
    o_frozen,
    o_trials,
    o_state
);

    input [31:0] i_input;
    input i_set_en;
    input i_reset;
    input i_clk;

    output o_access;
    output o_alarm;
    output o_frozen;
    output [2:0] o_trials;
    output [1:0] o_state;

    wire [31:0] saved_password;
    wire load_en;

    // The FSM drives all the decisions: it compares, counts the wrong
    // attempts and tells the register when to store a new password
    password_fsm u_fsm(
        .i_input(i_input),
        .i_saved(saved_password),
        .i_set_en(i_set_en),
        .i_reset(i_reset),
        .i_clk(i_clk),
        .o_access(o_access),
        .o_alarm(o_alarm),
        .o_frozen(o_frozen),
        .o_load(load_en),
        .o_trials(o_trials),
        .o_state(o_state)
    );

    // Holds the password that is currently saved
    password_reg u_reg(
        .i_data(i_input),
        .i_load(load_en),
        .i_reset(i_reset),
        .i_clk(i_clk),
        .o_password(saved_password)
    );

endmodule
