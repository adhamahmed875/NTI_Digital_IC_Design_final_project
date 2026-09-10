# Password Door Lock (Verilog)

A synchronous hexadecimal password door lock built as a Mealy finite state
machine, split across three modules.

## Overview

On power-up the system has no password saved. A 32-bit password is
programmed once through `i_set_en`, after which the system continuously
compares any new input against the saved password. Four wrong attempts in a
row trip an alarm and freeze the system completely; only a full reset can
recover it, and after that reset the password must be programmed again.

## States

- **INITIAL** — no password saved yet. Waits for `i_set_en` to program the
  first password, then moves to VERIFY.
- **VERIFY** — normal operating state. Compares every input against the
  saved password: a match grants access and resets the trial counter, a
  mismatch increments the trial counter.
- **FREEZE** — reached after 4 wrong attempts in VERIFY. Alarm stays on,
  access stays denied, and no input is accepted until `i_reset`.

## Files

| File | Role |
|---|---|
| `password_fsm.v` | The Mealy FSM: state register, trial counter, and all control outputs (`o_access`, `o_alarm`, `o_frozen`, `o_load`, `o_trials`, `o_state`) |
| `password_reg.v` | Stores the currently saved 32-bit password, loaded on `i_load` from the FSM |
| `password_top.v` | Top-level module wiring `password_fsm` and `password_reg` together |
| `testbench_top.v` | Testbench exercising password programming, 4 wrong attempts, freeze, and reset recovery |

## Interface (password_top)

**Inputs:** `i_input[31:0]`, `i_set_en`, `i_reset`, `i_clk`
**Outputs:** `o_access`, `o_alarm`, `o_frozen`, `o_trials[2:0]`, `o_state[1:0]`
