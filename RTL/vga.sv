module vga #(
    parameter DIVISOR,
    parameter WIDTH, 
    parameter H_TOTAL,
    parameter V_TOTAL,
    parameter H_DISPLAY, 
    parameter V_DISPLAY, 
    parameter H_SYNC_START, 
    parameter H_SYNC_END, 
    parameter V_SYNC_START, 
    parameter V_SYNC_END
) (
    input logic clk, rst, 
    output logic hsync, vsync, display_on,
    output logic [WIDTH-1:0] current_x, current_y
);

    logic clk_divided; // Now acts as a 1-cycle enable pulse
    logic [WIDTH-1:0] h_count;
    logic h_terminal;
    logic [WIDTH-1:0] v_count;
    logic h_display_area_compare;
    logic v_display_area_compare;
    logic hsync_next;
    logic vsync_next;

    generate
        if (DIVISOR == 1) begin
            assign clk_divided = 1'b1;
        end else begin
            clk_divider #(.DIVISOR(DIVISOR), .WIDTH(32)) clk_d (
                .clk(clk),
                .rst(rst),
                .clk_out(clk_divided)
            );
        end
    endgenerate

    horizontal_counter #(.PIXELS(H_TOTAL), .WIDTH(WIDTH)) h_counter (
        .clk(clk),
        .rst(rst),
        .en(clk_divided),
        .count(h_count),
        .terminal_count(h_terminal)
    );
    
    vertical_counter #(.PIXELS(V_TOTAL), .WIDTH(WIDTH)) v_counter (
        .clk(clk),
        .rst(rst),
        .en(h_terminal),
        .count(v_count)
    );

    always_comb begin
        h_display_area_compare = (h_count < H_DISPLAY);
        v_display_area_compare = (v_count < V_DISPLAY);

        display_on = h_display_area_compare & v_display_area_compare;
        current_x = h_count;
        current_y = v_count;
        hsync_next = ~(h_count >= H_SYNC_START && h_count < H_SYNC_END);
        vsync_next = ~(v_count >= V_SYNC_START && v_count < V_SYNC_END);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else if (clk_divided) begin
            hsync <= hsync_next;
            vsync <= vsync_next;
        end
    end
    
endmodule