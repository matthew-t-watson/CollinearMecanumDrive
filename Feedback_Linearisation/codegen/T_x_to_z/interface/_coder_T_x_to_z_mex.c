/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_T_x_to_z_mex.c
 *
 * Code generation for function '_coder_T_x_to_z_mex'
 *
 */

/* Include files */
#include "_coder_T_x_to_z_mex.h"
#include "T_x_to_z.h"
#include "T_x_to_z_data.h"
#include "T_x_to_z_initialize.h"
#include "T_x_to_z_terminate.h"
#include "_coder_T_x_to_z_api.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void T_x_to_z_mexFunction(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[1]);

/* Function Definitions */
void T_x_to_z_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs, const
  mxArray *prhs[1])
{
  const mxArray *outputs[1];
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 1, 4, 8,
                        "T_x_to_z");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 8,
                        "T_x_to_z");
  }

  /* Call the function. */
  T_x_to_z_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(T_x_to_z_atexit);

  /* Module initialization. */
  T_x_to_z_initialize();

  /* Dispatch the entry-point. */
  T_x_to_z_mexFunction(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  T_x_to_z_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_T_x_to_z_mex.c) */
