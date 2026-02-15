module alien(
    input logic clk,
    input logic rst_n,
    input logic [9:0] x_idx, // index in alien grid
    input logic [9:0] y_idx,
    input logic hit,
    input logic dir, // 0 = left, 1 = right

    output logic alive,
    output logic fired,
    output logic [9:0] x_pos,
    output logic [9:0] y_pos
);

// width + spacing: depending on bitmaps by Emil
localparam [9:0] width = 10'd10;
localparam [9:0] spacing = 10'd10; // space between aliens (vertical and horizontal)

function logic [9:0] get_position(input logic [9:0] idx);
    return (width+spacing)*idx;
endfunction

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_pos <= get_position(x_idx);
        y_pos <= get_position(y_idx);
        alive <= 1;
        fired <= 0;
    end else begin
        if (hit) begin
            alive <= 0;
        end
    end
end

endmodule