/*
 * Copyright (c) The mldsa-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [REF_AVX2]
 *   CRYSTALS-Dilithium optimized AVX2 implementation
 *   Bai, Ducas, Kiltz, Lepoint, Lyubashevsky, Schwabe, Seiler, Stehlé
 *   https://github.com/pq-crystals/dilithium/tree/master/avx2
 */

/*
 * This file is derived from the public domain
 * AVX2 Dilithium implementation @[REF_AVX2].
 */


/*************************************************
 * Name:        mld_poly_use_hint
 *
 * Description: Use hint polynomial to correct the high bits of a polynomial.
 *
 * Arguments:   - mld_poly *b: pointer to output polynomial with corrected high
 *                bits
 *              - const mld_poly *a: pointer to input polynomial
 *              - const mld_poly *hint: pointer to input hint polynomial
 **************************************************/

#include "../../../common.h"

#if defined(MLD_ARITH_BACKEND_X86_64_DEFAULT) && \
!defined(MLD_CONFIG_MULTILEVEL_NO_SHARED)

/* simpasm: header-end */

.text
.balign 16
.global MLD_ASM_NAMESPACE(mld_poly_use_hint_88_avx2)  
MLD_ASM_FN_SYMBOL(mld_poly_use_hint_88_avx2)

movl	$127, %ecx
xorl	%eax, %eax
vpxor	%xmm5, %xmm5, %xmm5

movl $11275, %r8d        /* 11275, 0 alternating (for .LC1) */ 
vmovd %r8d, %xmm8
vpbroadcastd %xmm8, %ymm8

vmovd	%ecx, %xmm4
movl	$8285184, %ecx

movl $128, %r9d        /* 128, 0 alternating (for .LC2)  */  
vmovd %r9d, %xmm7
vpbroadcastd %xmm7, %ymm7

movl $43, %r10d                       /* Load 43 constant (replaces .LC5) */ 
vmovd %r10d, %xmm6
vpbroadcastd %xmm6, %ymm6

vmovd	%ecx, %xmm3
movl	$43, %ecx

vpbroadcastd	%xmm4, %ymm4
vmovd	%ecx, %xmm2
vpbroadcastd	%xmm3, %ymm3
vpbroadcastd	%xmm2, %ymm2

mld_poly_use_hint_88_avx2_loop:
vmovdqa	(%rsi,%rax), %ymm0
vmovdqa	(%rdx,%rax), %ymm1
vpaddd	%ymm0, %ymm4, %ymm10
vpcmpgtd	%ymm3, %ymm0, %ymm11
vpsrld	$7, %ymm10, %ymm10
vpmulhuw	%ymm8, %ymm10, %ymm10
vpmulhrsw	%ymm7, %ymm10, %ymm10
vpslld	$1, %ymm10, %ymm12
vpandn	%ymm10, %ymm11, %ymm9
vpaddd	%ymm10, %ymm12, %ymm12
vpslld	$5, %ymm12, %ymm10
vpsubd	%ymm12, %ymm10, %ymm10
vpslld	$11, %ymm10, %ymm10
vpsubd	%ymm10, %ymm0, %ymm0
vpaddd	%ymm11, %ymm0, %ymm0
vpcmpgtd	%ymm5, %ymm0, %ymm0
vandnps	%ymm1, %ymm0, %ymm0
vpslld	$1, %ymm0, %ymm0
vpsubd	%ymm0, %ymm1, %ymm0
vpaddd	%ymm9, %ymm0, %ymm0
vblendvps	%ymm0, %ymm6, %ymm0, %ymm0
vpcmpgtd	%ymm2, %ymm0, %ymm1
vandnps	%ymm0, %ymm1, %ymm0
vmovaps	%ymm0, (%rdi,%rax)


addq	$32, %rax
cmpq	$1024, %rax
jne	mld_poly_use_hint_88_avx2_loop

ret

/* simpasm: footer-start */

#endif /* MLD_ARITH_BACKEND_X86_64_DEFAULT && !MLD_CONFIG_MULTILEVEL_NO_SHARED \
        */

