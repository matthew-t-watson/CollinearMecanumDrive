/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_calculate_b_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 30-Jul-2019 16:20:25
 */

#ifndef _CODER_CALCULATE_B_API_H
#define _CODER_CALCULATE_B_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_calculate_b_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void calculate_b(real_T x[8], real_T r[36], real_T b[448]);
extern void calculate_b_api(const mxArray * const prhs[5], int32_T nlhs, const
  mxArray *plhs[1]);
extern void calculate_b_atexit(void);
extern void calculate_b_initialize(void);
extern void calculate_b_terminate(void);
extern void calculate_b_xil_terminate(void);

#endif

/*
 * File trailer for _coder_calculate_b_api.h
 *
 * [EOF]
 */
