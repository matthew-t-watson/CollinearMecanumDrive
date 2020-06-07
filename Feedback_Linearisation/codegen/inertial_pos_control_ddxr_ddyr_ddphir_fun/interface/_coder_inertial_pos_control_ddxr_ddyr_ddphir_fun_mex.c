/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_mex.c
 *
 * Code generation for function '_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_mex'
 *
 */

/* Include files */
#include "_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_mex.h"
#include "_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_api.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_data.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_initialize.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void c_inertial_pos_control_ddxr_ddy(int32_T nlhs, mxArray
  *plhs[3], int32_T nrhs, const mxArray *prhs[14]);

/* Function Definitions */
void c_inertial_pos_control_ddxr_ddy(int32_T nlhs, mxArray *plhs[3], int32_T
  nrhs, const mxArray *prhs[14])
{
  const mxArray *outputs[3];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 14) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 14, 4,
                        41, "inertial_pos_control_ddxr_ddyr_ddphir_fun");
  }

  if (nlhs > 3) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 41,
                        "inertial_pos_control_ddxr_ddyr_ddphir_fun");
  }

  /* Call the function. */
  inertial_pos_control_ddxr_ddyr_ddphir_fun_api(prhs, nlhs, outputs);

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
  mexAtExit(inertial_pos_control_ddxr_ddyr_ddphir_fun_atexit);

  /* Module initialization. */
  inertial_pos_control_ddxr_ddyr_ddphir_fun_initialize();

  /* Dispatch the entry-point. */
  c_inertial_pos_control_ddxr_ddy(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  inertial_pos_control_ddxr_ddyr_ddphir_fun_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_mex.c) */
