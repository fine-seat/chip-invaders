module chipinvaders (
    input clk,
    input input_left,
    input input_right,
    input input_fire,
);

localparam alien_row_size = 5;
localparam alien_column_size = 3;

character alien_array [0:alien_row_size*alien_column_size-1];
character cannon;

struct {
    shortint x_pos;
    shortint y_pos;
    bit alive;
} character;

endmodule