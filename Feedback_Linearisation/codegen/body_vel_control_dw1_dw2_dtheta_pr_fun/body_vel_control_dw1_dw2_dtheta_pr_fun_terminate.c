/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * body_vel_control_dw1_dw2_dtheta_pr_fun_terminate.c
 *
 * Code generation for function 'body_vel_control_dw1_dw2_dtheta_pr_fun_terminate'
 *
 */

/* Include files */
#include "body_vel_control_dw1_dw2_dtheta_pr_fun_terminate.h"
#include "_coder_body_vel_control_dw1_dw2_dtheta_pr_fun_mex.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void body_vel_control_dw1_dw2_dtheta_pr_fun_atexit(void)
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

void body_vel_control_dw1_dw2_dtheta_pr_fun_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (body_vel_control_dw1_dw2_dtheta_pr_fun_terminate.c) */
