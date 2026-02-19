module alien_formation #(
    parameter logic [15:0] NUM_ROWS = 3,
    parameter logic [15:0] NUM_COLUMNS = 5,
    parameter logic [15:0] ALIEN_SPACING_X = 64,
    parameter logic [15:0] ALIEN_SPACING_Y = 32,
    parameter logic [15:0] START_X = 100,
    parameter logic [15:0] START_Y = 50
)(
    input logic clk,
    input logic rst_n,

    // current scan position of VGA module
    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    // matrices representing individual alien status
    output logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] alive_matrix = '1,
    output logic [15:0] alien_positions_x [NUM_ROWS-1:0][NUM_COLUMNS-1:0],
    output logic [15:0] alien_positions_y [NUM_ROWS-1:0][NUM_COLUMNS-1:0],
    output logic alien_pixel
);

    logic [3:0] level;
    logic [15:0] movement_frequency = 100;
    logic movement_direction = 1;
    logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] armed_matrix;
    logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] graphics_matrix;

    // update armed-matrix based on alive-matrix
    always_comb begin
        for (int active_column = 0; active_column < NUM_COLUMNS; active_column++) begin
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
    genvar row, column;
    generate
        for (row = 0; row < NUM_ROWS; row++) begin : g_alien_rows
            for (column = 0; column < NUM_COLUMNS; column++) begin : g_alien_cols

                // calculate initial position for each alien
                localparam logic [15:0] InitialPositionX = START_X + (column * ALIEN_SPACING_X);
                localparam logic [15:0] InitialPositionY = START_Y + (row * ALIEN_SPACING_Y);

                // create aliens
                alien #(
                    .INITIAL_POSITION_X(InitialPositionX),
                    .INITIAL_POSITION_Y(InitialPositionY)
                ) alien_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .alive(alive_matrix[row][column]),
                    .movement_frequency(movement_frequency),
                    .movement_direction(movement_direction),
                    .armed(armed_matrix[row][column]),
                    .scan_x(scan_x),
                    .scan_y(scan_y),
                    .graphics(graphics_matrix[row][column])
                );

            end
        end
    endgenerate

    // Combine all alien graphics into single output bit
    always_comb begin
        alien_pixel = graphics_matrix[0][0] | graphics_matrix[0][1] | graphics_matrix[0][2] | 
                      graphics_matrix[0][3] | graphics_matrix[0][4] |
                      graphics_matrix[1][0] | graphics_matrix[1][1] | graphics_matrix[1][2] | 
                      graphics_matrix[1][3] | graphics_matrix[1][4] |
                      graphics_matrix[2][0] | graphics_matrix[2][1] | graphics_matrix[2][2] | 
                      graphics_matrix[2][3] | graphics_matrix[2][4];
    end

    always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            level <= 0;
            alive_matrix <= '1;
        end else begin
            level <= 1;
            // basic level management
        end
    end

endmodule
