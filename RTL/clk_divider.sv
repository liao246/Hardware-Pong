module clk_divider #(
    parameter DIVISOR = 4,
    parameter WIDTH = 2
) (
    input  logic clk,
    input  logic rst,
    output logic clk_out
);

    localparam LIMIT = DIVISOR - 1;

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= '0;
        end else begin
            if (count == LIMIT[WIDTH-1:0]) begin
                count <= '0;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

    assign clk_out = (count == LIMIT[WIDTH-1:0]);

endmodule