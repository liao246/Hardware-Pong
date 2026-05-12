module horizontal_counter #(
    parameter PIXELS = 800,
    parameter WIDTH = 10
)(
    input logic clk, rst, en,
    output logic [WIDTH-1:0] count,
    output logic terminal_count
);

    logic [WIDTH-1:0] count_next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= '0;
        end else begin
            count <= count_next;
        end
    end

    always_comb begin
        if (en) begin
            if (count == PIXELS - 1) begin
                count_next = 0;
                terminal_count = 1;
            end else begin
                count_next = count + 1;
                terminal_count = 0;
            end
        end else begin
            count_next = count;
            terminal_count = 0;
        end
    end

endmodule