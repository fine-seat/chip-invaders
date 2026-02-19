`default_nettype none

module game_state_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       v_sync,
    input  logic       trigger_in,         // Botón de disparo directo
    input  logic       game_over_trigger,  // Señal externa de fin
    output logic [1:0] state,              // 0: MENU, 1: GAME, 2: END
    output logic       blink_signal        // Señal para parpadeo
);

    localparam logic [1:0] STATE_MENU = 2'd0;
    localparam logic [1:0] STATE_GAME = 2'd1;
    localparam logic [1:0] STATE_END  = 2'd2;

    logic [5:0] blink_timer;
    assign blink_signal = blink_timer[5];

    // Detector de flanco interno en vsync
    logic prev_trigger;
    wire trigger_pulse = trigger_in & ~prev_trigger;

    always_ff @(posedge v_sync or negedge rst_n) begin
        if (~rst_n) begin
            state <= STATE_MENU;
            blink_timer <= 6'd0;
            prev_trigger <= 1'b0;
        end else begin
            blink_timer <= blink_timer + 1'b1;
            prev_trigger <= trigger_in; // Guardamos el estado anterior
            
            case (state)
                STATE_MENU: begin
                    if (trigger_pulse) state <= STATE_GAME;
                end
                STATE_GAME: begin
                    if (game_over_trigger) state <= STATE_END;
                end
                STATE_END: begin
                    if (trigger_pulse) state <= STATE_MENU;
                end
                default:   state <= STATE_MENU;
            endcase
        end
    end

endmodule
