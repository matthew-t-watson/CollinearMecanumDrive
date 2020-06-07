/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_CMD_state_estimation_single_step_mex.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 02-Aug-2019 13:28:47
 */

/* Include Files */
#include "_coder_CMD_state_estimation_single_step_api.h"
#include "_coder_CMD_state_estimation_single_step_mex.h"

/* Function Declarations */
static void c_CMD_state_estimation_single_s(int32_T nlhs, mxArray *plhs[3],
  int32_T nrhs, const mxArray *prhs[6]);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 *                mxArray *plhs[3]
 *                int32_T nrhs
 *                const mxArray *prhs[6]
 * Return Type  : void
 */
static void c_CMD_state_estimation_single_s(int32_T nlhs, mxArray *plhs[3],
  int32_T nrhs, const mxArray *prhs[6])
{
  const mxArray *outputs[3];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 6) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 6, 4,
                        32, "CMD_state_estimation_single_step");
  }

  if (nlhs > 3) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 32,
                        "CMD_state_estimation_single_step");
  }

  /* Call the function. */
  CMD_state_estimation_single_step_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  CMD_state_estimation_single_step_terminate();
}

/*
 * Arguments    : int32_T nlhs
 *                mxArray * const plhs[]
 *                int32_T nrhs
 *                const mxArray * const prhs[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(CMD_state_estimation_single_step_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  CMD_state_estimation_single_step_initialize();

  /* Dispatch the entry-point. */
  c_CMD_state_estimation_single_s(nlhs, plhs, nrhs, prhs);
}

/*
 * Arguments    : void
 * Return Type  : emlrtCTX
 */
emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/*
 * File trailer for _coder_CMD_state_estimation_single_step_mex.c
 *
 * [EOF]
 */
