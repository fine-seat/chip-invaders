module chipinvaders (
    input clk,
    input input_left,
    input input_right,
    input input_fire,
);

localparam alien_row_size = 5;
localparam alien_column_size = 3;

localparam coordinate_size = 10;
localparam alive_size = 1;

logic alien_array [0:alien_row_size*alien_column_size*(2*coordinate_size+alive_size)-1];
logic cannon_array [0:2*coordinate_size+alive_size-1];
  
endmodule