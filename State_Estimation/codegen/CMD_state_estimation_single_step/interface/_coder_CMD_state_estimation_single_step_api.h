/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_CMD_state_estimation_single_step_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 02-Aug-2019 13:28:47
 */

#ifndef _CODER_CMD_STATE_ESTIMATION_SINGLE_STEP_API_H
#define _CODER_CMD_STATE_ESTIMATION_SINGLE_STEP_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_CMD_state_estimation_single_step_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void CMD_state_estimation_single_step(real_T state_in[10], real_T P_old
  [25], real_T u[3], real_T z[7], real_T theta_i_prev[4], real_T dt, real_T
  state_out[10], real_T P_new[25], real_T *ignoring_accel);
extern void CMD_state_estimation_single_step_api(const mxArray * const prhs[6],
  int32_T nlhs, const mxArray *plhs[3]);
extern void CMD_state_estimation_single_step_atexit(void);
extern void CMD_state_estimation_single_step_initialize(void);
extern void CMD_state_estimation_single_step_terminate(void);
extern void CMD_state_estimation_single_step_xil_terminate(void);

#endif

/*
 * File trailer for _coder_CMD_state_estimation_single_step_api.h
 *
 * [EOF]
 */
