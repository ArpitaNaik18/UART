module uart_tx #(parameter N=8)(

    input              sys_clk,
    input              rst,
    input              baud_clk,
    input              xmith,
    input      [N-1:0] xmit_datah,

    output reg         xmit_doneh,
    output reg         xmit_active,
    output reg         uart_xmit_dataH
);

    localparam IDLE       = 3'b000;
    localparam START      = 3'b001;
    localparam DATA_STATE = 3'b010;
    localparam STOP       = 3'b011;

    reg [N-1:0] data;

    reg [$clog2(N):0] ind;

    reg [2:0] state;

    reg [3:0] count;

    always @(posedge baud_clk or negedge rst) begin

        if(!rst) begin

            xmit_doneh      <= 1'b0;
            xmit_active     <= 1'b0;
            uart_xmit_dataH <= 1'b1;

            state <= IDLE;

            ind   <= 0;
            count <= 0;

            data  <= 0;

        end

        else begin

            case(state)

                IDLE: begin

                    uart_xmit_dataH <= 1'b1;

                    xmit_doneh <= 1'b0;

                    xmit_active <= 1'b0;

                    count <= 0;
                    ind   <= 0;

                    if(xmith) begin

                        data <= xmit_datah;

                        uart_xmit_dataH <= 1'b0;

                        state <= START;

                        xmit_active <= 1'b1;

                    end

                end

                START: begin

                    if(count == 4'd14) begin

                        count <= 0;

                        state <= DATA_STATE;

                    end

                    else begin

                        count <= count + 1'b1;

                    end

                end

                DATA_STATE: begin

                    uart_xmit_dataH <= data[ind];

                    if(count == 4'd15) begin

                        count <= 0;

                        if(ind == N-1) begin

                            ind <= 0;

                            state <= STOP;

                        end

                        else begin

                            ind <= ind + 1'b1;

                        end

                    end

                    else begin

                        count <= count + 1'b1;

                    end

                end

                STOP: begin

                    uart_xmit_dataH <= 1'b1;

                    if(count == 4'd15) begin

                        count <= 0;

                        xmit_doneh <= 1'b1;

                        xmit_active <= 1'b0;

                        state <= IDLE;

                    end

                    else begin

                        count <= count + 1'b1;

                    end

                end

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule
