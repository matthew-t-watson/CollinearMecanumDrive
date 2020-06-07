/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_dvy_ss_fun_mex.c
 *
 * Code generation for function '_coder_dvy_ss_fun_mex'
 *
 */

/* Include files */
#include "_coder_dvy_ss_fun_mex.h"
#include "_coder_dvy_ss_fun_api.h"
#include "dvy_ss_fun.h"
#include "dvy_ss_fun_data.h"
#include "dvy_ss_fun_initialize.h"
#include "dvy_ss_fun_terminate.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void dvy_ss_fun_mexFunction(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[2]);

/* Function Definitions */
void dvy_ss_fun_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs, const
  mxArray *prhs[2])
{
  const mxArray *outputs[1];
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4,
                        10, "dvy_ss_fun");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 10,
                        "dvy_ss_fun");
  }

  /* Call the function. */
  dvy_ss_fun_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(dvy_ss_fun_atexit);

  /* Module initialization. */
  dvy_ss_fun_initialize();

  /* Dispatch the entry-point. */
  dvy_ss_fun_mexFunction(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  dvy_ss_fun_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_dvy_ss_fun_mex.c) */
