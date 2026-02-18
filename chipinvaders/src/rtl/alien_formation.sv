module alien_formation #(
    parameter NUM_ROWS = 3,
    parameter NUM_COLS = 5,
    parameter ALIEN_SPACING_X = 64,
    parameter ALIEN_SPACING_Y = 32,
    parameter START_X = 100,
    parameter START_Y = 50
)(
    input logic clk,
    input logic rst_n,

    // current scan position of VGA module
    input logic [9:0] scan_x,
    input logic [9:0] scan_y,

    // matrices representing individual alien status
    output logic [NUM_ROWS-1:0][NUM_COLS-1:0] alive_matrix,
    output logic [15:0] alien_positions_x [NUM_ROWS-1:0][NUM_COLS-1:0],
    output logic [15:0] alien_positions_y [NUM_ROWS-1:0][NUM_COLS-1:0],
    output logic alien_pixel
);

    logic [3:0] level;
    logic [15:0] movement_frequency = 100;
    logic [1:0] movement_direction = 1;
    logic [NUM_ROWS-1:0][NUM_COLS-1:0] armed_matrix;
    logic [NUM_ROWS-1:0][NUM_COLS-1:0] alien_graphics;

    // update armed-matrix based on alive-matrix
    always_comb begin
        for (int active_column = 0; active_column < NUM_COLS; active_column++) begin
            for (int active_row = 0; active_row < NUM_ROWS; active_row++) begin
                armed_matrix[active_row][active_column] = alive_matrix[active_row][active_column];
                for (int lower_row = active_row + 1; lower_row < NUM_ROWS; lower_row++) begin
                    if (alive_matrix[lower_row][active_column]) begin
                        armed_matrix[active_row][active_column] = 1'b0;
                    end
                end
            end
        end
    end

    // create alien-matrix
    genvar row, col;
    generate
        for (row = 0; row < NUM_ROWS; row++) begin : alien_rows
            for (col = 0; col < NUM_COLS; col++) begin : alien_cols

                // calculate initial position for each alien
                localparam INITIAL_POSITION_X = START_X + (col * ALIEN_SPACING_X);
                localparam INITIAL_POSITION_Y = START_Y + (row * ALIEN_SPACING_Y);

                // create aliens
                alien #(
                    .INITIAL_POSITION_X(INITIAL_POSITION_X),
                    .INITIAL_POSITION_Y(INITIAL_POSITION_Y)
                ) alien_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .alive(alive_matrix[row][col]),
                    .movement_frequency(movement_frequency),
                    .movement_direction(movement_direction),
                    .armed(armed_matrix[row][col]),
                    .scan_x(scan_x),
                    .scan_y(scan_y),
                    .position_x(alien_positions_x[row][col]),
                    .position_y(alien_positions_y[row][col]),
                    .graphics(alien_graphics[row][col])
                );

            end
        end
    endgenerate

    // Combine all alien graphics into single output bit
    always_comb begin
        alien_pixel = alien_graphics[0][0] | alien_graphics[0][1] | alien_graphics[0][2] | 
                      alien_graphics[0][3] | alien_graphics[0][4] |
                      alien_graphics[1][0] | alien_graphics[1][1] | alien_graphics[1][2] | 
                      alien_graphics[1][3] | alien_graphics[1][4] |
                      alien_graphics[2][0] | alien_graphics[2][1] | alien_graphics[2][2] | 
                      alien_graphics[2][3] | alien_graphics[2][4];
    end

    always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            level <= 0;
        end else begin
            level <= 1;
            // basic level management
        end
    end

endmodule