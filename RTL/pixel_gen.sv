module pixel_gen #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480,
    parameter COORD_BITS = 10,
    parameter PADDLE_WIDTH = 10,
    parameter PADDLE_LENGTH = 60,
    parameter BALL_SIZE = 10,
    parameter LEFT_PADDLE_X = 20,
    parameter RIGHT_PADDLE_X = 610
) (
    input logic display_on,
    input logic [COORD_BITS-1:0] paddle1_y, paddle2_y, current_y, ball_y,
    input logic [COORD_BITS-1:0] current_x, ball_x,
    output logic [2:0] rgb
);

    always_comb begin
        if (~display_on)
            rgb = 3'b000;
        else if (current_x >= LEFT_PADDLE_X && current_x < LEFT_PADDLE_X + PADDLE_WIDTH &&
                 current_y >= paddle1_y && current_y < paddle1_y + PADDLE_LENGTH)
            rgb = 3'b111;
        else if (current_x >= RIGHT_PADDLE_X && current_x < RIGHT_PADDLE_X + PADDLE_WIDTH &&
                 current_y >= paddle2_y && current_y < paddle2_y + PADDLE_LENGTH)
            rgb = 3'b111;
        else if (current_x >= ball_x && current_x < ball_x + BALL_SIZE &&
                 current_y >= ball_y && current_y < ball_y + BALL_SIZE)
            rgb = 3'b111;
        else
            rgb = 3'b000;
    end    

endmodule
