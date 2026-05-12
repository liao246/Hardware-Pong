module game_physics #(
    parameter X_MAX = 800,
    parameter Y_MAX = 600,
    parameter X_MIN = 0,
    parameter Y_MIN = 0,
    parameter X_CENTER = 400,
    parameter Y_CENTER = 300,
    parameter BALL_SPEED = 2,
    parameter BALL_SIZE = 10,
    parameter PADDLE_MOVEMENT = 4,
    parameter PADDLE_WIDTH = 10,
    parameter PADDLE_HEIGHT = 60,
    parameter LEFT_PADDLE_X = 20,
    parameter RIGHT_PADDLE_X = 770,
    parameter MAX_BALL_SPEED = 8
)(
    input logic clk, rst,
    input logic vsync_pulse,
    input logic start_btn,
    input logic [1:0] player1_ctrl, player2_ctrl,
    output logic [9:0] ball_x, ball_y,
    output logic [9:0] paddle1_y, paddle2_y
);

    localparam UP = 2'b01;
    localparam DOWN = 2'b10;

    typedef enum logic {
        STATE_IDLE = 1'b0,
        STATE_PLAY = 1'b1
    } state_t;

    state_t current_state, next_state;
    logic game_enable;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) current_state <= STATE_IDLE;
        else     current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;

        case (current_state)
            STATE_IDLE: begin
                if (start_btn) begin
                    next_state = STATE_PLAY;
                end
            end
            STATE_PLAY: begin
                if (ball_x <= X_MIN || ball_x >= X_MAX) begin
                    next_state = STATE_IDLE;
                end
            end
        endcase
    end

    always_comb begin
        game_enable = 1'b0;
        if (current_state == STATE_PLAY) begin
            game_enable = 1'b1;
        end
    end

    // Combinational next-state physics
    logic [9:0] next_ball_x, next_ball_y;
    logic [9:0] next_paddle1_y, next_paddle2_y;
    
    logic ball_vel_x, next_ball_vel_x; 
    logic ball_vel_y, next_ball_vel_y;
    logic [9:0] current_ball_speed, next_ball_speed;

    always_comb begin
        next_ball_x     = ball_x;
        next_ball_y     = ball_y;
        next_ball_vel_x = ball_vel_x;
        next_ball_vel_y = ball_vel_y;
        next_paddle1_y  = paddle1_y;
        next_paddle2_y  = paddle2_y;
        next_ball_speed = current_ball_speed;

        if (game_enable && vsync_pulse) begin
            
            if (ball_vel_x == 1'b1) next_ball_x = ball_x + current_ball_speed;
            else                    next_ball_x = ball_x - current_ball_speed;
            
            if (ball_vel_y == 1'b1) next_ball_y = ball_y + current_ball_speed;
            else                    next_ball_y = ball_y - current_ball_speed;

            if (ball_vel_y == 1'b0 && ball_y <= (Y_MIN + current_ball_speed)) begin
                next_ball_vel_y = 1'b1;
                next_ball_y = ball_y + current_ball_speed;
            end 
            else if (ball_vel_y == 1'b1 && ball_y >= (Y_MAX - BALL_SIZE - current_ball_speed)) begin
                next_ball_vel_y = 1'b0;
                next_ball_y = ball_y - current_ball_speed;
            end

            // Left Paddle
            if (next_ball_x <= (LEFT_PADDLE_X + PADDLE_WIDTH) && 
               (next_ball_y + BALL_SIZE) >= paddle1_y && 
                next_ball_y <= (paddle1_y + PADDLE_HEIGHT)) begin
                
                next_ball_vel_x = 1'b1;
                next_ball_x     = LEFT_PADDLE_X + PADDLE_WIDTH;
                if (current_ball_speed < MAX_BALL_SPEED) next_ball_speed = current_ball_speed + 1;
            end 
            // Right Paddle
            else if ((next_ball_x + BALL_SIZE) >= RIGHT_PADDLE_X && 
                     (next_ball_y + BALL_SIZE) >= paddle2_y && 
                      next_ball_y <= (paddle2_y + PADDLE_HEIGHT)) begin
                
                next_ball_vel_x = 1'b0;
                next_ball_x     = RIGHT_PADDLE_X - BALL_SIZE;
                if (current_ball_speed < MAX_BALL_SPEED) next_ball_speed = current_ball_speed + 1;
            end



            // Player 1
            if (player1_ctrl == UP && paddle1_y >= (Y_MIN + PADDLE_MOVEMENT)) begin
                next_paddle1_y = paddle1_y - PADDLE_MOVEMENT;
            end 
            else if (player1_ctrl == DOWN && paddle1_y <= (Y_MAX - PADDLE_HEIGHT - PADDLE_MOVEMENT)) begin
                next_paddle1_y = paddle1_y + PADDLE_MOVEMENT;
            end

            // Player 2
            if (player2_ctrl == UP && paddle2_y >= (Y_MIN + PADDLE_MOVEMENT)) begin
                next_paddle2_y = paddle2_y - PADDLE_MOVEMENT;
            end 
            else if (player2_ctrl == DOWN && paddle2_y <= (Y_MAX - PADDLE_HEIGHT - PADDLE_MOVEMENT)) begin
                next_paddle2_y = paddle2_y + PADDLE_MOVEMENT;
            end
        end 
        else if (~game_enable) begin
            next_ball_x = X_CENTER;
            next_ball_y = Y_CENTER;
            next_ball_vel_x = 1'b1;
            next_ball_vel_y = 1'b1;
            next_ball_speed = BALL_SPEED;
        end
    end

    // Sequential memory registers
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ball_x     <= X_CENTER;
            ball_y     <= Y_CENTER;
            ball_vel_x <= 1'b1;
            ball_vel_y <= 1'b1;
            current_ball_speed <= BALL_SPEED;
            paddle1_y  <= (Y_CENTER - (PADDLE_HEIGHT/2));
            paddle2_y  <= (Y_CENTER - (PADDLE_HEIGHT/2));
        end else begin
            ball_x     <= next_ball_x;
            ball_y     <= next_ball_y;
            ball_vel_x <= next_ball_vel_x;
            ball_vel_y <= next_ball_vel_y;
            current_ball_speed <= next_ball_speed;
            paddle1_y  <= next_paddle1_y;
            paddle2_y  <= next_paddle2_y;
        end
    end

endmodule