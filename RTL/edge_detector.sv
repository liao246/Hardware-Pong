module edge_detector (
    input logic clk, rst,
    input logic signal_in,
    output logic pulse_out
);

    logic signal_last;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_last <= 1'b0;
        end else begin
            signal_last <= signal_in;
        end
    end

    assign pulse_out = signal_in & ~signal_last;

endmodule