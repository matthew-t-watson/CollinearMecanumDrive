/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_calculate_u_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 30-Jul-2019 16:20:27
 */

#ifndef _CODER_CALCULATE_U_API_H
#define _CODER_CALCULATE_U_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_calculate_u_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void calculate_u(real_T x[8], real_T r[36], real_T c[48], real_T u[4]);
extern void calculate_u_api(const mxArray * const prhs[5], int32_T nlhs, const
  mxArray *plhs[1]);
extern void calculate_u_atexit(void);
extern void calculate_u_initialize(void);
extern void calculate_u_terminate(void);
extern void calculate_u_xil_terminate(void);

#endif

/*
 * File trailer for _coder_calculate_u_api.h
 *
 * [EOF]
 */
