//==- RISCVSchedAndes45.td - Andes45 Scheduling Definitions --*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//

// The latency varies depending on the memory type and status.
defvar VLSU_MEM_LATENCY = 13;

/// c is true if mx has the worst case behavior compared to LMULs in MxList.
/// On the Andes45, the worst case LMUL is the Largest LMUL
/// and the worst case sew is the smallest SEW for that LMUL.
class Andes45IsWorstCaseMX<string mx, list<string> MxList> {
  defvar LLMUL = LargestLMUL<MxList>.r;
  bit c = !eq(mx, LLMUL);
}

/// c is true if mx and sew have the worst case behavior compared to LMULs in
/// MxList. On the Andes45, the worst case LMUL is the Largest LMUL
/// and the worst case sew is the smallest SEW for that LMUL.
class Andes45IsWorstCaseMXSEW<string mx, int sew, list<string> MxList,
                               bit isF = 0> {
  defvar LLMUL = LargestLMUL<MxList>.r;
  defvar SSEW = SmallestSEW<mx, isF>.r;
  bit c = !and(!eq(mx, LLMUL), !eq(sew, SSEW));
}

/// Number of DLEN parts = (LMUL * VLEN) / DLEN.
/// Since DLEN = VLEN / 2, Num DLEN parts = 2 * LMUL.
class Andes45GetCyclesDefault<string mx> {
  int c = !cond(
    !eq(mx, "M1") : 2,
    !eq(mx, "M2") : 4,
    !eq(mx, "M4") : 8,
    !eq(mx, "M8") : 16,
    !eq(mx, "MF2") : 1,
    !eq(mx, "MF4") : 1,
    !eq(mx, "MF8") : 1
  );
}

class Andes45GetCyclesNarrowing<string mx> {
  int c = !cond(
    !eq(mx, "M1") : 4,
    !eq(mx, "M2") : 8,
    !eq(mx, "M4") : 16,
    !eq(mx, "MF2") : 2,
    !eq(mx, "MF4") : 1,
    !eq(mx, "MF8") : 1
  );
}

class Andes45GetCyclesVMask<string mx> {
  int c = !cond(
    !eq(mx, "M1") : 1,
    !eq(mx, "M2") : 1,
    !eq(mx, "M4") : 1,
    !eq(mx, "M8") : 2,
    !eq(mx, "MF2") : 1,
    !eq(mx, "MF4") : 1,
    !eq(mx, "MF8") : 1
  );
}

/// VLDM and VSTM can't read/write more than 2 DLENs of data.
/// 2 DLENs when LMUL=8. 1 DLEN for all other DLENs
class Andes45GetMaskLoadStoreCycles<string mx> {
  int c = !cond(
    !eq(mx, "M8")  : 2,
    true : 1
  );
}

// Cycles for nf=2 segmented loads and stores are calculated using the
// formula (2 * VLEN * LMUL) / DLEN = 4 * LMUL
class Andes45GetCyclesSegmentedSeg2<string mx> {
  int c = !cond(
    !eq(mx, "M1") :  4,
    !eq(mx, "M2") :  8,
    !eq(mx, "M4") :  16,
    !eq(mx, "M8") :  32,
    !eq(mx, "MF2") : 2,
    !eq(mx, "MF4") : 1,
    !eq(mx, "MF8") : 1
  );
}

// Cycles for segmented loads and stores are calculated using the
// formula vl * ceil((SEW * nf) / DLEN), where SEW * nf is the segment size.
class Andes45GetCyclesSegmented<string mx, int sew, int nf> {
  defvar VLEN = 512;
  defvar DLEN = 256;
  // (VLEN * LMUL) / SEW
  defvar VLUpperBound  = !cond(
    !eq(mx, "M1") : !div(VLEN, sew),
    !eq(mx, "M2") : !div(!mul(VLEN, 2), sew),
    !eq(mx, "M4") : !div(!mul(VLEN, 4), sew),
    !eq(mx, "M8") : !div(!mul(VLEN, 8), sew),
    !eq(mx, "MF2") : !div(!div(VLEN, 2), sew),
    !eq(mx, "MF4") : !div(!div(VLEN, 4), sew),
    !eq(mx, "MF8") : !div(!div(VLEN, 8), sew),
  );
  // We can calculate ceil(a/b) using (a + b - 1) / b.
  defvar a = !mul(sew, nf);
  defvar b = DLEN;
  int c = !mul(VLUpperBound, !div(!sub(!add(a, b), 1), b));
}

class Andes45GetCyclesOnePerElement<string mx, int sew> {
  // FIXME: On Andes45, VLEN is 512. Although a user can request the compiler
  // to use a different VLEN, this model will not make scheduling decisions
  // based on the user specified VLEN.
  // c = ceil(VLEN / SEW) * LMUL
  // Note: c >= 1 since the smallest VLEN is 512 / 8 = 8, and the
  // largest division performed on VLEN is in MF8 case with division
  // by 8. Therefore, there is no need to ceil the result.
  int VLEN = !div(512, sew);
  int c = !cond(
    !eq(mx, "M1")  : VLEN,
    !eq(mx, "M2")  : !mul(VLEN, 2),
    !eq(mx, "M4")  : !mul(VLEN, 4),
    !eq(mx, "M8")  : !mul(VLEN, 8),
    !eq(mx, "MF2") : !div(VLEN, 2),
    !eq(mx, "MF4") : !div(VLEN, 4),
    !eq(mx, "MF8") : !div(VLEN, 8)
  );
}

class Andes45GetDivOrSqrtFactor<int sew> {
  int c = !cond(
    // TODO: Add SchedSEWSetFP upstream and remove the SEW=8 case.
    !eq(sew, 8) : 15,
    !eq(sew, 16) : 15,
    !eq(sew, 32) : 28,
    !eq(sew, 64) : 57
  );
}

/// Cycles for reductions take approximately VL*SEW/DLEN + 5(4 + log(DLEN/SEW))
/// cycles.
class Andes45GetReductionCycles<string mx, int sew> {
  // VLUpperBound*SEW/DLEN is equivalent to 2*LMUL since
  // VLUpperBound=(VLEN*LMUL)/SEW.
  defvar VLEN = 512;
  defvar DLEN = !div(VLEN, 2);
  defvar TwoTimesLMUL = !cond(
    !eq(mx, "M1") : 2,
    !eq(mx, "M2") : 4,
    !eq(mx, "M4") : 8,
    !eq(mx, "M8") : 16,
    !eq(mx, "MF2") : 1,
    !eq(mx, "MF4") : 1,
    !eq(mx, "MF8") : 1
  );
  int c = !add(
    TwoTimesLMUL,
    !mul(5, !add(4, !logtwo(!div(DLEN, sew))))
  );
}

/// Cycles for ordered reductions take approximately 6*VL cycles
class Andes45GetOrderedReductionCycles<string mx, int sew> {
  defvar VLEN = 512;
  // (VLEN * LMUL) / SEW
  defvar VLUpperBound  = !cond(
    !eq(mx, "M1") : !div(VLEN, sew),
    !eq(mx, "M2") : !div(!mul(VLEN, 2), sew),
    !eq(mx, "M4") : !div(!mul(VLEN, 4), sew),
    !eq(mx, "M8") : !div(!mul(VLEN, 8), sew),
    !eq(mx, "MF2") : !div(!div(VLEN, 2), sew),
    !eq(mx, "MF4") : !div(!div(VLEN, 4), sew),
    !eq(mx, "MF8") : !div(!div(VLEN, 8), sew),
  );
  int c = !mul(6, VLUpperBound);
}

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

//===----------------------------------------------------------------------===//
// Andes 45 series CPU
//   - 2 Interger Arithmetic and Logical Units (ALU)
//   - Multiply / Divide Unit (MDU)
//   - Load Store Unit (LSU)
//   - Control and Status Register Unit (CSR)
//   - Floating Point Multiply-Accumulate Unit (FMAC)
//   - Floating Point Divide / SQRT Unit (FDIV)
//   - Floating Point Move Unit (FMV)
//   - Floating Point Misc Unit (FMISC)
//===----------------------------------------------------------------------===//

let BufferSize = 0 in {
def Andes45ALU : ProcResource<2>;
def Andes45MDU : ProcResource<1>;
def Andes45LSU : ProcResource<1>;
def Andes45CSR : ProcResource<1>;

def Andes45FMAC  : ProcResource<1>;
def Andes45FDIV  : ProcResource<1>;
def Andes45FMV   : ProcResource<1>;
def Andes45FMISC : ProcResource<1>;

// VPU
def Andes45VALU    : ProcResource<1>;
def Andes45VMAC    : ProcResource<1>;
def Andes45VFMIS   : ProcResource<1>;
def Andes45VLSU    : ProcResource<1>;
def Andes45VMASK   : ProcResource<1>;
def Andes45VPERMUT : ProcResource<1>;
def Andes45VDIV    : ProcResource<1>;
def Andes45VFDIV   : ProcResource<1>;
}

// Integer arithmetic and logic
def : WriteRes<WriteIALU, [Andes45ALU]>;
def : WriteRes<WriteIALU32, [Andes45ALU]>;
def : WriteRes<WriteShiftImm, [Andes45ALU]>;
def : WriteRes<WriteShiftImm32, [Andes45ALU]>;
def : WriteRes<WriteShiftReg, [Andes45ALU]>;
def : WriteRes<WriteShiftReg32, [Andes45ALU]>;

// Branching
def : WriteRes<WriteJmp, [Andes45ALU]>;
def : WriteRes<WriteJal, [Andes45ALU]>;
def : WriteRes<WriteJalr, [Andes45ALU]>;

// Integer multiplication
let Latency = 3 in {
def : WriteRes<WriteIMul, [Andes45MDU]>;
def : WriteRes<WriteIMul32, [Andes45MDU]>;
}

// Integer division
let Latency = 39, ReleaseAtCycles = [39] in {
def : WriteRes<WriteIDiv, [Andes45MDU]>;
def : WriteRes<WriteIDiv32, [Andes45MDU]>;
}

// Integer remainder
let Latency = 39, ReleaseAtCycles = [39] in {
def : WriteRes<WriteIRem, [Andes45MDU]>;
def : WriteRes<WriteIRem32, [Andes45MDU]>;
}

// Memory
let Latency = 5 in {
def : WriteRes<WriteLDB, [Andes45LSU]>;
def : WriteRes<WriteLDH, [Andes45LSU]>;
def : WriteRes<WriteFLD16, [Andes45LSU]>;
}

let Latency = 3 in {
def : WriteRes<WriteLDW, [Andes45LSU]>;
def : WriteRes<WriteLDD, [Andes45LSU]>;
def : WriteRes<WriteFLD32, [Andes45LSU]>;
def : WriteRes<WriteFLD64, [Andes45LSU]>;
}

let Latency = 1 in {
def : WriteRes<WriteSTB, [Andes45LSU]>;
def : WriteRes<WriteSTH, [Andes45LSU]>;
def : WriteRes<WriteSTW, [Andes45LSU]>;
def : WriteRes<WriteSTD, [Andes45LSU]>;
def : WriteRes<WriteFST16, [Andes45LSU]>;
def : WriteRes<WriteFST32, [Andes45LSU]>;
def : WriteRes<WriteFST64, [Andes45LSU]>;
}

// Atomic Memory
let Latency = 9 in {
def : WriteRes<WriteAtomicW, [Andes45LSU]>;
def : WriteRes<WriteAtomicD, [Andes45LSU]>;
def : WriteRes<WriteAtomicLDW, [Andes45LSU]>;
def : WriteRes<WriteAtomicLDD, [Andes45LSU]>;
}

let Latency = 3 in {
def : WriteRes<WriteAtomicSTW, [Andes45LSU]>;
def : WriteRes<WriteAtomicSTD, [Andes45LSU]>;
}

// FMAC
let Latency = 4 in  {
def : WriteRes<WriteFAdd16, [Andes45FMAC]>;
def : WriteRes<WriteFAdd32, [Andes45FMAC]>;
def : WriteRes<WriteFAdd64, [Andes45FMAC]>;
def : WriteRes<WriteFMul16, [Andes45FMAC]>;
def : WriteRes<WriteFMul32, [Andes45FMAC]>;
def : WriteRes<WriteFMul64, [Andes45FMAC]>;
def : WriteRes<WriteFMA16, [Andes45FMAC]>;
def : WriteRes<WriteFMA32, [Andes45FMAC]>;
def : WriteRes<WriteFMA64, [Andes45FMAC]>;
}

// FDIV
let Latency = 12, ReleaseAtCycles = [12] in
def : WriteRes<WriteFDiv16, [Andes45FDIV]>;
let Latency = 11, ReleaseAtCycles = [11] in
def : WriteRes<WriteFSqrt16, [Andes45FDIV]>;

let Latency = 19, ReleaseAtCycles = [19] in
def : WriteRes<WriteFDiv32, [Andes45FDIV]>;
let Latency = 18, ReleaseAtCycles = [18] in
def : WriteRes<WriteFSqrt32, [Andes45FDIV]>;

let Latency = 33, ReleaseAtCycles = [33] in
def : WriteRes<WriteFDiv64, [Andes45FDIV]>;
let Latency = 32, ReleaseAtCycles = [32] in
def : WriteRes<WriteFSqrt64, [Andes45FDIV]>;

// FMV
def : WriteRes<WriteFSGNJ16, [Andes45FMV]>;
def : WriteRes<WriteFSGNJ32, [Andes45FMV]>;
def : WriteRes<WriteFSGNJ64, [Andes45FMV]>;
def : WriteRes<WriteFMovF16ToI16, [Andes45FMV]>;
def : WriteRes<WriteFMovI16ToF16, [Andes45FMV]>;
def : WriteRes<WriteFMovF32ToI32, [Andes45FMV]>;
def : WriteRes<WriteFMovI32ToF32, [Andes45FMV]>;
def : WriteRes<WriteFMovF64ToI64, [Andes45FMV]>;
def : WriteRes<WriteFMovI64ToF64, [Andes45FMV]>;

// FMISC
let Latency = 2 in  {
def : WriteRes<WriteFMinMax16, [Andes45FMISC]>;
def : WriteRes<WriteFMinMax32, [Andes45FMISC]>;
def : WriteRes<WriteFMinMax64, [Andes45FMISC]>;
def : WriteRes<WriteFClass16, [Andes45FMISC]>;
def : WriteRes<WriteFClass32, [Andes45FMISC]>;
def : WriteRes<WriteFClass64, [Andes45FMISC]>;
def : WriteRes<WriteFCmp16, [Andes45FMISC]>;
def : WriteRes<WriteFCmp32, [Andes45FMISC]>;
def : WriteRes<WriteFCmp64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF16ToI32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF16ToI64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF32ToI32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF32ToI64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF64ToI32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF64ToI64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI32ToF16, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI32ToF32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI32ToF64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI64ToF16, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI64ToF32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtI64ToF64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF16ToF32, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF16ToF64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF32ToF16, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF32ToF64, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF64ToF16, [Andes45FMISC]>;
def : WriteRes<WriteFCvtF64ToF32, [Andes45FMISC]>;
}

// Bitmanip
// Zba extension
def : WriteRes<WriteSHXADD, [Andes45ALU]>;
def : WriteRes<WriteSHXADD32, [Andes45ALU]>;

// Zbb extension
def : WriteRes<WriteRotateImm, [Andes45ALU]>;
def : WriteRes<WriteRotateImm32, [Andes45ALU]>;
def : WriteRes<WriteRotateReg, [Andes45ALU]>;
def : WriteRes<WriteRotateReg32, [Andes45ALU]>;
def : WriteRes<WriteREV8, [Andes45ALU]>;
def : WriteRes<WriteORCB, [Andes45ALU]>;
def : WriteRes<WriteIMinMax, [Andes45ALU]>;

let Latency = 3 in  {
def : WriteRes<WriteCLZ, [Andes45ALU]>;
def : WriteRes<WriteCLZ32, [Andes45ALU]>;
def : WriteRes<WriteCTZ, [Andes45ALU]>;
def : WriteRes<WriteCTZ32, [Andes45ALU]>;
def : WriteRes<WriteCPOP, [Andes45ALU]>;
def : WriteRes<WriteCPOP32, [Andes45ALU]>;
}

// Zbc extension
let Latency = 3 in
def : WriteRes<WriteCLMUL, [Andes45ALU]>;

// Zbs extension
def : WriteRes<WriteSingleBit, [Andes45ALU]>;
def : WriteRes<WriteSingleBitImm, [Andes45ALU]>;
def : WriteRes<WriteBEXT, [Andes45ALU]>;
def : WriteRes<WriteBEXTI, [Andes45ALU]>;

// 6. Configuration-Setting Instructions
def : WriteRes<WriteVSETVLI, [Andes45CSR]>;
def : WriteRes<WriteVSETIVLI, [Andes45CSR]>;
def : WriteRes<WriteVSETVL, [Andes45CSR]>;

// Others
def : WriteRes<WriteCSR, [Andes45CSR]>;
def : WriteRes<WriteNop, []>;

//===----------------------------------------------------------------------===//

// Bypass and advance
def : ReadAdvance<ReadIALU, 0>;
def : ReadAdvance<ReadIALU32, 0>;
def : ReadAdvance<ReadShiftImm, 0>;
def : ReadAdvance<ReadShiftImm32, 0>;
def : ReadAdvance<ReadShiftReg, 0>;
def : ReadAdvance<ReadShiftReg32, 0>;
def : ReadAdvance<ReadJalr, 0>;
def : ReadAdvance<ReadJmp, 0>;
def : ReadAdvance<ReadIMul, 0>;
def : ReadAdvance<ReadIMul32, 0>;
def : ReadAdvance<ReadIDiv, 0>;
def : ReadAdvance<ReadIDiv32, 0>;
def : ReadAdvance<ReadIRem, 0>;
def : ReadAdvance<ReadIRem32, 0>;
def : ReadAdvance<ReadStoreData, 0>;
def : ReadAdvance<ReadMemBase, 0>;
def : ReadAdvance<ReadAtomicWA, 0>;
def : ReadAdvance<ReadAtomicWD, 0>;
def : ReadAdvance<ReadAtomicDA, 0>;
def : ReadAdvance<ReadAtomicDD, 0>;
def : ReadAdvance<ReadAtomicLDW, 0>;
def : ReadAdvance<ReadAtomicLDD, 0>;
def : ReadAdvance<ReadAtomicSTW, 0>;
def : ReadAdvance<ReadAtomicSTD, 0>;
def : ReadAdvance<ReadFStoreData, 0>;
def : ReadAdvance<ReadFMemBase, 0>;
def : ReadAdvance<ReadFAdd16, 0>;
def : ReadAdvance<ReadFAdd32, 0>;
def : ReadAdvance<ReadFAdd64, 0>;
def : ReadAdvance<ReadFMul16, 0>;
def : ReadAdvance<ReadFMul32, 0>;
def : ReadAdvance<ReadFMul64, 0>;
def : ReadAdvance<ReadFMA16, 0>;
def : ReadAdvance<ReadFMA32, 0>;
def : ReadAdvance<ReadFMA64, 0>;
def : ReadAdvance<ReadFMA16Addend, 0>;
def : ReadAdvance<ReadFMA32Addend, 0>;
def : ReadAdvance<ReadFMA64Addend, 0>;
def : ReadAdvance<ReadFDiv16, 0>;
def : ReadAdvance<ReadFDiv32, 0>;
def : ReadAdvance<ReadFDiv64, 0>;
def : ReadAdvance<ReadFSqrt16, 0>;
def : ReadAdvance<ReadFSqrt32, 0>;
def : ReadAdvance<ReadFSqrt64, 0>;
def : ReadAdvance<ReadFSGNJ16, 0>;
def : ReadAdvance<ReadFSGNJ32, 0>;
def : ReadAdvance<ReadFSGNJ64, 0>;
def : ReadAdvance<ReadFMovF16ToI16, 0>;
def : ReadAdvance<ReadFMovI16ToF16, 0>;
def : ReadAdvance<ReadFMovF32ToI32, 0>;
def : ReadAdvance<ReadFMovI32ToF32, 0>;
def : ReadAdvance<ReadFMovF64ToI64, 0>;
def : ReadAdvance<ReadFMovI64ToF64, 0>;
def : ReadAdvance<ReadFMinMax16, 0>;
def : ReadAdvance<ReadFMinMax32, 0>;
def : ReadAdvance<ReadFMinMax64, 0>;
def : ReadAdvance<ReadFClass16, 0>;
def : ReadAdvance<ReadFClass32, 0>;
def : ReadAdvance<ReadFClass64, 0>;
def : ReadAdvance<ReadFCmp16, 0>;
def : ReadAdvance<ReadFCmp32, 0>;
def : ReadAdvance<ReadFCmp64, 0>;
def : ReadAdvance<ReadFCvtF16ToI32, 0>;
def : ReadAdvance<ReadFCvtF16ToI64, 0>;
def : ReadAdvance<ReadFCvtF32ToI32, 0>;
def : ReadAdvance<ReadFCvtF32ToI64, 0>;
def : ReadAdvance<ReadFCvtF64ToI32, 0>;
def : ReadAdvance<ReadFCvtF64ToI64, 0>;
def : ReadAdvance<ReadFCvtI32ToF16, 0>;
def : ReadAdvance<ReadFCvtI32ToF32, 0>;
def : ReadAdvance<ReadFCvtI32ToF64, 0>;
def : ReadAdvance<ReadFCvtI64ToF16, 0>;
def : ReadAdvance<ReadFCvtI64ToF32, 0>;
def : ReadAdvance<ReadFCvtI64ToF64, 0>;
def : ReadAdvance<ReadFCvtF16ToF32, 0>;
def : ReadAdvance<ReadFCvtF16ToF64, 0>;
def : ReadAdvance<ReadFCvtF32ToF16, 0>;
def : ReadAdvance<ReadFCvtF32ToF64, 0>;
def : ReadAdvance<ReadFCvtF64ToF16, 0>;
def : ReadAdvance<ReadFCvtF64ToF32, 0>;
def : ReadAdvance<ReadSHXADD, 0>;
def : ReadAdvance<ReadSHXADD32, 0>;
def : ReadAdvance<ReadRotateImm, 1>;
def : ReadAdvance<ReadRotateImm32, 1>;
def : ReadAdvance<ReadRotateReg, 1>;
def : ReadAdvance<ReadRotateReg32, 1>;
def : ReadAdvance<ReadCLZ, 0>;
def : ReadAdvance<ReadCLZ32, 0>;
def : ReadAdvance<ReadCTZ, 0>;
def : ReadAdvance<ReadCTZ32, 0>;
def : ReadAdvance<ReadCPOP, 0>;
def : ReadAdvance<ReadCPOP32, 0>;
def : ReadAdvance<ReadREV8, 0>;
def : ReadAdvance<ReadORCB, 0>;
def : ReadAdvance<ReadIMinMax, 0>;
def : ReadAdvance<ReadCLMUL, 0>;
def : ReadAdvance<ReadSingleBit, 0>;
def : ReadAdvance<ReadSingleBitImm, 0>;
def : ReadAdvance<ReadCSR, 0>;

//===----------------------------------------------------------------------===//
// Unsupported extensions
defm : UnsupportedSchedQ;
defm : UnsupportedSchedSFB;
// defm : UnsupportedSchedV;
defm : UnsupportedSchedXsfvcp;
defm : UnsupportedSchedZabha;
defm : UnsupportedSchedZbkb;
defm : UnsupportedSchedZbkx;
defm : UnsupportedSchedZfa;
defm : UnsupportedSchedZvk;
}
