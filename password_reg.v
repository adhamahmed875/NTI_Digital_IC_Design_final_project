module password_reg(
    i_data,
    i_load,
    i_reset,
    i_clk,
    o_password
);

    input [31:0] i_data;
    input i_load;
    input i_reset;
    input i_clk;

    output reg [31:0] o_password;

    // Store a new password only when the FSM requests a load, use a known
    // default value after reset so VERIFY has something to compare against
    always @ (posedge i_clk) begin
        if (i_reset) begin
            o_password <= 32'h1234abcd;
        end else if (i_load) begin
            o_password <= i_data;
        end
    end

endmodule
