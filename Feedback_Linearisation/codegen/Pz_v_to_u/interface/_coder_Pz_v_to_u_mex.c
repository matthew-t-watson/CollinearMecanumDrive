/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_Pz_v_to_u_mex.c
 *
 * Code generation for function '_coder_Pz_v_to_u_mex'
 *
 */

/* Include files */
#include "_coder_Pz_v_to_u_mex.h"
#include "Pz_v_to_u.h"
#include "Pz_v_to_u_data.h"
#include "Pz_v_to_u_initialize.h"
#include "Pz_v_to_u_terminate.h"
#include "_coder_Pz_v_to_u_api.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void Pz_v_to_u_mexFunction(int32_T nlhs, mxArray *plhs[1],
  int32_T nrhs, const mxArray *prhs[2]);

/* Function Definitions */
void Pz_v_to_u_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs, const
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
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4, 9,
                        "Pz_v_to_u");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 9,
                        "Pz_v_to_u");
  }

  /* Call the function. */
  Pz_v_to_u_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(Pz_v_to_u_atexit);

  /* Module initialization. */
  Pz_v_to_u_initialize();

  /* Dispatch the entry-point. */
  Pz_v_to_u_mexFunction(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  Pz_v_to_u_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_Pz_v_to_u_mex.c) */
