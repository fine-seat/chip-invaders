module chipinvaders (
    input clk,
    input rst_n,

    // Buttons
    input btn_d,
    input btn_l,
    input btn_r,
    input btn_u,

    // VGA
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs
);

endmodule
