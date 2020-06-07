/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate.c
 *
 * Code generation for function 'inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate'
 *
 */

/* Include files */
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate.h"
#include "_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_mex.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void inertial_pos_control_ddxr_ddyr_ddphir_fun_atexit(void)
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

void inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate.c) */
