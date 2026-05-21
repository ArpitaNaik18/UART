module uart_rx #(parameter N = 8)(

    input               sys_clk,
    input               rst,
    input               baud_clk,
    input               xmith,
    input               uart_rec_datah,

    output reg [N-1:0]  rec_dataH,
    output reg          rec_readyH,
    output reg          rec_busy
);

    localparam IDLE     = 3'b000;
    localparam START    = 3'b001;
    localparam DATA_OUT = 3'b010;
    localparam STOP     = 3'b011;

    reg rx_ff1, rx_ff2;

    always @(posedge baud_clk or negedge rst) begin

        if(!rst) begin

            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;

        end

        else begin

            rx_ff1 <= uart_rec_datah;
            rx_ff2 <= rx_ff1;

        end

    end

    reg [2:0] state;

    reg [3:0] count;

    reg [$clog2(N)-1:0] ind;

    reg [N-1:0] temp;

    always @(posedge baud_clk or negedge rst) begin

        if(!rst) begin

            rec_readyH <= 1'b0;
            rec_busy   <= 1'b0;

            rec_dataH  <= 0;

            state <= IDLE;

            ind   <= 0;
            count <= 0;

            temp  <= 0;

        end

        else begin

            rec_readyH <= 1'b0;

            case(state)

                IDLE: begin

                    rec_busy <= 1'b0;

                    count <= 0;
                    ind   <= 0;

                    if(rx_ff2 == 1'b0) begin

                        state <= START;

                        rec_busy <= 1'b1;

                    end

                end

                START: begin

                    rec_busy <= 1'b1;

                    if(count == 4'd7) begin

                        count <= 0;

                        if(rx_ff2 == 1'b0)

                            state <= DATA_OUT;

                        else

                            state <= IDLE;

                    end

                    else begin

                        count <= count + 1'b1;

                    end

                end

                DATA_OUT: begin

                    rec_busy <= 1'b1;

                    if(count == 4'd15) begin

                        count <= 0;

                        temp <= {rx_ff2,temp[N-1:1]};

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

                    rec_busy <= 1'b1;

                    if(count == 4'd15) begin

                        count <= 0;

                        rec_dataH <= temp;

                        rec_readyH <= 1'b1;

                        rec_busy <= 1'b0;

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
