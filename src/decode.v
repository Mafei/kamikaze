`include "riscv_defines.v"

module kamikaze_decode( clk_i,
			rst_i,
			is_compressed_instr_i,
			instr_i,
			instr_valid_i,
			pc_i,
			
			rf_rs1_o,
			rf_rs2_o,
			rf_rd_o,
			
			imm_o,
			decode_valid_o
			);
	
	input clk_i;
	input rst_i;
	
	input is_compressed_instr_i;
	input [31:0]instr_i;
	input instr_valid_i;
	
	input [31:0]pc_i; /*虽然没什么卵用*/
	
	output reg [4:0]rf_rs1_o = 0;
	output reg [4:0]rf_rs2_o = 0;
	output reg [4:0]rf_rd_o  = 0; /* 寄存器 2R 1W地址口, 同步RAM?分布RAM? */
	
	output reg imm_o;
	output reg decode_valid_o; /* 指令是否有效 */
	
	reg [31:0]pc = 0;
	
	reg [31:0]expand_comp; /* 解码压缩指令 */
	
	reg illegal_instr_comp; /* 压缩指令错误 */
	wire [31:0]instr; /* 真正的指令 */
	
	reg is_compressed_instr = 0;
	
	wire [6:0]opcode = instr[6:0];
	
	wire [4:0]rs1_i = instr[19:15];
	wire [4:0]rs2_i = instr[24:20];
	wire [4:0]rd_i  = instr[11:7];
	
	always @(posedge clk_i or negedge rst_i)
	begin
		if(!rst_i)
		begin
			decode_valid_o <= 0;
		end
		else
		begin
			if(is_compressed_instr_i)
			begin //压缩指令处理
				rf_rs2_o <= instr_i[6:2];
			end
			else
			begin //非压缩指令处理
				
				rf_rs1_o <= rs1_i; /* 可能可以提前 */
				rf_rs2_o <= rs1_i;
				rf_rd_o  <= rs1_i; /* 寄存器解码 */
				
				decode_valid_o <= 1;
				case (opcode[6:2])
					`OPC_OP_IMM:
					begin
						
					end
					/*OPC_LUI:
					OPC_AUIPC:
					OPC_OP:
					OPC_JAL:
					OPC_JALR:
					OPC_BRANCH:
					OPC_LOAD:
					OPC_STORE:
					OPC_SYSTEM:*/
					default:
					begin
						decode_valid_o <= 0;
					end
				endcase
				
			end
			
			pc <= pc_i;
			is_compressed_instr <= is_compressed_instr_i;
		end
	end
	
	
endmodule
