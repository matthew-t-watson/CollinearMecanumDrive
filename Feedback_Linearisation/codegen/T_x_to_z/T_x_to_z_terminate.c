/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * T_x_to_z_terminate.c
 *
 * Code generation for function 'T_x_to_z_terminate'
 *
 */

/* Include files */
#include "T_x_to_z_terminate.h"
#include "T_x_to_z.h"
#include "T_x_to_z_data.h"
#include "_coder_T_x_to_z_mex.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void T_x_to_z_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void T_x_to_z_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (T_x_to_z_terminate.c) */
