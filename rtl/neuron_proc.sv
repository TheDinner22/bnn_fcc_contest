// TODO add registers to input and output for a total of 5 not 3
module neuron_proc #(
    parameter int MAX_NEURON_INPUTS = 8,
    parameter int PW = 8,

    parameter int THRESHHOLD_WIDTH = $clog2(MAX_NEURON_INPUTS + 1)
) (
    input logic [PW-1:0] inputs,
    input logic [PW-1:0] weights,
    input logic [THRESHHOLD_WIDTH-1:0] threshhold,
    input logic valid_in,
    input logic last,

    input logic clk,
    input logic rst,

    output logic valid_out,
    output logic y,
    output logic [THRESHHOLD_WIDTH-1:0] popcount
);
  /* comb logic signals */
  logic [        $bits(inputs)-1:0] xnor_res;
  logic [$clog2($bits(inputs))-1:0] xnors_popcount;
  logic [      $bits(popcount)-1:0] next_accum;
  logic                             cmp_result;

  /* registers */
  logic [     THRESHHOLD_WIDTH-1:0] accum_r;
  logic [                   PW-1:0] xnor_res_r;
  logic [     THRESHHOLD_WIDTH-1:0] popcount_res_r;

  always_comb begin
    xnor_res = inputs ~^ weights;
    xnors_popcount = $countones(xnor_res_r);
    next_accum = popcount_res_r;
    cmp_result = accum_r > threshhold;
    y = cmp_result;
    popcount = accum_r;
  end

  always_ff @(posedge clk or posedge rst) begin
    accum_r <= accum_r + next_accum;
    if (rst) accum_r <= 0;  // TODO implicit bit change

    xnor_res_r <= xnor_res;
    if (rst) xnor_res_r <= 0;  // TODO implicit bit change

    popcount_res_r <= xnors_popcount;
    if (rst) popcount_res_r <= 0;  // TODO implicit bit change
  end

  delay #(
      .CYCLES(3),
      .WIDTH (1)
  ) delay1 (

      .clk(clk),
      .rst(rst),
      .en (1'b1),
      .in (valid_in),
      .out(valid_out)
  );
endmodule

