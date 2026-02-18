module alien #(
    parameter logic [15:0] INITIAL_POSITION_X = 0,
    parameter logic [15:0] INITIAL_POSITION_Y = 0,
    parameter logic [15:0] SPRITE_WIDTH = 16,
    parameter logic [15:0] SPRITE_HEIGHT = 16
)(
    input logic clk,
    input logic rst_n,

    input logic alive,
    input logic [15:0] movement_frequency,
    input logic movement_direction, // 0 = left, 1 = right
    input logic armed, // 0 = unable to fire, 1 = capable of firing

    input logic [9:0] scan_x,
    input logic [9:0] scan_y,
    output logic [15:0] position_x = INITIAL_POSITION_X,
    output logic [15:0] position_y = INITIAL_POSITION_Y,
    output logic graphics
);

// internal signals for next state
logic [15:0] next_position_x;
logic [15:0] next_position_y;

// movement counter for frequency control
logic [15:0] movement_counter;

// Sprite ROM
logic [SPRITE_WIDTH-1:0] sprite_rom [0:SPRITE_HEIGHT-1];
initial begin
    $readmemb("src/rtl/basic_alien.hex", sprite_rom);
end

// Calculate relative position within sprite
logic signed [10:0] rel_x, rel_y;
logic in_sprite_bounds;

always_comb begin
    rel_x = scan_x - position_x;
    rel_y = scan_y - position_y;

    // Check if current scan position is within sprite bounds
    in_sprite_bounds = (rel_x >= 0) && (rel_x < SPRITE_WIDTH) && 
                       (rel_y >= 0) && (rel_y < SPRITE_HEIGHT) &&
                       alive;

    // Output graphics signal based on sprite ROM
    graphics = in_sprite_bounds ? sprite_rom[rel_y[3:0]][rel_x[3:0]] : 1'b0;
end

// combinational logic for movement calculation
always_comb begin
    next_position_x = position_x;
    next_position_y = position_y;

    // move when counter reaches frequency threshold
    if (movement_counter >= movement_frequency && alive) begin
        if (movement_direction) begin
            next_position_x = position_x + 1;  // move right
        end else begin
            next_position_x = position_x - 1;  // move left
        end
    end
end

// sequential logic for state updates
always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        position_x <= INITIAL_POSITION_X;
        position_y <= INITIAL_POSITION_Y;
        movement_counter <= 0;
    end else begin
        // update positions
        position_x <= next_position_x;
        position_y <= next_position_y;

        // update movement counter
        if (movement_counter >= movement_frequency) begin
            movement_counter <= 0;
        end else begin
            movement_counter <= movement_counter + 1;
        end

    end
end

endmodule
