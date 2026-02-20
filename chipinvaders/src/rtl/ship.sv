`default_nettype none

module ship (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       v_sync,
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic       move_left,
    input  logic       move_right,
    input  logic [3:0] scale,        // Scaling factor (1, 2, 4, etc.)
    output logic [9:0] ship_x_pos,   // Current X position for bullet spawning
    output logic       ship_on       // Pixel output signal for the VGA mixer
);

    // Original Sprite Dimensions (Unscaled)
    localparam int BASE_WIDTH  = 13;
    localparam int BASE_HEIGHT = 8;
    
    // Position and Speed
    localparam logic [9:0] SHIP_Y  = 10'd440;
    localparam logic [9:0] SPEED   = 10'd4;

    // Logic to calculate current scaled size
    logic [9:0] scaled_width;
    logic [9:0] scaled_height;
    
    assign scaled_width  = BASE_WIDTH  * scale;
    assign scaled_height = BASE_HEIGHT * scale;

    logic [9:0] x_reg;

    // --- MOVEMENT LOGIC ---
    // Update position on every Vertical Sync (once per frame)
    always_ff @(posedge v_sync or negedge rst_n) begin
        if (~rst_n) begin
            x_reg <= 10'd312; // Start at center screen
        end else begin
            if (move_left && x_reg > SPEED) 
                x_reg <= x_reg - SPEED;
            else if (move_right && x_reg < (10'd640 - scaled_width)) 
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

    // --- RENDERING LOGIC WITH SCALING ---
    always_comb begin
        // Check if current beam is inside the scaled bounding box
        if (pix_x >= x_reg && pix_x < x_reg + scaled_width && 
            pix_y >= SHIP_Y && pix_y < SHIP_Y + scaled_height) begin
            
            // Map screen coordinates back to bitmap coordinates using scale factor
            // Division by scale stretches the pixels
            ship_on = ship_bitmap[(pix_y - SHIP_Y) / scale][12 - ((pix_x - x_reg) / scale)];
            
        end else begin
            ship_on = 1'b0;
        end
    end

endmodule
