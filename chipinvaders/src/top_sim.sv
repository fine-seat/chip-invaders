module top_sim (
    input logic clk,
    input logic rst_n,

    input logic key_up,
    input logic key_left,
    input logic key_right,

    output logic [3:0] r,
    g,
    b,
    output logic hsync,
    output logic vsync
);

  chipinvaders game (
      .clk(clk),
      .rst_n(rst_n),
      .btn_u(key_up),
      .btn_l(key_left),
      .btn_r(key_right),
      .vga_r(r),
      .vga_g(g),
      .vga_b(b),
      .vga_hs(hsync),
      .vga_vs(vsync)
  );

endmodule
