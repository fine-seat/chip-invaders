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

    logic clk_wiz_out;

    design_1_clk_wiz_0_0_clk_wiz clk_wiz (
        .clk_out1(clk_wiz_out),
        .reset(~rst_n),
        .locked(),
        .clk_in1(clk)
    );

endmodule
