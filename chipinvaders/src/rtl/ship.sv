`default_nettype none

module ship (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       v_sync,
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic       move_left,
    input  logic       move_right,
    output logic [9:0] ship_x_pos,
    output logic       ship_on
);

    localparam logic [9:0] SHIP_Y  = 10'd440;
    localparam logic [9:0] SPEED   = 10'd4;
    localparam int         WIDTH   = 13;
    localparam int         HEIGHT  = 8;

    logic [9:0] x_reg;

    always_ff @(posedge v_sync or negedge rst_n) begin
        if (~rst_n) begin
            x_reg <= 10'd312;
        end else begin
            if (move_left && x_reg > SPEED) 
                x_reg <= x_reg - SPEED;
            else if (move_right && x_reg < (10'd640 - WIDTH)) 
                x_reg <= x_reg + SPEED;
        end
    end

    assign ship_x_pos = x_reg;

    function logic get_sprite_pixel(input logic [3:0] row, input logic [9:0] col);
        case (row)
            4'd0: return (col == 4'd6);
            4'd1: return (col >= 4'd5 && col <= 4'd7);
            4'd2: return (col >= 4'd5 && col <= 4'd7);
            4'd3: return (col >= 4'd1 && col <= 4'd11);
            4'd4: return 1'b1; // Fila completa
            4'd5: return 1'b1; // Fila completa
            4'd6: return 1'b1; // Fila completa
            4'd7: return 1'b1; // Fila completa
            default: return 1'b0;
        endcase
    endfunction

    always_comb begin
        if (pix_x >= x_reg && pix_x < x_reg + WIDTH && 
            pix_y >= SHIP_Y && pix_y < SHIP_Y + HEIGHT) begin
            ship_on = get_sprite_pixel(pix_y[3:0] - SHIP_Y[3:0], pix_x - x_reg);
        end else begin
            ship_on = 1'b0;
        end
    end

endmodule