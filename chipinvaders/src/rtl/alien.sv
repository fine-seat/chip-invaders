module alien #(
    parameter INITIAL_POSITION_X,
    parameter INITIAL_POSITION_Y
)(
    input logic clk,
    input logic rst_n,

    input logic alive,
    input logic [15:0] movement_frequency,
    input logic movement_direction, // 0 = left, 1 = right
    input logic armed, // 0 = unable to fire, 1 = capable of firing

    output logic [9:0] position_x = INITIAL_POSITION_X,
    output logic [9:0] position_y = INITIAL_POSITION_Y,
    output logic graphics
);

// internal signals for next state
logic [9:0] next_position_x;
logic [9:0] next_position_y;

// movement counter for frequency control
logic [15:0] movement_counter;

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