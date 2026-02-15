`default_nettype none

module ship (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       v_sync,
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic       move_left,
    input  logic       move_right,
    output logic [9:0] ship_x_pos, // Current X position for bullet spawning
    output logic       ship_on      // Pixel output signal for the VGA mixer
);

    // Ship Configuration
    localparam logic [9:0] SHIP_Y  = 10'd440; // Fixed vertical position near bottom
    localparam logic [9:0] SPEED   = 10'd4;   // Movement speed (pixels per frame)
    localparam int         WIDTH   = 13;      // Sprite width
    localparam int         HEIGHT  = 8;       // Sprite height

    logic [9:0] x_reg;

    // --- MOVEMENT LOGIC ---
    // Update position on every Vertical Sync (once per frame)
    always_ff @(posedge v_sync or negedge rst_n) begin
        if (~rst_n) begin
            x_reg <= 10'd312; // Start at center screen
        end else begin
            if (move_left && x_reg > SPEED) 
                x_reg <= x_reg - SPEED;
            else if (move_right && x_reg < (10'd640 - WIDTH)) 
                x_reg <= x_reg + SPEED;
        end
    end

    assign ship_x_pos = x_reg;

    // --- SPRITE BITMAP ---
    // Each line defines a row of pixels (13-bit wide vector)
    logic [12:0] ship_bitmap [8];
    
    always_comb begin
        ship_bitmap[0] = 13'b0000001000000; //       #       
        ship_bitmap[1] = 13'b0000011100000; //      ###      
        ship_bitmap[2] = 13'b0000011100000; //      ###      
        ship_bitmap[3] = 13'b0111111111110; //  ###########  
        ship_bitmap[4] = 13'b1111111111111; // ############# 
        ship_bitmap[5] = 13'b1111111111111; // ############# 
        ship_bitmap[6] = 13'b1111111111111; // ############# 
        ship_bitmap[7] = 13'b1111111111111; // ############# 
    end

    // --- RENDERING LOGIC ---
    always_comb begin
        // Check if the current beam (pix_x, pix_y) is inside the ship's bounding box
        if (pix_x >= x_reg && pix_x < x_reg + WIDTH && 
            pix_y >= SHIP_Y && pix_y < SHIP_Y + HEIGHT) begin
            
            // Access the specific bit in the bitmap:
            // 1. [pix_y - SHIP_Y] selects the row (0 to 7)
            // 2. [12 - (pix_x - x_reg)] selects the column (0 to 12)
            // Subtracting from 12 ensures the MSB is drawn on the left (prevents mirroring)
            ship_on = ship_bitmap[pix_y - SHIP_Y][12 - (pix_x - x_reg)];
            
        end else begin
            ship_on = 1'b0;
        end
    end

endmodule
