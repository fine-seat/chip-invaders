module hvsync_generator (
    input clk,
    input reset,
    output logic hsync,
    output logic vsync,
    output logic display_on,
    output logic [9:0] hpos,
    output logic [9:0] vpos
);

  // declarations for TV-simulator sync parameters
  // horizontal constants
  localparam logic [15:0] HDisplay = 640;  // horizontal display width
  localparam logic [15:0] HBack = 48;  // horizontal left border (back porch)
  localparam logic [15:0] HFront = 16;  // horizontal right border (front porch)
  localparam logic [15:0] HSync = 96;  // horizontal sync width
  // verticallogic constants
  localparam logic [15:0] VDisplay = 480;  // vertical display height
  localparam logic [15:0] VTop = 33;  // vertical top border
  localparam logic [15:0] VBottom = 10;  // vertical bottom border
  localparam logic [15:0] VSync = 2;  // vertical sync # lines
  // derived constants
  localparam logic [15:0] HSyncStart = HDisplay + HFront;
  localparam logic [15:0] HSyncEnd = HDisplay + HFront + HSync - 1;
  localparam logic [15:0] HMax = HDisplay + HBack + HFront + HSync - 1;
  localparam logic [15:0] VSyncStart = VDisplay + VBottom;
  localparam logic [15:0] VSyncEnd = VDisplay + VBottom + VSync - 1;
  localparam logic [15:0] VMax = VDisplay + VTop + VBottom + VSync - 1;

  wire hmaxxed = (hpos == HMax) || reset;  // set when hpos is maximum
  wire vmaxxed = (vpos == VMax) || reset;  // set when vpos is maximum

  // horizontal position counter
  always @(posedge clk) begin
    hsync <= (hpos >= HSyncStart && hpos <= HSyncEnd);
    if (hmaxxed) hpos <= 0;
    else hpos <= hpos + 1;
  end

  // vertical position counter
  always @(posedge clk) begin
    vsync <= (vpos >= VSyncStart && vpos <= VSyncEnd);
    if (hmaxxed)
      if (vmaxxed) vpos <= 0;
      else vpos <= vpos + 1;
  end

  // display_on is set when beam is in "safe" visible frame
  assign display_on = (hpos < HDisplay) && (vpos < VDisplay);

endmodule
