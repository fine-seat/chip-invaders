module alien(
    input logic clk,
    input logic rst_n,
    input logic hit,
    input logic dir, // 0 = left, 1 = right
    input logic fire,

    output logic alive = 1,
    output logic fired = 0
);

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        alive <= 1;
        fired <= 0;
    end else begin
        if (hit) begin
            alive <= 0;
        end

        fired <= fire && alive;
    end

end

endmodule