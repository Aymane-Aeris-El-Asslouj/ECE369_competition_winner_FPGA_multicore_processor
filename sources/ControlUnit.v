`timescale 1ns / 1ps
`default_nettype none

module ControlUnit(opcode, funct, rs, rt, ID_EX_RegWrite, EX_MEM_RegWrite, MEM_SAD_RegWrite, SAD_SADD_RegWrite, SAD_SSAD_RegWrite,
                    EX_WriteRegister, EX_MEM_WriteRegister, MEM_SAD_WriteRegister, SAD_SADD_WriteRegister, SAD_SSAD_WriteRegister,
                    
                    ID_frame_shift, ID_window_shift, ID_min_in, ID_buff,
                    
                    all_buf_flags, ID_load_buff_a, ID_load_buff_b,
                    
                    ID_load_min, ID_load_min_tag, ID_special,
                    
                    EX_MEM_special, MEM_SAD_special, SAD_SADD_special, SAD_SSAD_special, ID_EX_special,

                    ID_ALUControl, ID_R, ID_RegWrite, ID_MemWrite,
                    ID_MemRead, ID_HalfControl, ID_ByteControl, branch,
                    JR, ID_JALControl, CompareControl,
                    ID_stall);

          
    // ALU operations
    localparam [3:0] AND = 4'd0;
    localparam [3:0] OR = 4'd1;
    localparam [3:0] ADD = 4'd2;
    localparam [3:0] XOR = 4'd3;
    localparam [3:0] SLL = 4'd4;
    localparam [3:0] SRL = 4'd5;
    localparam [3:0] SUB = 4'd6;
    localparam [3:0] SLT = 4'd7;
    localparam [3:0] MUL = 4'd8;
    localparam [3:0] NOR = 4'd9;
    
    // Compare operations
    localparam [2:0] GTZ = 3'd0;
    localparam [2:0] LTZ = 3'd1;
    localparam [2:0] GEZ = 3'd2;
    localparam [2:0] LEZ = 3'd3;
    localparam [2:0] EQ = 3'd4;
    localparam [2:0] NEQ = 3'd5;
    
    // Ahrithmetic/logical opcodes
    localparam [5:0] SPECIAL = 6'b000000;
    localparam [5:0] SPECIAL2 = 6'b011100;  
    localparam [5:0] ADDI_OPCODE = 6'b001000;   
    localparam [5:0] ANDI_OPCODE = 6'b001100;  
    localparam [5:0] ORI_OPCODE = 6'b001101;  
    localparam [5:0] XORI_OPCODE = 6'b001110;  
    localparam [5:0] SLTI_OPCODE = 6'b001010;  
    
    // Ahrithmetic/logical functs
    localparam [5:0] ADD_FUNCT = 6'b100000;    
    localparam [5:0] SUB_FUNCT = 6'b100010;    
    localparam [5:0] AND_FUNCT = 6'b100100;    
    localparam [5:0] OR_FUNCT = 6'b100101;    
    localparam [5:0] NOR_FUNCT = 6'b100111;    
    localparam [5:0] XOR_FUNCT = 6'b100110;    
    localparam [5:0] SLT_FUNCT = 6'b101010;    
    localparam [5:0] SLL_FUNCT = 6'b000000;  
    localparam [5:0] SRL_FUNCT = 6'b000010;
    localparam [5:0] BUF_FUNCT = 6'b010101;//////
    
    // Memory opcode
    localparam [5:0] LW_OPCODE = 6'b100011;
    localparam [5:0] LH_OPCODE = 6'b100001;
    localparam [5:0] LB_OPCODE = 6'b100000;
    localparam [5:0] SW_OPCODE = 6'b101011;
    localparam [5:0] SH_OPCODE = 6'b101001;
    localparam [5:0] SB_OPCODE = 6'b101000;
    
    // Branch opcode
    localparam [5:0] BEQ_OPCODE = 6'b000100;//////
    localparam [5:0] BNE_OPCODE = 6'b000101;//////
    localparam [5:0] REGIMM = 6'b000001;//////
    localparam [5:0] BGTZ_OPCODE = 6'b000111;//////
    localparam [5:0] BLEZ_OPCODE = 6'b000110;//////
    
    localparam [4:0] BGEZ_RT = 5'b00001;//////
    localparam [4:0] BLTZ_RT = 5'b00000;//////
    
    localparam [5:0] J_OPCODE = 6'b000010;
    localparam [5:0] JAL_OPCODE = 6'b000011;
    
    localparam [5:0] JR_FUNCT = 6'b001000;//////
    
    // SAD opcode
    localparam [5:0] SAD_A_OPCODE = 6'b011101;
    localparam [5:0] SAD_B_OPCODE = 6'b010110;
    localparam [5:0] SAD_C_OPCODE = 6'b110110;
    localparam [5:0] LBUFA_OPCODE = 6'b010011;
    localparam [5:0] LBUFB_OPCODE = 6'b110011;
    localparam [5:0] LBUFC_OPCODE = 6'b110010;
    localparam [5:0] LMIN_OPCODE = 6'b111001;
    localparam [5:0] LTAG_OPCODE = 6'b110111;
    
    input [5:0] opcode, funct;
    input [4:0] rs, rt;
    
    input wire all_buf_flags;
    
    output wire ID_R, ID_MemWrite, ID_RegWrite, ID_MemRead, branch;
    output wire JR, ID_special;
    output wire ID_HalfControl, ID_ByteControl, ID_JALControl;
    output reg [3:0] ID_ALUControl;
    output reg [2:0] CompareControl;
    
    output wire ID_frame_shift, ID_window_shift, ID_min_in, ID_buff, ID_load_buff_a, ID_load_buff_b,
    ID_load_min, ID_load_min_tag;
    
    wire strict_branch, equality_branch;
    
    wire need_buff;

    always @(*) begin
        case(opcode)
            SPECIAL: case(funct)
                    ADD_FUNCT: ID_ALUControl <= ADD;
                    SUB_FUNCT: ID_ALUControl <= SUB;
                    AND_FUNCT: ID_ALUControl <= AND;
                    OR_FUNCT: ID_ALUControl <= OR;
                    NOR_FUNCT: ID_ALUControl <= NOR;
                    XOR_FUNCT: ID_ALUControl <= XOR;
                    SLT_FUNCT: ID_ALUControl <= SLT;
                    SLL_FUNCT: ID_ALUControl <= SLL;
                    SRL_FUNCT: ID_ALUControl <= SRL;
                    default: ID_ALUControl <= 4'bX;
                endcase
            SPECIAL2: ID_ALUControl <= MUL;
            ADDI_OPCODE: ID_ALUControl <= ADD;
            ANDI_OPCODE: ID_ALUControl <= AND;
            ORI_OPCODE: ID_ALUControl <= OR;
            XORI_OPCODE: ID_ALUControl <= XOR;
            SLTI_OPCODE: ID_ALUControl <= SLT;
            
            default: ID_ALUControl <= ADD;
        endcase
    end
    
    always @(*) begin
        case(opcode)
            BEQ_OPCODE: CompareControl <= EQ;
            BNE_OPCODE: CompareControl <= NEQ;
            BGTZ_OPCODE: CompareControl <= GTZ;
            REGIMM: case(rt)
                    BLTZ_RT: CompareControl <= LTZ;
                    BGEZ_RT: CompareControl <= GEZ;
                    default: CompareControl <= 4'bX;
                endcase
            BLEZ_OPCODE: CompareControl <= LEZ;
            default: CompareControl <= 4'bX;
        endcase
    
    end
    
    wire SAD_C, LBUFC;
    
    assign SAD_C = (opcode == SAD_C_OPCODE);
    assign LBUFC = (opcode == LBUFC_OPCODE);
    assign ID_min_in = SAD_C | LBUFC;
    assign ID_window_shift = (opcode == SAD_A_OPCODE);
    assign ID_frame_shift = (opcode == SAD_B_OPCODE) | SAD_C;
    assign ID_load_buff_a = (opcode == LBUFA_OPCODE);
    assign ID_load_buff_b = (opcode == LBUFB_OPCODE) | LBUFC;
    
    assign ID_load_min = (opcode == LMIN_OPCODE);
    assign ID_load_min_tag = (opcode == LTAG_OPCODE) | ID_load_min;
    
    assign ID_special = (opcode == SPECIAL);
    
    assign ID_buff = ID_special &(funct == BUF_FUNCT);
    assign need_buff = ID_load_buff_a | ID_load_buff_b;
    
    assign ID_R = ID_special | (opcode == SPECIAL2);
    
    assign ID_HalfControl = (opcode == SH_OPCODE) | (opcode == LH_OPCODE);
    assign ID_ByteControl = (opcode == SB_OPCODE) | (opcode == LB_OPCODE);
    
    assign ID_MemWrite = (opcode == SW_OPCODE) | (opcode == SH_OPCODE) | (opcode == SB_OPCODE);
    assign ID_MemRead = (opcode == LW_OPCODE) | (opcode == LH_OPCODE) | (opcode == LB_OPCODE)
     | ID_frame_shift | ID_window_shift | ID_load_buff_a | ID_load_buff_b;
    
    assign ID_JALControl = (opcode == JAL_OPCODE);
    
    assign JR = ID_special & (funct == JR_FUNCT);
    
    assign strict_branch = (opcode == REGIMM) | (opcode == BGTZ_OPCODE) | (opcode == BLEZ_OPCODE);
    assign equality_branch = (opcode == BEQ_OPCODE) | (opcode == BNE_OPCODE);
    assign branch = equality_branch | strict_branch;
    
    
    assign ID_RegWrite = (~(ID_MemWrite | branch | JR | ID_frame_shift | ID_window_shift)) | ID_JALControl;
    
    
    
    // Hazard detection
    output wire ID_stall;
    
    input wire ID_EX_RegWrite, EX_MEM_RegWrite, MEM_SAD_RegWrite, SAD_SADD_RegWrite, SAD_SSAD_RegWrite;
    input [4:0] EX_WriteRegister, EX_MEM_WriteRegister, MEM_SAD_WriteRegister, SAD_SADD_WriteRegister, SAD_SSAD_WriteRegister;
    
    
    input wire EX_MEM_special, MEM_SAD_special, SAD_SADD_special, SAD_SSAD_special, ID_EX_special;
    
    
    
    assign ID_stall =   ((rs != 5'b0) 
                         & (
                        (ID_EX_RegWrite & (rs==EX_WriteRegister) & (~(ID_EX_special & ID_special))) | 
                        (EX_MEM_RegWrite & (rs==EX_MEM_WriteRegister) & (~(EX_MEM_special & ID_special)))| 
                        (MEM_SAD_RegWrite & (rs==MEM_SAD_WriteRegister) & (~(MEM_SAD_special & ID_special)))| 
                        (SAD_SADD_RegWrite & (rs==SAD_SADD_WriteRegister) & (~(SAD_SADD_special & ID_special)))| 
                        (SAD_SSAD_RegWrite & (rs==SAD_SSAD_WriteRegister) & (~(SAD_SSAD_special & ID_special)))
                        )& (~ID_JALControl))
                        | ((rt != 5'b0) 
                        & (
                        (ID_EX_RegWrite & (rt==EX_WriteRegister) & (~(ID_EX_special & ID_special))) | 
                        (EX_MEM_RegWrite & (rt==EX_MEM_WriteRegister) & (~(EX_MEM_special & ID_special)))| 
                        (MEM_SAD_RegWrite & (rt==MEM_SAD_WriteRegister) & (~(MEM_SAD_special & ID_special)))| 
                        (SAD_SADD_RegWrite & (rt==SAD_SADD_WriteRegister) & (~(SAD_SADD_special & ID_special)))| 
                        (SAD_SSAD_RegWrite & (rt==SAD_SSAD_WriteRegister) & (~(SAD_SSAD_special & ID_special)))
                        )
                         &(ID_R | ID_MemWrite | equality_branch | ID_frame_shift)) 
                         | (need_buff & (~all_buf_flags));
    
  
        
      
    endmodule