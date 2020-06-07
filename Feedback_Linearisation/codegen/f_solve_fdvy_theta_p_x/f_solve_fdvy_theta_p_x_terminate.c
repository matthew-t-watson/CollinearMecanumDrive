/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * f_solve_fdvy_theta_p_x_terminate.c
 *
 * Code generation for function 'f_solve_fdvy_theta_p_x_terminate'
 *
 */

/* Include files */
#include "f_solve_fdvy_theta_p_x_terminate.h"
#include "_coder_f_solve_fdvy_theta_p_x_mex.h"
#include "f_solve_fdvy_theta_p_x.h"
#include "f_solve_fdvy_theta_p_x_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void f_solve_fdvy_theta_p_x_atexit(void)
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

void f_solve_fdvy_theta_p_x_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (f_solve_fdvy_theta_p_x_terminate.c) */
