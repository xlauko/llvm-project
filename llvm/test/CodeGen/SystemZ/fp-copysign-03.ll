; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s --check-prefixes=CHECK,Z10
; RUN: llc < %s -mtriple=s390x-linux-gnu -mcpu=z16 \
; RUN:   | FileCheck %s --check-prefixes=CHECK,Z16
;
; Test copysign intrinsics with half.

declare half @llvm.copysign.f16(half, half)
declare float @llvm.copysign.f32(float, float)
declare double @llvm.copysign.f64(double, double)
declare fp128 @llvm.copysign.f128(fp128, fp128)

; Test copysign with an f16 result and f16 sign argument.
define half @f0(half %a, half %b) {
; CHECK-LABEL: f0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cpsdr %f0, %f2, %f0
; CHECK-NEXT:    br %r14
  %res = call half @llvm.copysign.f16(half %a, half %b)
  ret half %res
}

; Test copysign with an f16 result and f32 sign argument.
define half @f1(half %a, float %b) {
; CHECK-LABEL: f1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cpsdr %f0, %f2, %f0
; CHECK-NEXT:    br %r14
  %bh = fptrunc float %b to half
  %res = call half @llvm.copysign.f16(half %a, half %bh)
  ret half %res
}

; Test copysign with an f16 result and f64 sign argument.
define half @f2(half %a, double %b) {
; CHECK-LABEL: f2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cpsdr %f0, %f2, %f0
; CHECK-NEXT:    br %r14
  %bh = fptrunc double %b to half
  %res = call half @llvm.copysign.f16(half %a, half %bh)
  ret half %res
}

; Test copysign with an f16 result and f128 sign argument.
; TODO: Let the DAGCombiner remove the fp_round.
define half @f3(half %a, fp128 %b) {
; Z10-LABEL: f3:
; Z10:       # %bb.0:
; Z10-NEXT:    stmg %r14, %r15, 112(%r15)
; Z10-NEXT:    .cfi_offset %r14, -48
; Z10-NEXT:    .cfi_offset %r15, -40
; Z10-NEXT:    aghi %r15, -184
; Z10-NEXT:    .cfi_def_cfa_offset 344
; Z10-NEXT:    std %f8, 176(%r15) # 8-byte Spill
; Z10-NEXT:    .cfi_offset %f8, -168
; Z10-NEXT:    ld %f1, 0(%r2)
; Z10-NEXT:    ld %f3, 8(%r2)
; Z10-NEXT:    ler %f8, %f0
; Z10-NEXT:    la %r2, 160(%r15)
; Z10-NEXT:    std %f1, 160(%r15)
; Z10-NEXT:    std %f3, 168(%r15)
; Z10-NEXT:    brasl %r14, __trunctfhf2@PLT
; Z10-NEXT:    cpsdr %f0, %f0, %f8
; Z10-NEXT:    ld %f8, 176(%r15) # 8-byte Reload
; Z10-NEXT:    lmg %r14, %r15, 296(%r15)
; Z10-NEXT:    br %r14
;
; Z16-LABEL: f3:
; Z16:       # %bb.0:
; Z16-NEXT:    stmg %r14, %r15, 112(%r15)
; Z16-NEXT:    .cfi_offset %r14, -48
; Z16-NEXT:    .cfi_offset %r15, -40
; Z16-NEXT:    aghi %r15, -184
; Z16-NEXT:    .cfi_def_cfa_offset 344
; Z16-NEXT:    std %f8, 176(%r15) # 8-byte Spill
; Z16-NEXT:    .cfi_offset %f8, -168
; Z16-NEXT:    ldr %f8, %f0
; Z16-NEXT:    vl %v0, 0(%r2), 3
; Z16-NEXT:    la %r2, 160(%r15)
; Z16-NEXT:    vst %v0, 160(%r15), 3
; Z16-NEXT:    brasl %r14, __trunctfhf2@PLT
; Z16-NEXT:    cpsdr %f0, %f0, %f8
; Z16-NEXT:    ld %f8, 176(%r15) # 8-byte Reload
; Z16-NEXT:    lmg %r14, %r15, 296(%r15)
; Z16-NEXT:    br %r14
  %bh = fptrunc fp128 %b to half
  %res = call half @llvm.copysign.f16(half %a, half %bh)
  ret half %res
}

; Test copysign with an f32 result and half sign argument.
define float @f4(float %a, half %b) {
; CHECK-LABEL: f4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cpsdr %f0, %f2, %f0
; CHECK-NEXT:    br %r14
  %bf = fpext half %b to float
  %res = call float @llvm.copysign.f32(float %a, float %bf)
  ret float %res
}

; Test copysign with an f64 result and half sign argument.
define double @f5(double %a, half %b) {
; CHECK-LABEL: f5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cpsdr %f0, %f2, %f0
; CHECK-NEXT:    br %r14
  %bd = fpext half %b to double
  %res = call double @llvm.copysign.f64(double %a, double %bd)
  ret double %res
}

; Test copysign with an f128 result and half sign argument.
define fp128 @f6(fp128 %a, half %b) {
; Z10-LABEL: f6:
; Z10:       # %bb.0:
; Z10-NEXT:    ld %f1, 0(%r3)
; Z10-NEXT:    ld %f3, 8(%r3)
; Z10-NEXT:    cpsdr %f1, %f0, %f1
; Z10-NEXT:    std %f1, 0(%r2)
; Z10-NEXT:    std %f3, 8(%r2)
; Z10-NEXT:    br %r14
;
; Z16-LABEL: f6:
; Z16:       # %bb.0:
; Z16-NEXT:    aghi %r15, -168
; Z16-NEXT:    .cfi_def_cfa_offset 328
; Z16-NEXT:    vl %v1, 0(%r3), 3
; Z16-NEXT:    vsteh %v0, 164(%r15), 0
; Z16-NEXT:    tm 164(%r15), 128
; Z16-NEXT:    je .LBB6_2
; Z16-NEXT:  # %bb.1:
; Z16-NEXT:    wflnxb %v0, %v1
; Z16-NEXT:    j .LBB6_3
; Z16-NEXT:  .LBB6_2:
; Z16-NEXT:    wflpxb %v0, %v1
; Z16-NEXT:  .LBB6_3:
; Z16-NEXT:    vst %v0, 0(%r2), 3
; Z16-NEXT:    aghi %r15, 168
; Z16-NEXT:    br %r14
  %bd = fpext half %b to fp128
  %res = call fp128 @llvm.copysign.f128(fp128 %a, fp128 %bd)
  ret fp128 %res
}
