/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * f_solve_fdvy_theta_p_x_initialize.c
 *
 * Code generation for function 'f_solve_fdvy_theta_p_x_initialize'
 *
 */

/* Include files */
#include "f_solve_fdvy_theta_p_x_initialize.h"
#include "_coder_f_solve_fdvy_theta_p_x_mex.h"
#include "f_solve_fdvy_theta_p_x.h"
#include "f_solve_fdvy_theta_p_x_data.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static const volatile char_T *emlrtBreakCheckR2012bFlagVar = NULL;

/* Function Definitions */
void f_solve_fdvy_theta_p_x_initialize(void)
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

/* End of code generation (f_solve_fdvy_theta_p_x_initialize.c) */
