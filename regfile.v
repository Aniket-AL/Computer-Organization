module regfile(
    input [4:0] rs1,     // address of first operand to read - 5 bits
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of value to write
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk,            // Clock signal - all changes at clock posedge
    input [5:0] op,
    input [31:0] instr,
    output reg [31:0] daddr,
    input [31:0] iaddr
);
    // Desired function
    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    // on clock edge, if we=1, regfile entry for rd will be updated

    integer i;
    reg [31:0] memory [0:31];
    reg [31:0] rv1, rv2;
    
    initial begin
        for (i=0;i<32;i=i+1) begin
            memory[i] = 0;
            end
        end
    
    always @* begin
        rv1 = memory[rs1];
        rv2 = memory[rs2];
        case(op)
            19,20,21,22,
            23: daddr = rv1 + {{20{instr[31]}},instr[31:20]};
            24,25,
            26: daddr = rv1 + {{ 20{instr[31]}},instr[31:25],instr[11:7]};
            default : daddr = 0;  //added default in a8
        endcase 
    end
    
    always @(posedge clk) begin  //regfile same as A5 just keeping r0 = 0
        if(we == 1 & rd!= 0) begin
            memory[rd] <= wdata;
         end
        else begin
            memory[0]<=0;            //added else statement to synthesize the code
        end
    end
endmodule