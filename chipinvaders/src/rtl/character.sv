module character #(
    parameter logic [15:0] SCALING = 1,
    parameter logic [15:0] X_POS   = 0,
    parameter logic [15:0] Y_POS   = 0
) (
    input logic v_sync,
    input logic [15:0] char,  // ascii
    input logic [15:0] hpos,
    input logic [15:0] vpos,

    output logic graphics
);

  localparam logic [15:0] SpriteWidth = 5;
  localparam logic [15:0] SpriteHeight = 5;
  localparam logic [15:0] NumDigits = 10;
  localparam logic [15:0] NumLetters = 26;

  logic [SpriteWidth-1:0] digits_rom [0:NumDigits-1][0:SpriteHeight-1];
  logic [SpriteWidth-1:0] letters_rom [0:NumLetters-1][0:SpriteHeight-1];

  initial begin
    $readmemb("src/rtl/digits.hex", digits_rom);
  end

  logic is_digit, is_letter;

  logic [15:0] digit_index, letter_index;

  logic [15:0] rel_x, rel_y;

  always_comb begin
    is_digit = (char >= "0") && (char <= "9");
    is_letter = (char >= "A") && (char <= "Z");

    rel_x = (hpos - X_POS) / SCALING;
    rel_y = (vpos - Y_POS) / SCALING;

    if (rel_y < SpriteHeight && rel_x < SpriteWidth)
      if (is_digit) begin
        digit_index = char[15:0] - "0";
        graphics = digits_rom[digit_index][rel_y][SpriteWidth-1-rel_x];
      end else if (is_letter) begin
        letter_index = char[15:0] - "A";
        graphics = digits_rom[letter_index][rel_y][SpriteWidth-1-rel_x];
      end else graphics = 0;
    else graphics = 0;
  end

endmodule
