/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inertial_vel_control_dw1_dw2_dtheta_pr_fun_initialize.c
 *
 * Code generation for function 'inertial_vel_control_dw1_dw2_dtheta_pr_fun_initialize'
 *
 */

/* Include files */
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun_initialize.h"
#include "_coder_inertial_vel_control_dw1_dw2_dtheta_pr_fun_mex.h"
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun.h"
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun_data.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static const volatile char_T *emlrtBreakCheckR2012bFlagVar = NULL;

/* Function Definitions */
void inertial_vel_control_dw1_dw2_dtheta_pr_fun_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mex_InitInfAndNan();
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (inertial_vel_control_dw1_dw2_dtheta_pr_fun_initialize.c) */
