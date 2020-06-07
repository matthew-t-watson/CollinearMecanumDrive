/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_f_solve_fdvy_theta_p_x_mex.c
 *
 * Code generation for function '_coder_f_solve_fdvy_theta_p_x_mex'
 *
 */

/* Include files */
#include "_coder_f_solve_fdvy_theta_p_x_mex.h"
#include "_coder_f_solve_fdvy_theta_p_x_api.h"
#include "f_solve_fdvy_theta_p_x.h"
#include "f_solve_fdvy_theta_p_x_data.h"
#include "f_solve_fdvy_theta_p_x_initialize.h"
#include "f_solve_fdvy_theta_p_x_terminate.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void c_f_solve_fdvy_theta_p_x_mexFun(int32_T nlhs, mxArray
  *plhs[2], int32_T nrhs, const mxArray *prhs[3]);

/* Function Definitions */
void c_f_solve_fdvy_theta_p_x_mexFun(int32_T nlhs, mxArray *plhs[2], int32_T
  nrhs, const mxArray *prhs[3])
{
  const mxArray *outputs[2];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 3) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 3, 4,
                        22, "f_solve_fdvy_theta_p_x");
  }

  if (nlhs > 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 22,
                        "f_solve_fdvy_theta_p_x");
  }

  /* Call the function. */
  f_solve_fdvy_theta_p_x_api(prhs, nlhs, outputs);

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
  mexAtExit(f_solve_fdvy_theta_p_x_atexit);

  /* Module initialization. */
  f_solve_fdvy_theta_p_x_initialize();

  /* Dispatch the entry-point. */
  c_f_solve_fdvy_theta_p_x_mexFun(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  f_solve_fdvy_theta_p_x_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_f_solve_fdvy_theta_p_x_mex.c) */
