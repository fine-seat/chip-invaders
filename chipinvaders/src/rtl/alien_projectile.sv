
module alien_projectile #(
    parameter logic [15:0] SPRITE_WIDTH = 8,
    parameter logic [15:0] SPRITE_HEIGHT = 8,
    parameter logic [15:0] INITIAL_POSITION_X = 0,
    parameter logic [15:0] INITIAL_POSITION_Y = 0,
    parameter logic [15:0] MAX_POSITION_X = 640,
    parameter logic [15:0] MAX_POSITION_Y = 480,
    parameter logic [15:0] SCALING_FACTOR = 2
) (
    input logic clk,
    input logic rst_n,

    input logic [15:0] alien_position_x,
    input logic [15:0] alien_position_y,

    input logic movement_direction_x, // 0 = left, 1 = right
    input logic movement_direction_y, // 0 = stay, 1 = down
    input logic [15:0] movement_frequency,
    input logic [15:0] movement_width,

    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    output logic graphics,
    output logic projectile_armed,
    output logic [15:0] projectile_position_x,
    output logic [15:0] projectile_position_y,

    output logic projectile_gfx
);

  logic [15:0] movement_counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      projectile_position_x <= INITIAL_POSITION_X;
      projectile_position_y <= INITIAL_POSITION_Y;
      movement_counter <= 0;
    end else begin
      projectile_position_x <= projectile_position_x + 1;
      projectile_position_y <= projectile_position_y + 1;
    end
  end

endmodule
