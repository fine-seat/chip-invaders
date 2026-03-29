module cannon_display #(
    parameter logic [9:0] CANNON_Y = 10'd440,
    parameter logic [3:0] SCALE = 2
) (
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic [9:0] x_reg,
    output logic       cannon_graphics
);

  localparam int SpriteW = 16;
  localparam int SpriteH = 16;

  logic [SpriteW-1:0] sprite_rom[SpriteH];
  initial begin
    $readmemb("src/rtl/single_barrel_cannon.hex", sprite_rom);
  end

  logic signed [10:0] rel_x, rel_y;
  logic in_sprite_bounds;

  always_comb begin
    rel_x = (10'(pix_x) - x_reg) / SCALE;
    rel_y = (10'(pix_y) - CANNON_Y) / SCALE;

    in_sprite_bounds = (rel_x >= 0) && (rel_x < SpriteW) && (rel_y >= 0) && (rel_y < SpriteH);

    cannon_graphics = in_sprite_bounds ? ~sprite_rom[rel_y[3:0]][SpriteW-1-rel_x[3:0]] : 1'b0;
  end

endmodule
