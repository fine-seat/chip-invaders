
module alien_projectile #(
    parameter logic [15:0] SPRITE_WIDTH = 16,
    parameter logic [15:0] SPRITE_HEIGHT = 16,
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
    input logic fire_projectile,

    input logic movement_direction_x, // 0 = left, 1 = right
    input logic movement_direction_y, // 0 = stay, 1 = down
    input logic [15:0] movement_frequency,
    input logic [15:0] movement_width,

    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    output logic graphics,
    output logic projectile_active,
    output logic [15:0] projectile_position_x,
    output logic [15:0] projectile_position_y,

    output logic projectile_graphics
);

  logic [15:0] movement_counter;
  logic signed [15:0] relative_position_x;
  logic signed [15:0] relative_position_y;
  logic in_sprite_bounds;

  // sprite ROM
  logic [SPRITE_WIDTH-1:0] sprite_rom [0:SPRITE_HEIGHT-1];
  initial begin
    $readmemb("src/rtl/projectile.hex", sprite_rom);
  end

  always_comb begin
    relative_position_x = (scan_x - projectile_position_x) / SCALING_FACTOR;
    relative_position_y = (scan_y - projectile_position_y) / SCALING_FACTOR;

    // check if current scan position is within sprite bounds
    in_sprite_bounds = (relative_position_x >= 0) && (relative_position_x < SPRITE_WIDTH) &&
                       (relative_position_y >= 0) && (relative_position_y < SPRITE_HEIGHT) &&
                       projectile_active;

    // output graphics signal based on sprite ROM
    projectile_graphics = in_sprite_bounds ? ~sprite_rom[relative_position_y[3:0]][relative_position_x[3:0]] : 1'b0;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      projectile_position_x <= INITIAL_POSITION_X;
      projectile_position_y <= INITIAL_POSITION_Y;
      movement_counter <= 0;
      projectile_active <= 0;
    end else begin
      if (projectile_active) begin
        if (movement_counter >= movement_frequency) begin
          movement_counter <= 0;
          projectile_position_y <= projectile_position_y + (4 * SCALING_FACTOR);
        end else begin
          movement_counter <= movement_counter + 1;
        end

        if (projectile_position_y >= MAX_POSITION_Y) begin
          projectile_active <= 0;
        end
      end else begin
        projectile_position_x <= alien_position_x;
        projectile_position_y <= alien_position_y + (SPRITE_HEIGHT * SCALING_FACTOR);
        movement_counter <= 0;
        if (fire_projectile) begin
          projectile_active <= 1;
        end
      end
    end
  end

endmodule
