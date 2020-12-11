module alu32(
    input [5:0] op,      // some input encoding of your choice
    input [31:0] rv1,    // First operand
    input [31:0] rv2,    // Second operand
    output [31:0] rvout,  // Output value
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe,
    input [31:0] daddr,
    input [31:0] iaddr,
    input [31:0] instr
);
    
    reg [31:0] rvout;
    reg [31:0] dwdata;
    reg [3:0] dwe;
    always @* begin
        
       
        case(op)
            0 : begin rvout = rv1 + rv2; dwe = 0; dwdata = 0; end  //ADDI
            1 : begin rvout = $signed(rv1) < $signed(rv2); dwe = 0; dwdata = 0;end //SLTI
            2 : begin rvout = rv1 < rv2; dwe = 0; dwdata = 0;end //SLTIU
            3 : begin rvout = rv1 ^ rv2; dwe = 0; dwdata = 0;end //XORI
            4 : begin rvout = rv1 | rv2; dwe = 0; dwdata = 0;end //ORI
            5 : begin rvout = rv1 & rv2; dwe = 0; dwdata = 0;end //ANDI
            6 : begin rvout = rv1 << rv2[4:0]; dwe = 0; dwdata = 0;end //SLLI
            7 : begin rvout = rv1 >> rv2[4:0]; dwe = 0; dwdata = 0;end //SRLI
            8 : begin rvout = $signed(rv1) >>> rv2[4:0]; dwe = 0; dwdata = 0;end //SRAI
            9 : begin rvout = rv1 + rv2; dwe = 0; dwdata = 0;end //ADD
            10: begin rvout = rv1 - rv2; dwe = 0; dwdata = 0;end //SUB
            11: begin rvout = rv1 << rv2[4:0]; dwe = 0; dwdata = 0;end //SLL
            12: begin rvout = $signed(rv1) < $signed(rv2); dwe = 0; dwdata = 0;end //SLT
            13: begin rvout = rv1 < rv2; dwe = 0; dwdata = 0;end //SLTU
            14: begin rvout = rv1 ^ rv2; dwe = 0; dwdata = 0;end //XOR
            15: begin rvout = rv1 >> rv2[4:0]; dwe = 0; dwdata = 0;end //SRL
            16: begin rvout = $signed(rv1) >> rv2[4:0]; dwe = 0; dwdata = 0;end //SRA
            17: begin rvout = rv1 | rv2; dwe = 0; dwdata = 0;end //OR
            18: begin rvout = rv1 & rv2; dwe = 0; dwdata = 0;end //AND
            19 : begin dwe = 0;dwdata = 0;           // all the case statements added here on are because of misaligned command, there was a test case where daddr was not a multiple of 4 case statements below are for cases like those only
            case (daddr[1:0])
                2'b00: rvout = {{24{drdata[7]}}, drdata[7:0]};    
                2'b01: rvout = {{24{drdata[15]}}, drdata[15:8]}; //taking the 2nd bit and sign extending
                2'b10: rvout = {{24{drdata[23]}}, drdata[23:16]};
                2'b11: rvout = {{24{drdata[31]}}, drdata[31:24]};
                default : rvout = {{24{drdata[7]}}, drdata[7:0]};
            endcase
                end                                                     //LB
            20 : begin  dwe = 0; dwdata = 0;
                case (daddr[1:0])
                    2'b00: rvout = {{16{drdata[15]}}, drdata[15:0]};
                    2'b10: rvout = {{16{drdata[31]}}, drdata[31:16]};
                    default : rvout = {{16{drdata[15]}}, drdata[15:0]};
                endcase
                end                                                     //LH
            21 : begin rvout = drdata; dwe = 0; dwdata = 0; end                         //LW
            22 : begin dwe = 0;dwdata = 0; 
                case (daddr[1:0])
                    2'b00: rvout = {{24{1'b0}}, drdata[7:0]};
                    2'b01: rvout = {{24{1'b0}}, drdata[15:8]};
                    2'b10: rvout = {{24{1'b0}}, drdata[23:16]};
                    2'b11: rvout = {{24{1'b0}}, drdata[31:24]};
                    default : rvout = {{24{1'b0}}, drdata[7:0]};
                endcase
                end                                                     //LBU
            23 : begin dwe = 0; dwdata = 0; 
                case (daddr[1:0])
                    2'b00: rvout = {{16{1'b0}}, drdata[15:0]};
                    2'b10: rvout = {{16{1'b0}}, drdata[31:16]};
                    default : rvout = {{16{1'b0}}, drdata[15:0]};
                endcase
                end                                                    //LHU
            24 : begin dwdata = rv2; rvout = 0;
                case(daddr[1:0])
                    2'b00: dwe = 4'b0001;        // writing only initial 8 bits
                    2'b01: dwe = 4'b0010;        // next 8 bits
                    2'b10: dwe = 4'b0100;        // next 8 bits
                    2'b11: dwe = 4'b1000;        // next 8 bits
                    default : dwe = 4'b0001; 
                endcase 
            end                                                            //SB
            25 : begin dwdata = rv2; rvout = 0;
                case(daddr[1:0])
                    2'b00: dwe = 4'b0011;       //dwe is only set to 1 for store instructions because we have to write in dmem
                    2'b10: dwe = 4'b1100;
                    default : dwe = 4'b0011;
                endcase
            end                                                             //SH
            26 : begin dwdata = rv2; dwe = 4'b1111; rvout = 0; end                     //SW
            27: begin rvout = {instr[31:12],{12{1'b0}}}; dwe = 0; dwdata = 0;end //LUI
            28: begin rvout = iaddr + {instr[31:12],{12{1'b0}}}; dwe = 0; dwdata = 0;end //AIUPC
            29: begin rvout = iaddr +4; dwe = 0; dwdata = 0;end //JAL
            30: begin rvout = iaddr +4; dwe = 0; dwdata = 0;end //JALR
            31: begin dwe = 0; dwdata = 0; rvout = 0; end      //BEQ   branch instructions do not have any alu operation nor do they need to store data
            32: begin dwe = 0; rvout = 0; dwdata = 0; end //BNE
            33: begin dwe = 0; rvout = 0; dwdata = 0; end //BLT
            34: begin dwe = 0; rvout = 0; dwdata = 0; end //BGE
            35: begin dwe = 0; rvout = 0; dwdata = 0; end //BLTU
            36: begin dwe = 0; rvout = 0; dwdata = 0; end //BGEU
            default : begin rvout =0; dwe = 0; dwdata = 0; end 
        endcase
    end
endmodule