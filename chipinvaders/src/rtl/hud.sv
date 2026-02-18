`default_nettype none

/**
 * Module: hud
 * Description: UI Head-Up Display for the game (Score and Lives).
 * This module receives screen coordinates and game state to output RGB signals.
 * You can change the colors, and need to give it coordinates, the lives and score, its just a hud that shows information on the screen
 * It also has a scaling variable
 */
module hud (
    input  logic [9:0] pix_x,      // Current beam X position
    input  logic [9:0] pix_y,      // Current beam Y position
    input  logic [1:0] lives,      // Current player lives (0-3)
    input  logic [7:0] score,      // Current player score (0-255)
    input  logic [3:0] scale,      // Scaling factor (e.g., 2, 4)
    output logic [2:0] rgb         // RGB output [2]=R, [1]=G, [0]=B
);

    // --- DIMENSIONS AND POSITIONS ---
    localparam int CHAR_WIDTH  = 5;
    localparam int CHAR_HEIGHT = 7;
    localparam int SHIP_WIDTH  = 13;
    localparam int SHIP_HEIGHT = 8;

    localparam logic [9:0] HUD_Y_POS     = 10'd20;
    localparam logic [9:0] SCORE_X_START = 10'd40;
    localparam logic [9:0] LIVES_X_START = 10'd500;

    // --- INTERNAL SIGNALS ---
    logic letter_on;
    logic [9:0] scaled_char_w, scaled_char_h;
    logic [9:0] scaled_ship_w, scaled_ship_h;

    assign scaled_char_w = CHAR_WIDTH  * scale;
    assign scaled_char_h = CHAR_HEIGHT * scale;
    assign scaled_ship_w = SHIP_WIDTH  * scale;
    assign scaled_ship_h = SHIP_HEIGHT * scale;

    // --- SHIP BITMAP (For Lives) ---
    logic [12:0] ship_bitmap [8];
    always_comb begin
        ship_bitmap[0] = 13'b0000001000000;
        ship_bitmap[1] = 13'b0000011100000;
        ship_bitmap[2] = 13'b0000011100000;
        ship_bitmap[3] = 13'b0111111111110;
        ship_bitmap[4] = 13'b1111111111111;
        ship_bitmap[5] = 13'b1111111111111;
        ship_bitmap[6] = 13'b1111111111111;
        ship_bitmap[7] = 13'b1111111111111;
    end

    // --- RENDERING LOGIC ---
    always_comb begin
        letter_on = 1'b0;
        rgb = 3'b000; // Default: transparent/black

        // --- SCORE SECTION (Characters) ---
        if (pix_y >= HUD_Y_POS && pix_y < HUD_Y_POS + scaled_char_h) begin
            
            // Relative coordinates for character lookup
            logic [9:0] rel_x, rel_y;
            rel_y = (pix_y - HUD_Y_POS) / scale;

            // Render "S"
            if (pix_x >= SCORE_X_START && pix_x < SCORE_X_START + scaled_char_w) begin
                rel_x = (pix_x - SCORE_X_START) / scale;
                if (rel_y==0 || rel_y==3 || rel_y==6) letter_on = (rel_x > 0 && rel_x < 4);
                else if (rel_y < 3) letter_on = (rel_x == 0);
                else letter_on = (rel_x == 4);
            end
            // Render "C"
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 1.5) && pix_x < SCORE_X_START + (scaled_char_w * 2.5)) begin
                rel_x = (pix_x - (SCORE_X_START + (scaled_char_w * 1.5))) / scale;
                if (rel_y==0 || rel_y==6) letter_on = (rel_x > 0);
                else letter_on = (rel_x == 0);
            end
            // Render "O"
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 3) && pix_x < SCORE_X_START + (scaled_char_w * 4)) begin
                rel_x = (pix_x - (SCORE_X_START + (scaled_char_w * 3))) / scale;
                if (rel_y==0 || rel_y==6) letter_on = (rel_x > 0 && rel_x < 4);
                else letter_on = (rel_x == 0 || rel_x == 4);
            end
            // Render "R"
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 4.5) && pix_x < SCORE_X_START + (scaled_char_w * 5.5)) begin
                rel_x = (pix_x - (SCORE_X_START + (scaled_char_w * 4.5))) / scale;
                if (rel_y==0 || rel_y==3) letter_on = (rel_x < 4);
                else if (rel_y < 3) letter_on = (rel_x == 0 || rel_x == 4);
                else letter_on = (rel_x == 0 || (rel_x == (rel_y - 3)));
            end
            // Render "E"
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 6) && pix_x < SCORE_X_START + (scaled_char_w * 7)) begin
                rel_x = (pix_x - (SCORE_X_START + (scaled_char_w * 6))) / scale;
                if (rel_y==0 || rel_y==3 || rel_y==6) letter_on = 1'b1;
                else letter_on = (rel_x == 0);
            end
            // Render ":"
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 7.5) && pix_x < SCORE_X_START + (scaled_char_w * 8)) begin
                letter_on = (rel_y == 2 || rel_y == 5);
            end
            // Render "0" (Static score digit)
            else if (pix_x >= SCORE_X_START + (scaled_char_w * 8.5) && pix_x < SCORE_X_START + (scaled_char_w * 9.5)) begin
                rel_x = (pix_x - (SCORE_X_START + (scaled_char_w * 8.5))) / scale;
                if (rel_y==0 || rel_y==6) letter_on = (rel_x > 0 && rel_x < 4);
                else letter_on = (rel_x == 0 || rel_x == 4);
            end

            if (letter_on) rgb = 3'b110; // Yellow Text
        end

        // --- LIVES SECTION (Mini Ships) ---
        if (pix_y >= HUD_Y_POS && pix_y < HUD_Y_POS + scaled_ship_h) begin
            logic [9:0] ship_rel_x, ship_rel_y;
            ship_rel_y = (pix_y - HUD_Y_POS) / scale;

            // Display ship icons based on lives remaining
            if (lives >= 1 && pix_x >= LIVES_X_START && pix_x < LIVES_X_START + scaled_ship_w) begin
                ship_rel_x = (pix_x - LIVES_X_START) / scale;
                if (ship_bitmap[ship_rel_y][12 - ship_rel_x]) rgb = 3'b100; // Red
            end
            else if (lives >= 2 && pix_x >= LIVES_X_START + (scaled_ship_w * 1.5) && pix_x < LIVES_X_START + (scaled_ship_w * 2.5)) begin
                ship_rel_x = (pix_x - (LIVES_X_START + (scaled_ship_w * 1.5))) / scale;
                if (ship_bitmap[ship_rel_y][12 - ship_rel_x]) rgb = 3'b100;
            end
            else if (lives >= 3 && pix_x >= LIVES_X_START + (scaled_ship_w * 3) && pix_x < LIVES_X_START + (scaled_ship_w * 4)) begin
                ship_rel_x = (pix_x - (LIVES_X_START + (scaled_ship_w * 3))) / scale;
                if (ship_bitmap[ship_rel_y][12 - ship_rel_x]) rgb = 3'b100;
            end
        end
    end

endmodule
