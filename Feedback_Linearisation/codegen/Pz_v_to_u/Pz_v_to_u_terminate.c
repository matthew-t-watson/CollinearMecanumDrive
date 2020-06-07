/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Pz_v_to_u_terminate.c
 *
 * Code generation for function 'Pz_v_to_u_terminate'
 *
 */

/* Include files */
#include "Pz_v_to_u_terminate.h"
#include "Pz_v_to_u.h"
#include "Pz_v_to_u_data.h"
#include "_coder_Pz_v_to_u_mex.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void Pz_v_to_u_atexit(void)
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

void Pz_v_to_u_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (Pz_v_to_u_terminate.c) */
