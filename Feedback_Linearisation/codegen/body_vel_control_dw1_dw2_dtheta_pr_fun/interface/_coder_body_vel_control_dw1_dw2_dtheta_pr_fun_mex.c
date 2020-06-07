/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_body_vel_control_dw1_dw2_dtheta_pr_fun_mex.c
 *
 * Code generation for function '_coder_body_vel_control_dw1_dw2_dtheta_pr_fun_mex'
 *
 */

/* Include files */
#include "_coder_body_vel_control_dw1_dw2_dtheta_pr_fun_mex.h"
#include "_coder_body_vel_control_dw1_dw2_dtheta_pr_fun_api.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun_data.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun_initialize.h"
#include "body_vel_control_dw1_dw2_dtheta_pr_fun_terminate.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void c_body_vel_control_dw1_dw2_dthe(int32_T nlhs, mxArray
  *plhs[3], int32_T nrhs, const mxArray *prhs[17]);

/* Function Definitions */
void c_body_vel_control_dw1_dw2_dthe(int32_T nlhs, mxArray *plhs[3], int32_T
  nrhs, const mxArray *prhs[17])
{
  const mxArray *outputs[3];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 17) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 17, 4,
                        38, "body_vel_control_dw1_dw2_dtheta_pr_fun");
  }

  if (nlhs > 3) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 38,
                        "body_vel_control_dw1_dw2_dtheta_pr_fun");
  }

  /* Call the function. */
  body_vel_control_dw1_dw2_dtheta_pr_fun_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(body_vel_control_dw1_dw2_dtheta_pr_fun_atexit);

  /* Module initialization. */
  body_vel_control_dw1_dw2_dtheta_pr_fun_initialize();

  /* Dispatch the entry-point. */
  c_body_vel_control_dw1_dw2_dthe(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  body_vel_control_dw1_dw2_dtheta_pr_fun_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_body_vel_control_dw1_dw2_dtheta_pr_fun_mex.c) */
