module chipinvaders (
    input clk,
    input input_left,
    input input_right,
    input input_fire
);

localparam alien_row_size = 5;
localparam alien_column_size = 3;

typedef struct packed {
    shortint x_pos;
    shortint y_pos;
    bit alive;
} character;

character alien_array [0:alien_row_size*alien_column_size-1];
character cannon;

initial begin
    cannon.x_pos = 100;
    cannon.y_pos = 100;
    cannon.alive = 1;
end

always @(posedge clk) begin
    if (input_left == 1) begin
        cannon.x_pos <= cannon.x_pos - 5;
    end
    if (input_right == 1) begin
        cannon.x_pos <= cannon.x_pos + 5;
    end
end

endmodule