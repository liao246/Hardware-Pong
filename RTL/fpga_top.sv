`default_nettype none

module fpga_top (
    input  logic hz100, reset,
    input  logic [20:0] pb,
    output logic [7:0] left, right,
            ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,

    output logic red, green, blue,

    output logic [7:0] txdata,
    input  logic [7:0] rxdata,
    output logic txclk, rxclk,
    input  logic txready, rxready
);

    // Internal signals
    logic [2:0]  rgb_out;
    logic hsync_out, vsync_out;
    logic [9:0]  current_x, current_y;
    logic display_on;
    logic vsync_pulse;
    logic [9:0]  ball_x, ball_y;
    logic [9:0]  paddle1_y, paddle2_y;
    logic [1:0]  player1_ctrl, player2_ctrl;

    // Player 1 controls (right paddle)
    // UP = 2'b01 (bit 0), DOWN = 2'b10 (bit 1)
    assign player1_ctrl[0] = pb[7]; // up
    assign player1_ctrl[1] = pb[3]; // down

    // Player 2 controls (left paddle)
    assign player2_ctrl[0] = pb[4]; // up
    assign player2_ctrl[1] = pb[0]; // down

    // Route VGA sync signals to the 'left' breakout header
    assign left[7:5] = 3'b0;
    assign left[4] = rgb_out[2];
    assign left[3] = rgb_out[1];
    assign left[2] = rgb_out[0];
    assign left[1] = hsync_out;
    assign left[0] = vsync_out;

    // RGB output to VGA
    assign {red, green, blue} = rgb_out;

    // Unused pin tie-offs
    assign right = 8'b0;
    assign ss7 = 8'b0;
    assign ss6 = 8'b0;
    assign ss5 = 8'b0;
    assign ss4 = 8'b0;
    assign ss3 = 8'b0;
    assign ss2 = 8'b0;
    assign ss1 = 8'b0;
    assign ss0 = 8'b0;
    assign txdata = 8'b0;
    assign txclk  = 1'b0;
    assign rxclk  = 1'b0;

    // VGA timing controller
    vga #(
        .DIVISOR(1),
        .WIDTH(10),
        .H_TOTAL(800),
        .V_TOTAL(524),
        .H_DISPLAY(640),
        .V_DISPLAY(480),
        .H_SYNC_START(656),
        .H_SYNC_END(752),
        .V_SYNC_START(491),
        .V_SYNC_END(493)
    ) vga_inst (
        .clk(hz100),
        .rst(reset),
        .hsync(hsync_out),
        .vsync(vsync_out),
        .display_on(display_on),
        .current_x(current_x),
        .current_y(current_y)
    );

    // Rising edge detector on vsync for game tick
    edge_detector edge_det_inst (
        .clk(hz100),
        .rst(reset),
        .signal_in(vsync_out),
        .pulse_out(vsync_pulse)
    );

    // Pong game physics and state machine
    game_physics #(
        .X_MAX(640),
        .Y_MAX(480),
        .X_MIN(0),
        .Y_MIN(0),
        .X_CENTER(320),
        .Y_CENTER(240),
        .BALL_SPEED(2),
        .BALL_SIZE(10),
        .PADDLE_MOVEMENT(6),
        .PADDLE_WIDTH(10),
        .PADDLE_HEIGHT(60),
        .LEFT_PADDLE_X(20),
        .RIGHT_PADDLE_X(610),
        .MAX_BALL_SPEED(8)
    ) game_physics_inst (
        .clk(hz100),
        .rst(reset),
        .vsync_pulse(vsync_pulse),
        .start_btn(pb[19]),
        .player1_ctrl(player1_ctrl),
        .player2_ctrl(player2_ctrl),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle1_y(paddle1_y),
        .paddle2_y(paddle2_y)
    );

    // Pixel generator for paddles and ball
    pixel_gen #(
        .WIDTH(640),
        .HEIGHT(480),
        .COORD_BITS(10),
        .PADDLE_WIDTH(10),
        .PADDLE_LENGTH(60),
        .BALL_SIZE(10),
        .LEFT_PADDLE_X(20),
        .RIGHT_PADDLE_X(610)
    ) pixel_gen_inst (
        .display_on(display_on),
        .paddle1_y(paddle1_y),
        .paddle2_y(paddle2_y),
        .current_y(current_y),
        .ball_y(ball_y),
        .current_x(current_x),
        .ball_x(ball_x),
        .rgb(rgb_out)
    );

endmodule
