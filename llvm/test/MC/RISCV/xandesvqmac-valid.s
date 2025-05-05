# XAndesVQMac - Andes Vector Quad-Widening Integer Multiply-Add Extension
# RUN: llvm-mc %s -triple=riscv32 -mattr=+xandesvqmac -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+xandesvqmac < %s \
# RUN:     | llvm-objdump --mattr=+xandesvqmac -M no-aliases --no-print-imm-hex -d -r - \
# RUN:     | FileCheck -check-prefixes=CHECK-OBJ %s
# RUN: not llvm-mc -triple=riscv32 -show-encoding %s 2>&1 \
# RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
# RUN: llvm-mc %s -triple=riscv64 -mattr=+xandesvqmac -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM %s
# RUN: llvm-mc -filetype=obj -triple riscv64 -mattr=+xandesvqmac < %s \
# RUN:     | llvm-objdump --mattr=+xandesvqmac -M no-aliases --no-print-imm-hex -d -r - \
# RUN:     | FileCheck -check-prefixes=CHECK-OBJ %s
# RUN: not llvm-mc -triple=riscv64 -show-encoding %s 2>&1 \
# RUN:        | FileCheck %s --check-prefix=CHECK-ERROR

# CHECK-OBJ: nds.vqmaccu.vv v8, v12, v14, v0.t
# CHECK-ASM: nds.vqmaccu.vv v8, v12, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccu.vv v8, v12, v14, v0.t

# CHECK-OBJ: nds.vqmaccu.vv v8, v12, v14
# CHECK-ASM: nds.vqmaccu.vv v8, v12, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccu.vv v8, v12, v14

# CHECK-OBJ: nds.vqmaccu.vx v8, a0, v14, v0.t
# CHECK-ASM: nds.vqmaccu.vx v8, a0, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccu.vx v8, a0, v14, v0.t

# CHECK-OBJ: nds.vqmaccu.vx v8, a0, v14
# CHECK-ASM: nds.vqmaccu.vx v8, a0, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccu.vx v8, a0, v14

# CHECK-OBJ: nds.vqmacc.vv v8, v12, v14, v0.t
# CHECK-ASM: nds.vqmacc.vv v8, v12, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmacc.vv v8, v12, v14, v0.t

# CHECK-OBJ: nds.vqmacc.vv v8, v12, v14
# CHECK-ASM: nds.vqmacc.vv v8, v12, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmacc.vv v8, v12, v14

# CHECK-OBJ: nds.vqmacc.vx v8, a0, v14, v0.t
# CHECK-ASM: nds.vqmacc.vx v8, a0, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmacc.vx v8, a0, v14, v0.t

# CHECK-OBJ: nds.vqmacc.vx v8, a0, v14
# CHECK-ASM: nds.vqmacc.vx v8, a0, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmacc.vx v8, a0, v14

# CHECK-OBJ: nds.vqmaccsu.vv v8, v12, v14, v0.t
# CHECK-ASM: nds.vqmaccsu.vv v8, v12, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccsu.vv v8, v12, v14, v0.t

# CHECK-OBJ: nds.vqmaccsu.vv v8, v12, v14
# CHECK-ASM: nds.vqmaccsu.vv v8, v12, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccsu.vv v8, v12, v14

# CHECK-OBJ: nds.vqmaccsu.vx v8, a0, v14, v0.t
# CHECK-ASM: nds.vqmaccsu.vx v8, a0, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccsu.vx v8, a0, v14, v0.t

# CHECK-OBJ: nds.vqmaccsu.vx v8, a0, v14
# CHECK-ASM: nds.vqmaccsu.vx v8, a0, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccsu.vx v8, a0, v14

# CHECK-OBJ: nds.vqmaccsu.vx v8, a0, v14, v0.t
# CHECK-ASM: nds.vqmaccsu.vx v8, a0, v14, v0.t
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccus.vx v8, a0, v14, v0.t

# CHECK-OBJ: nds.vqmaccsu.vx v8, a0, v14
# CHECK-ASM: nds.vqmaccsu.vx v8, a0, v14
# CHECK-ASM: encoding: [0x5b,0x70,0x05,0x21]
# CHECK-ERROR: instruction requires the following: 'XAndesVQMac' (Andes Vector Quad-Widening Integer Multiply-Add Extension){{$}}
nds.vqmaccus.vx v8, a0, v14
