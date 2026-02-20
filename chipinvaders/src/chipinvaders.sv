module chipinvaders (
    input logic clk,
    input logic rst_n,

    // Buttons
    //input logic btn_d,
    input logic btn_l,
    input logic btn_r,
    input logic btn_u,

    // VGA
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic vga_hs,
    output logic vga_vs
);

  // Generate a 25 MHz clock from the 100 MHz input
  //logic [1:0] counter;
  logic clk_25mhz;

  // always_ff @(posedge clk or negedge rst_n) begin
  //   if (!rst_n) begin
  //     counter <= 0;
  //   end else begin
  //     counter <= counter + 1;
  //   end
  // end

  // assign clk_25mhz = counter[1];
  assign clk_25mhz = clk;


  // VGA signals
  logic hsync;
  logic vsync;
  logic display_on;
  logic [9:0] hpos;
  logic [9:0] vpos;

  hvsync_generator hvsync_gen (
      .clk(clk_25mhz),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(display_on),
      .hpos(hpos),
      .vpos(vpos)
  );

  // All game signals
  logic reset_game;

  // Cannon modules
  logic [9:0] cannon_x;
  logic cannon_gfx;

  ship cannon (
      .rst_n(rst_n),
      .v_sync(vsync),
      .pix_x(hpos),
      .pix_y(vpos),
      .move_left(btn_l),
      .move_right(btn_r),
      .ship_x_pos(cannon_x),
      .ship_on(cannon_gfx),
      .scale(4)
  );

  logic laser_active;
  logic [9:0] laser_x;
  logic [9:0] laser_y;
  logic laser_gfx;

  cannon_laser #(
      .CANNON_Y(440)
  ) laser (
      .reset_n(rst_n),
      .vpos(vpos),
      .hpos(hpos),
      .vsync(vsync),
      .shoot(btn_u),
      .cannon_x(cannon_x),
      .hit_alien(1'b0),
      .laser_active(laser_active),
      .laser_x(laser_x),
      .laser_y(laser_y),
      .laser_gfx(laser_gfx)
  );

  // Scoreboard and Lives
  logic [1:0] lives = 3;
  logic [7:0] score = 10;
  logic [2:0] hud_rgb;

  hud hud (
      .pix_x(hpos),
      .pix_y(vpos),
      .lives(lives),
      .score(score),
      .scale(2),
      .rgb  (hud_rgb)
  );

  // Game Start and Game Over
  logic [1:0] game_state;  // 00 = start, 01 = playing, 10 = game over
  logic blink_signal;
  logic [1:0] disp_r;
  logic [1:0] disp_g;
  logic [1:0] disp_b;

  game_display game_disp (
      .rst_n(rst_n),
      .v_sync(vsync),
      .pix_x(hpos),
      .pix_y(vpos),
      .state(game_state),
      .blink_signal(blink_signal),
      .r(disp_r),
      .g(disp_g),
      .b(disp_b)
  );

  logic game_over_trigger = (lives == 0);

  game_state_machine state_machine (
      .rst_n(rst_n),
      .v_sync(vsync),
      .trigger_in(btn_u),
      .game_over_trigger(game_over_trigger),
      .state(game_state),
      .blink_signal(blink_signal),
      .reset_game(reset_game)
  );

  // RGB output logic
  logic game_gfx = laser_gfx || cannon_gfx;

  assign vga_r  = (display_on && (laser_gfx || hud_rgb[2] || disp_r[1])) ? 4'b1111 : 4'b0000;
  assign vga_g  = (display_on && (cannon_gfx || hud_rgb[1] || disp_g[1])) ? 4'b1111 : 4'b0000;
  assign vga_b  = (display_on && (hud_rgb[0] || disp_b[1])) ? 4'b1111 : 4'b0000;

  assign vga_hs = hsync;
  assign vga_vs = vsync;

endmodule
