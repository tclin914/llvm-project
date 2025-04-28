//==- RISCVSchedAndes45.td - Andes45 Scheduling Definitions --*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//

// FIXME: Implement sheduling model for V and other extensions.
def Andes45Model : SchedMachineModel {
  let MicroOpBufferSize = 0;  // Andes45 is in-order processor
  let IssueWidth = 2;         // 2 micro-ops dispatched per cycle
  let LoadLatency = 2;
  let MispredictPenalty = 5;
  let CompleteModel = 0;
}

let SchedModel = Andes45Model in {

//===----------------------------------------------------------------------===//
// Define each kind of processor resource and number available.

let BufferSize = 0 in {
def Andes45ALU : ProcResource<2>;
def Andes45MDU : ProcResource<1>;
def Andes45LSU : ProcResource<1>;
def Andes45CSR : ProcResource<1>;

def Andes45FMAC  : ProcResource<1>;
def Andes45FDIV  : ProcResource<1>;
def Andes45FMV   : ProcResource<1>;
def Andes45FMISC : ProcResource<1>;
}

def : WriteRes<WriteIALU, [Andes45ALU]> { let Latency = 3; }
def : WriteRes<WriteIALU32, [Andes45ALU]> { let Latency = 3; }
def : WriteRes<WriteShiftImm, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteShiftImm32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteShiftReg, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteShiftReg32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteJmp, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteJal, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteJalr, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteIMul, [Andes45MDU]> { let Latency = 11; }
def : WriteRes<WriteIMul32, [Andes45MDU]> { let Latency = 11; }
def : WriteRes<WriteIDiv, [Andes45MDU]> { let Latency = 39; }
def : WriteRes<WriteIDiv32, [Andes45MDU]> { let Latency = 39; }
def : WriteRes<WriteIRem, [Andes45MDU]> { let Latency = 39; }
def : WriteRes<WriteIRem32, [Andes45MDU]> { let Latency = 39; }
def : WriteRes<WriteLDB, [Andes45LSU]> { let Latency = 5; }
def : WriteRes<WriteLDH, [Andes45LSU]> { let Latency = 5; }
def : WriteRes<WriteLDW, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteLDD, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteSTB, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteSTH, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteSTW, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteSTD, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteCSR, [Andes45CSR]> { let Latency = 4; }
def : WriteRes<WriteNop, []>;

def : ReadAdvance<ReadIALU, 1>;
def : ReadAdvance<ReadIALU32, 1>;
def : ReadAdvance<ReadShiftImm, 1>;
def : ReadAdvance<ReadShiftImm32, 1>;
def : ReadAdvance<ReadShiftReg, 1>;
def : ReadAdvance<ReadShiftReg32, 1>;
def : ReadAdvance<ReadJalr, 1>;
def : ReadAdvance<ReadJmp, 1>;
def : ReadAdvance<ReadMemBase, 1>;
def : ReadAdvance<ReadIMul, 1>;
def : ReadAdvance<ReadIMul32, 1>;
def : ReadAdvance<ReadIDiv, 1>;
def : ReadAdvance<ReadIDiv32, 1>;
def : ReadAdvance<ReadIRem, 1>;
def : ReadAdvance<ReadIRem32, 1>;
def : ReadAdvance<ReadStoreData, 1>;
def : ReadAdvance<ReadCSR, 3>;

def : WriteRes<WriteAtomicW, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteAtomicD, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteAtomicLDW, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteAtomicLDD, [Andes45LSU]> { let Latency = 3; }
def : WriteRes<WriteAtomicSTW, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteAtomicSTD, [Andes45LSU]> { let Latency = 1; }

def : ReadAdvance<ReadAtomicDA, 1>;
def : ReadAdvance<ReadAtomicDD, 1>;
def : ReadAdvance<ReadAtomicWA, 1>;
def : ReadAdvance<ReadAtomicWD, 1>;
def : ReadAdvance<ReadAtomicLDW, 1>;
def : ReadAdvance<ReadAtomicSTW, 1>;
def : ReadAdvance<ReadAtomicLDD, 1>;
def : ReadAdvance<ReadAtomicSTD, 1>;

// Subtarget-specific FPU SchedWrite types which map ProcResources and latency.
def : WriteRes<WriteFLD16, [Andes45LSU]> { let Latency = 4; }
def : WriteRes<WriteFLD32, [Andes45LSU]> { let Latency = 4; }
def : WriteRes<WriteFLD64, [Andes45LSU]> { let Latency = 4; }
def : WriteRes<WriteFST16, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteFST32, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteFST64, [Andes45LSU]> { let Latency = 1; }
def : WriteRes<WriteFMinMax16, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFMinMax32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFMinMax64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFSGNJ16, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFSGNJ32, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFSGNJ64, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFAdd16, [Andes45FMAC]> { let Latency = 3; }
def : WriteRes<WriteFAdd32, [Andes45FMAC]> { let Latency = 5; }
def : WriteRes<WriteFAdd64, [Andes45FMAC]> { let Latency = 6; }
def : WriteRes<WriteFMul16, [Andes45FMAC]> { let Latency = 5; }
def : WriteRes<WriteFMul32, [Andes45FMAC]> { let Latency = 5; }
def : WriteRes<WriteFMul64, [Andes45FMAC]> { let Latency = 6; }
def : WriteRes<WriteFMA16, [Andes45FMAC]> { let Latency = 5; }
def : WriteRes<WriteFMA32, [Andes45FMAC]> { let Latency = 5; }
def : WriteRes<WriteFMA64, [Andes45FMAC]> { let Latency = 6; }
def : WriteRes<WriteFDiv16, [Andes45FDIV]> { let Latency = 33; }
def : WriteRes<WriteFSqrt16, [Andes45FDIV]> { let Latency = 32; }
def : WriteRes<WriteFDiv32, [Andes45FDIV]> { let Latency = 33; }
def : WriteRes<WriteFSqrt32, [Andes45FDIV]> { let Latency = 32; }
def : WriteRes<WriteFDiv64, [Andes45FDIV]> { let Latency = 33; }
def : WriteRes<WriteFSqrt64, [Andes45FDIV]> { let Latency = 32; }
def : WriteRes<WriteFCvtF16ToI32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF16ToI64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF32ToI32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF32ToI64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF64ToI32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF64ToI64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI32ToF16, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI32ToF32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI32ToF64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI64ToF16, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI64ToF32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtI64ToF64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF16ToF32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF16ToF64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF32ToF16, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF32ToF64, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF64ToF16, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFCvtF64ToF32, [Andes45FMISC]> { let Latency = 2; }
def : WriteRes<WriteFClass16, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFClass32, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFClass64, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFCmp16, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFCmp32, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFCmp64, [Andes45FMISC]> { let Latency = 3; }
def : WriteRes<WriteFMovF16ToI16, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFMovI16ToF16, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFMovF32ToI32, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFMovI32ToF32, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFMovF64ToI64, [Andes45FMV]> { let Latency = 2; }
def : WriteRes<WriteFMovI64ToF64, [Andes45FMV]> { let Latency = 2; }

def : ReadAdvance<ReadFStoreData, 2>;
def : ReadAdvance<ReadFMemBase, 2>;
def : ReadAdvance<ReadFMinMax16, 1>;
def : ReadAdvance<ReadFMinMax32, 1>;
def : ReadAdvance<ReadFMinMax64, 1>;
def : ReadAdvance<ReadFSGNJ16, 1>;
def : ReadAdvance<ReadFSGNJ32, 1>;
def : ReadAdvance<ReadFSGNJ64, 1>;
def : ReadAdvance<ReadFAdd16, 1>;
def : ReadAdvance<ReadFAdd32, 1>;
def : ReadAdvance<ReadFAdd64, 1>;
def : ReadAdvance<ReadFMul16, 1>;
def : ReadAdvance<ReadFMul32, 1>;
def : ReadAdvance<ReadFMul64, 1>;
def : ReadAdvance<ReadFMA16, 1>;
def : ReadAdvance<ReadFMA16Addend, 1>;
def : ReadAdvance<ReadFMA32, 1>;
def : ReadAdvance<ReadFMA32Addend, 1>;
def : ReadAdvance<ReadFMA64, 1>;
def : ReadAdvance<ReadFMA64Addend, 1>;
def : ReadAdvance<ReadFDiv16, 1>;
def : ReadAdvance<ReadFDiv32, 1>;
def : ReadAdvance<ReadFDiv64, 1>;
def : ReadAdvance<ReadFSqrt16, 1>;
def : ReadAdvance<ReadFSqrt32, 1>;
def : ReadAdvance<ReadFSqrt64, 1>;
def : ReadAdvance<ReadFCvtF16ToI32, 1>;
def : ReadAdvance<ReadFCvtF16ToI64, 1>;
def : ReadAdvance<ReadFCvtF32ToI32, 1>;
def : ReadAdvance<ReadFCvtF32ToI64, 1>;
def : ReadAdvance<ReadFCvtF64ToI32, 1>;
def : ReadAdvance<ReadFCvtF64ToI64, 1>;
def : ReadAdvance<ReadFCvtI32ToF16, 1>;
def : ReadAdvance<ReadFCvtI32ToF32, 1>;
def : ReadAdvance<ReadFCvtI32ToF64, 1>;
def : ReadAdvance<ReadFCvtI64ToF16, 1>;
def : ReadAdvance<ReadFCvtI64ToF32, 1>;
def : ReadAdvance<ReadFCvtI64ToF64, 1>;
def : ReadAdvance<ReadFCvtF16ToF32, 1>;
def : ReadAdvance<ReadFCvtF16ToF64, 1>;
def : ReadAdvance<ReadFCvtF32ToF16, 1>;
def : ReadAdvance<ReadFCvtF32ToF64, 1>;
def : ReadAdvance<ReadFCvtF64ToF16, 1>;
def : ReadAdvance<ReadFCvtF64ToF32, 1>;
def : ReadAdvance<ReadFCmp16, 1>;
def : ReadAdvance<ReadFCmp32, 1>;
def : ReadAdvance<ReadFCmp64, 1>;
def : ReadAdvance<ReadFClass16, 1>;
def : ReadAdvance<ReadFClass32, 1>;
def : ReadAdvance<ReadFClass64, 1>;
def : ReadAdvance<ReadFMovF16ToI16, 1>;
def : ReadAdvance<ReadFMovI16ToF16, 1>;
def : ReadAdvance<ReadFMovF32ToI32, 1>;
def : ReadAdvance<ReadFMovI32ToF32, 1>;
def : ReadAdvance<ReadFMovF64ToI64, 1>;
def : ReadAdvance<ReadFMovI64ToF64, 1>;

// Zba extension
def : WriteRes<WriteSHXADD, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteSHXADD32, [Andes45ALU]> { let Latency = 2; }

// Zbb extension
def : WriteRes<WriteRotateImm, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteRotateImm32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteRotateReg, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteRotateReg32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCLZ, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCLZ32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCTZ, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCTZ32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCPOP, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteCPOP32, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteREV8, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteORCB, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteIMinMax, [Andes45ALU]> { let Latency = 2; }

// Zbc extension
def : WriteRes<WriteCLMUL, [Andes45ALU]> { let Latency = 2; }

// Zbs extension
def : WriteRes<WriteSingleBit, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteSingleBitImm, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteBEXT, [Andes45ALU]> { let Latency = 2; }
def : WriteRes<WriteBEXTI, [Andes45ALU]> { let Latency = 2; }

// Subtarget-specific RVB extension SchedRead types which map to generics.
// Zba extension
def : ReadAdvance<ReadSHXADD, 1>;
def : ReadAdvance<ReadSHXADD32, 1>;

// Zbb extension
def : ReadAdvance<ReadRotateImm, 1>;
def : ReadAdvance<ReadRotateImm32, 1>;
def : ReadAdvance<ReadRotateReg, 1>;
def : ReadAdvance<ReadRotateReg32, 1>;
def : ReadAdvance<ReadCLZ, 1>;
def : ReadAdvance<ReadCLZ32, 1>;
def : ReadAdvance<ReadCTZ, 1>;
def : ReadAdvance<ReadCTZ32, 1>;
def : ReadAdvance<ReadCPOP, 1>;
def : ReadAdvance<ReadCPOP32, 1>;
def : ReadAdvance<ReadREV8, 1>;
def : ReadAdvance<ReadORCB, 1>;
def : ReadAdvance<ReadIMinMax, 1>;

// Zbc extension
def : ReadAdvance<ReadCLMUL, 1>;

// Zbs extension
def : ReadAdvance<ReadSingleBit, 1>;
def : ReadAdvance<ReadSingleBitImm, 1>;

//===----------------------------------------------------------------------===//
// Unsupported extensions
defm : UnsupportedSchedSFB;
defm : UnsupportedSchedV;
defm : UnsupportedSchedXsfvcp;
defm : UnsupportedSchedZabha;
defm : UnsupportedSchedZbkb;
defm : UnsupportedSchedZbkx;
defm : UnsupportedSchedZfa;
defm : UnsupportedSchedZvk;
}

