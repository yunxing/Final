// WARNING!!!!
// This RS was written by Ali Saidi 2 years ago and used for a final exam problem last year. 
// I've filled in the blanks that were in the exam, however you should not consider this 
// as a complete solution! It was simplified for the exam and won't handle many cases you'll 
// be required to handle in your design. You may use whatever parts of it you like for your 
// 470 project however, it is largely provided as an example as to how these reservation 
// stations should work. 


module rs1(rs1_dest_in,
	   rs1_opa_in,
	   rs1_opa_valid,
	   rs1_opb_in,
	   rs1_opb_valid,
	   
           rs1_cdb1_in,
	   rs1_cdb1_tag,
	   rs1_cdb1_valid,
	   
           rs1_cdb2_in,
	   rs1_cdb2_tag,
	   rs1_cdb2_valid,
	   
           rs1_cdb3_in,
	   rs1_cdb3_tag,
	   rs1_cdb3_valid,
	   
	   rs1_load_in,
	   PRNum_in,
	   ROBNum_in,
	   FunctionCode_in,
	   RS1_free_in,

	   rs1_avail_out, 
           rs1_ready_out,
	   rs1_opa_out,
	   rs1_opb_out,
	   rs1_use_enable,
	   FunctionCode,
	   PRNum,
	   ROBNum,
           reset,
	   clock); 
   
   input [4:0]  rs1_dest_in;    // The destination of this instruction
   
      
   input [63:0] rs1_cdb1_in;     // CDB bus from functional units 
   input [4:0] 	rs1_cdb1_tag;    // CDB tag bus from functional units 
   input        rs1_cdb1_valid;  // The data on the CDB is valid
      
   input [63:0] rs1_cdb2_in;     // CDB bus from functional units 
   input [4:0] 	rs1_cdb2_tag;    // CDB tag bus from functional units 
   input        rs1_cdb2_valid;  // The data on the CDB is valid
      
   input [63:0] rs1_cdb3_in;     // CDB bus from functional units 
   input [4:0] 	rs1_cdb3_tag;    // CDB tag bus from functional units 
   input        rs1_cdb3_valid;  // The data on the CDB is valid
   
     
   input [63:0] rs1_opa_in;     // Operand a from Rename  
   input [63:0] rs1_opb_in;     // Operand a from Rename 
   input        rs1_opa_valid;  // Is Opa a Tag or immediate data (READ THIS COMMENT) 
   input        rs1_opb_valid;  // Is Opb a tag or immediate data (READ THIS COMMENT) 
   input        rs1_load_in;    // Signal from rename to flop opa/b 
   input        rs1_use_enable; // Signal to send data to Func units AND to free this RS
   input 	RS1_free_in;
   input        reset;          // reset signal 
   input        clock;          // the clock
   input [`PRN_BITS - 1:0] PRNum_in;
   input [`ROB_BITS - 1:0] ROBNum_in;
   input [4:0] 		   FunctionCode_in;   
   
   output 		   rs1_ready_out;     // This RS is in use and ready to go to EX 
   output [63:0] 	   rs1_opa_out;       // This RS' opa 
   output [63:0] 	   rs1_opb_out;       // This RS' opb 
   // output [4:0] 	   rs1_dest_tag_out;  // This RS' destination tag  
   output 		   rs1_avail_out;     // Is this RS is available to be issued to
   output [4:0] 	   FunctionCode;
   output [`PRN_BITS - 1:0] PRNum;
   output [`ROB_BITS - 1:0] ROBNum;
   
   
   wor [63:0] 		    rs1_opa_out; 
   wor [63:0] 		    rs1_opb_out; 
//   wor [4:0] 		    rs1_dest_tag_out;  

   
   reg [63:0] 		    OPa;              // Operand A 
   reg [63:0] 		    OPb;              // Operand B 
   reg 			    OPaValid;         // Operand a Tag/Value 
   reg 			    OPbValid;         // Operand B Tag/Valuereg
   reg [4:0] 		    FunctionCode;
   reg [`PRN_BITS - 1:0]    PRNum;
   reg [`ROB_BITS - 1:0]    ROBNum;
   reg 			    InUse;            // InUse bit 
   // reg [4:0] 	 DestTag;          // Destination Tag bit 
   
         
   wire 		    LoadAFromCDB1;  // signal to load from the CDB 
   wire 		    LoadBFromCDB1;  // signal to load from the CDB 
         
   wire 		    LoadAFromCDB2;  // signal to load from the CDB 
   wire 		    LoadBFromCDB2;  // signal to load from the CDB 
         
   wire 		    LoadAFromCDB3;  // signal to load from the CDB 
   wire 		    LoadBFromCDB3;  // signal to load from the CDB 
      
   
   assign rs1_avail_out = ~InUse;
   
   assign rs1_ready_out = InUse & OPaValid & OPbValid; 
   
   assign rs1_opa_out = rs1_use_enable ? OPa : 64'b0; 
   
   assign rs1_opb_out = rs1_use_enable ? OPb : 64'b0; 
   
//   assign rs1_dest_tag_out = rs1_use_enable ? DestTag : 64'b0;
   
   // Has the tag we are waiting for shown up on the CDB
   
   assign LoadAFromCDB1 = (rs1_cdb1_tag[4:0] == OPa) && !OPaValid && InUse && rs1_cdb1_valid; 
   assign LoadBFromCDB1 = (rs1_cdb1_tag[4:0] == OPb) && !OPbValid && InUse && rs1_cdb1_valid; 
   
   assign LoadAFromCDB2 = (rs1_cdb2_tag[4:0] == OPa) && !OPaValid && InUse && rs1_cdb2_valid; 
   assign LoadBFromCDB2 = (rs1_cdb2_tag[4:0] == OPb) && !OPbValid && InUse && rs1_cdb2_valid; 
   
   assign LoadAFromCDB3 = (rs1_cdb3_tag[4:0] == OPa) && !OPaValid && InUse && rs1_cdb3_valid; 
   assign LoadBFromCDB3 = (rs1_cdb3_tag[4:0] == OPb) && !OPbValid && InUse && rs1_cdb3_valid; 
      


   always @(posedge clock) 
     begin 
	if (reset) 
	  begin 
             OPa <= `SD 0; 
             OPb <= `SD 0; 
             OPaValid <= `SD 0; 
             OPbValid <= `SD 0; 
             InUse <= `SD 1'b0; 
//             DestTag <= `SD 0;
	     FunctionCode <= `SD 0;
	     PRNum <= `SD 0;
	     ROBNum <= `SD 0;
	  end 
	else 
	  begin 
             if (rs1_load_in) 
               begin
		  FunctionCode <= `SD FunctionCode_in;
		  PRNum <= `SD PRNum_in;
		  ROBNum <= `SD ROBNum_in;
		  OPa <= `SD rs1_opa_in; 
		  OPb <= `SD rs1_opb_in; 
		  OPaValid <= `SD rs1_opa_valid; 
		  OPbValid <= `SD rs1_opb_valid; 
		  InUse <= `SD 1'b1; 
//		  DestTag <= `SD rs1_dest_in; 
               end 
             else 
               begin
		  		  
		  if (LoadAFromCDB1)
		    begin
                       OPa <= `SD rs1_cdb1_in;
                       OPaValid <= `SD 1'b1;
		    end
		  if (LoadBFromCDB1)
		    begin
                       OPb <= `SD rs1_cdb1_in;
                       OPbValid <= `SD 1'b1;
		    end
		  		  
		  if (LoadAFromCDB2)
		    begin
                       OPa <= `SD rs1_cdb2_in;
                       OPaValid <= `SD 1'b1;
		    end
		  if (LoadBFromCDB2)
		    begin
                       OPb <= `SD rs1_cdb2_in;
                       OPbValid <= `SD 1'b1;
		    end
		  		  
		  if (LoadAFromCDB3)
		    begin
                       OPa <= `SD rs1_cdb3_in;
                       OPaValid <= `SD 1'b1;
		    end
		  if (LoadBFromCDB3)
		    begin
                       OPb <= `SD rs1_cdb3_in;
                       OPbValid <= `SD 1'b1;
		    end
		  
		    
		  // Clear InUse bit once the FU has data
		  if (RS1_free_in)
		    begin
                       InUse <= `SD 0;
		    end
               end // else rs1_load_in 
	  end // else !reset 
     end // always @ 
endmodule  