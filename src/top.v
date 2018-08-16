module top (
    input  clk

    // Unused outputs
  , output [17:0] ADR
  , output [15:0] DAT
  , output RAMOE
  , output RAMWE
  , output RAMCS

    // All PMOD outputs
  , output [55:0] PMOD
  );

  // Set unused values to default
  assign ADR[17:0] = {18{1'bz}};
  assign DAT[15:0] = {16{1'bz}};
  assign RAMOE = 1'b1;
  assign RAMWE = 1'b1;
  assign RAMCS = 1'b1;
  assign PMOD[54:0] = {55{1'bz}};

  //
  // reset
  //

  wire reset;

  Reset_topEntity my_reset (
    .clk (clk),
    .rst (1'b0),
    .result (reset)
  );

  //
  // blink
  //

  Blink_topEntity my_blink (
    .clk (clk),
    .rst (reset),
    .r (PMOD[55])
  );

endmodule
