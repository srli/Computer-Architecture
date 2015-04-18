module finitestatemachine(clk, cs, sclk_pos, rw, sr_we, dm_we, addr_we, miso_en);
input clk;
input cs;
input sclk_pos;
input rw;
output reg sr_we;
output reg dm_we;
output reg addr_we;
output reg miso_en;

parameter state_GET = 0;
parameter state_GOT = 1;
parameter state_READ_1 = 2;
parameter state_READ_2 = 3;
parameter state_READ_3 = 4;
parameter state_WRITE_1 = 5;
parameter state_WRITE_2 = 6;
parameter state_DONE = 7;

reg[3:0] count = 0;
reg[2:0] state = state_GET;

reg reset_count;

always @(posedge clk) begin
if (!cs) begin
    count <= count + sclk_pos;
end
sr_we = 0;
dm_we = 0;
addr_we = 0;
reset_count = 0;

if (cs) begin
    reset_count = 1;
    state <= state_GET;
end

case (state)
    state_DONE: 
        begin
            reset_count = 1;
        end
    state_GET:
        begin
            miso_en = 0;
            if (count == 8) begin
                state <= state_GOT;
            end
        end
    state_GOT:
        begin
            reset_count = 1;
            addr_we = 1;
            if (rw) begin
                state <= state_READ_1;
            end
            else begin
                state <= state_WRITE_1;
            end
        end
    state_READ_1:
       begin
            state <= state_READ_2;
        end 
    state_READ_2:
        begin
            sr_we = 1;
            state <= state_READ_3;
        end
    state_READ_3:
        begin
            miso_en = 1;
            if (count == 8) begin
                state <= state_DONE;
            end
        end
    state_WRITE_1:
        begin
            if (count == 8) begin
                state <= state_WRITE_2;
            end
        end
    state_WRITE_2:
        begin
            dm_we = 1;
            state <= state_DONE;
        end
endcase

if (reset_count) begin
    count <= 0;
end

end
endmodule