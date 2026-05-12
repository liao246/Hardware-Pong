module vertical_counter #(
    parameter PIXELS = 600,
    parameter WIDTH = 10
)(
    input logic clk,
    input logic rst,
    input logic en,
    output logic [WIDTH-1:0] count
);

    logic [WIDTH-1:0] count_next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= '0;
        end else if (en) begin
            count <= count_next;
        end
    end

    always_comb begin
        if (count == PIXELS - 1) begin
            count_next = 0;
        end else begin
            count_next = count + 1;
        end
    end

endmodule
