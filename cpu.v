module cpu (
    input clk, 
    input reset,
    output [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe
);
    
    reg [31:0] iaddr;
    reg [31:0] daddr;
    reg [31:0] dwdata;
    reg [3:0]  dwe;
    wire [31:0] daddr1, dwdata1; //daddr,dwdata and dwe needed to be wires
    wire [3:0] dwe1;
    wire [5:0] op;
    wire [31:0] rv1, rv2, rvout, r_rv2, wdata;
    wire [4:0] rs1, rs2, rd;
    wire we;
    //instantiating the 3 extra files that I have made in this assignment(alu,dummy,regfile)
    alu32 u1(
        .op(op),
        .rv1(rv1),           // From regfile
        .rv2(rv2),
        .rvout(rvout),
        .drdata(drdata),     // From dmem
        .dwdata(dwdata1),    // To dmem
        .dwe(dwe1),
        .daddr(daddr1),
        .iaddr(iaddr),
        .instr(idata)
    );
    
    regfile u2(
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .we(we),
        .wdata(rvout),
        .rv1(rv1),
        .rv2(r_rv2),
        .clk(clk),
        .op(op),
        .instr(idata),
        .daddr(daddr1)
    );
    
    dummydecoder u3(
        .instr(idata),
        .op(op),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .r_rv2(r_rv2),
        .rv2(rv2),
        .we(we)
    );
    
    always @(daddr1 or dwdata1 or dwe1) begin
        if (reset) begin
           daddr = 0;
           dwdata = 0;
           dwe = 0;
        end
        else begin
        daddr <= daddr1;
        dwdata <= dwdata1;
        dwe <= dwe1;
        end
    end

    always @(posedge clk) begin //initialising
        if (reset) begin
            iaddr <= 0;
        end else begin //computing pc by adding immediate values according to instruction table
            case(op)
                
                29 : iaddr = iaddr + {{12{idata[31]}},idata[19:12],idata[20],idata[30:21],1'b0}; //JAL
                30 : begin iaddr = rv1 + {{20{idata[31]}},idata[31:20]} ; iaddr[0] = 0;  end //JALR
                31 : begin if(rv1 == rv2) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0}; //BEQ
                     else iaddr <= iaddr + 4; end
                32 : begin if(rv1 != rv2) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0}; //BNE
                     else iaddr <= iaddr + 4; end
                33 : begin if($signed(rv1) < $signed(rv2)) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0}; //BLT
                     else iaddr <= iaddr + 4; end
                34 : begin if($signed(rv1) >= $signed(rv2)) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0}; //BGE
                     else iaddr <= iaddr + 4;  end
                35 : begin if(rv1 < rv2) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0}; //BLTU
                     else iaddr <= iaddr + 4; end
                36 : begin if(rv1 >= rv2) iaddr = iaddr + {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0};//BGEU
                     else iaddr <= iaddr + 4; end
                default : iaddr <= iaddr + 4;
            endcase
        end      //default is pc = pc +4 for other instructions
    end

endmodule
