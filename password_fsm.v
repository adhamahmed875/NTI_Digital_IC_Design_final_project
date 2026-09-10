module password_fsm(
    i_input,
    i_saved,
    i_set_en,
    i_reset,
    i_clk,
    o_access,
    o_alarm,
    o_frozen,
    o_load,
    o_trials,
    o_state
);

    input [31:0] i_input;
    input [31:0] i_saved;
    input i_set_en;
    input i_reset;
    input i_clk;

    output reg o_access;
    output reg o_alarm;
    output reg o_frozen;
    output o_load;
    output reg [2:0] o_trials;
    output [1:0] o_state;

    reg [1:0] current_state;
    reg [1:0] next_state;
    reg r_access;
    reg r_alarm;
    reg r_frozen;
    reg r_load;
    reg [2:0] r_trials;

    // State encoding for the three remaining states
    localparam [1:0] INITIAL = 2'b00;
    localparam [1:0] VERIFY  = 2'b01;
    localparam [1:0] FREEZE  = 2'b10;

    // Register the state and the Mealy outputs on every clock edge
    always @ (posedge i_clk) begin
        current_state <= next_state;
        o_access <= r_access;
        o_alarm <= r_alarm;
        o_frozen <= r_frozen;
        o_trials <= r_trials;
    end

    // Combinational next-state and output logic
    always @ (current_state or i_input or i_saved or i_set_en or i_reset) begin
        if (i_reset) begin

            r_access = 0;
            r_alarm = 0;
            r_frozen = 0;
            r_load = 0;
            r_trials = 0;
            next_state = INITIAL;

        end else begin

            r_access = 0;
            r_alarm = 0;
            r_frozen = 0;
            r_load = 0;
            r_trials = o_trials;

            case (current_state)

                // Wait here until the very first password is programmed
                INITIAL: begin
                    if (i_set_en) begin
                        r_load = 1;
                        next_state = VERIFY;
                    end else begin
                        next_state = INITIAL;
                    end
                end

                // Compare the entered value against the saved password
                VERIFY: begin
                    if (i_input == i_saved) begin
                        r_access = 1;
                        r_trials = 0;
                        next_state = VERIFY;
                    end else begin
                        r_access = 0;
                        r_trials = o_trials + 1;
                        if (o_trials == 3'd3) begin
                            r_alarm = 1;
                            next_state = FREEZE;
                        end else begin
                            next_state = VERIFY;
                        end
                    end
                end

                // Locked state, only i_reset can leave it
                FREEZE: begin
                    r_alarm = 1;
                    r_frozen = 1;
                    r_trials = o_trials;
                    next_state = FREEZE;
                end

                default: begin
                    next_state = INITIAL;
                end

            endcase
        end
    end

    assign o_state = current_state;
    assign o_load = r_load;

endmodule
