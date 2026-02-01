`timescale 1 ns / 10 ps  // 1 ns time unit, 10 ps precision

module neuron_proc_tb;
  localparam int MAX_NEURON_INPUTS = 8;
  localparam int PW = 8;
  localparam int THRESHHOLD_WIDTH = $clog2(MAX_NEURON_INPUTS + 1);
  localparam int period = 10;

  logic [PW-1:0] inputs = 0;
  logic [PW-1:0] weights = 0;
  logic [THRESHHOLD_WIDTH-1:0] threshhold = 0;
  logic valid_in = 0;
  logic last = 0;
  logic clk = 1'b0;
  logic rst;
  logic valid_out;
  logic y;
  logic [THRESHHOLD_WIDTH-1:0] popcount;

  neuron_proc #(
      .MAX_NEURON_INPUTS(MAX_NEURON_INPUTS),
      .PW(PW),
      .THRESHHOLD_WIDTH(THRESHHOLD_WIDTH)
  ) DUT (
      .*
  );

  // Generate a clock with a 10 ns period
  initial begin : generate_clock
    forever #5 clk <= ~clk;
  end

  initial begin : apply_tests
    $timeformat(-9, 0, " ns");

    rst <= 1'b1;
    @(negedge clk);
    rst <= 1'b0;
    @(posedge clk);

    valid_in <= 1'b1;
    inputs <= 8'b11110000;
    weights <= 8'b11111111;
    threshhold <= 1;

    @(posedge clk);

    valid_in <= 1'b1;
    inputs <= 8'b11111111;
    weights <= 8'b11111111;
    threshhold <= 1;
    last <= 1;

    @(posedge clk);

    last <= 0;
    valid_in <= 0;

    // wait until rising edge when valid_out is 1
    @(posedge clk);
    while (!valid_out) begin
      @(negedge clk);
    end

    assert (y == 1'b1)
    else $fatal("y was incorrect! y = %b", y);

    assert (popcount == 12)
    else $fatal("popcount was incorrect! popcount = %0d", popcount);


    $display("TB ended");
    $finish;
  end
endmodule
