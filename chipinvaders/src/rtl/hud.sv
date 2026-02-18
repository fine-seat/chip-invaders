`default_nettype none

module hud (
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic [1:0] lives,
    input  logic [7:0] score,
    output logic       hud_on
);

    // --- MINI SHIP BITMAP ---
    logic [12:0] mini_ship [8];
    assign mini_ship[0] = 13'b0000001000000;
    assign mini_ship[1] = 13'b0000011100000;
    assign mini_ship[2] = 13'b0000011100000;
    assign mini_ship[3] = 13'b0111111111110;
    assign mini_ship[4] = 13'b1111111111111;
    assign mini_ship[5] = 13'b1111111111111;
    assign mini_ship[6] = 13'b1111111111111;
    assign mini_ship[7] = 13'b1111111111111;

    // --- FONT FUNCTION CORREGIDA ---
    // Ahora recibe coordenadas de 0-6 (row) y 0-4 (col)
    function logic get_char_pixel(input logic [2:0] char_id, input logic [3:0] row, input logic [3:0] col);
        case (char_id)
            3'd0: // S
                case(row) 0,3,6: return (col>0 && col<4); 1,2: return (col==0); 4,5: return (col==4); default: return 0; endcase
            3'd1: // C
                case(row) 0,6: return (col>0); 1,2,3,4,5: return (col==0); default: return 0; endcase
            3'd2: // O
                case(row) 0,6: return (col>0 && col<4); 1,2,3,4,5: return (col==0 || col==4); default: return 0; endcase
            3'd3: // R
                case(row) 0,3: return (col<4); 1,2: return (col==0 || col==4); 4: return (col==0 || col==2); 5: return (col==0 || col==3); 6: return (col==0 || col==4); default: return 0; endcase
            3'd4: // E
                case(row) 0,3,6: return (col<5); default: return (col==0); endcase
            default: return 0;
        endcase
    endfunction

    always_comb begin
        hud_on = 1'b0;
        
        // --- SCORE TEXT (X: 50 a 95, Y: 20 a 26) ---
        if (pix_y >= 20 && pix_y <= 26) begin
            // Calculamos la fila local (0 a 6)
            logic [3:0] l_row;
            l_row = pix_y - 20;

            if (pix_x >= 50 && pix_x < 55)      hud_on = get_char_pixel(3'd0, l_row, pix_x - 50); // S
            else if (pix_x >= 60 && pix_x < 65) hud_on = get_char_pixel(3'd1, l_row, pix_x - 60); // C
            else if (pix_x >= 70 && pix_x < 75) hud_on = get_char_pixel(3'd2, l_row, pix_x - 70); // O
            else if (pix_x >= 80 && pix_x < 85) hud_on = get_char_pixel(3'd3, l_row, pix_x - 80); // R
            else if (pix_x >= 90 && pix_x < 95) hud_on = get_char_pixel(3'd4, l_row, pix_x - 90); // E
        end

        // --- LIVES ICONS ---
        if (pix_y >= 20 && pix_y < 28) begin
            if (lives >= 2'd1 && pix_x >= 500 && pix_x < 513)
                hud_on = mini_ship[pix_y - 20][12 - (pix_x - 500)];
            else if (lives >= 2'd2 && pix_x >= 520 && pix_x < 533)
                hud_on = mini_ship[pix_y - 20][12 - (pix_x - 520)];
            else if (lives >= 2'd3 && pix_x >= 540 && pix_x < 553)
                hud_on = mini_ship[pix_y - 20][12 - (pix_x - 540)];
        end
        
        // --- SCORE BAR ---
        if (pix_y >= 20 && pix_y < 28 && pix_x >= 110 && pix_x < 110 + (score << 1)) begin
            hud_on = 1'b1;
        end
    end

endmodule
