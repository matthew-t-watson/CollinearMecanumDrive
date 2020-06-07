/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * dvy_ss_fun_terminate.c
 *
 * Code generation for function 'dvy_ss_fun_terminate'
 *
 */

/* Include files */
#include "dvy_ss_fun_terminate.h"
#include "_coder_dvy_ss_fun_mex.h"
#include "dvy_ss_fun.h"
#include "dvy_ss_fun_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void dvy_ss_fun_atexit(void)
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

void dvy_ss_fun_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (dvy_ss_fun_terminate.c) */
