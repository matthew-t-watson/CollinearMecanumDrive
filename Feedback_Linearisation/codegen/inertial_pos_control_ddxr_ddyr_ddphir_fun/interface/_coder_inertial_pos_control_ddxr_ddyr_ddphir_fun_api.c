/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_api.c
 *
 * Code generation for function '_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_api'
 *
 */

/* Include files */
#include "_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_api.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun.h"
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_data.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static real_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[8];
static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *K_vr,
  const char_T *identifier);
static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static real_T (*e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[8];
static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *in1, const
  char_T *identifier))[8];
static const mxArray *emlrt_marshallOut(const real_T u);
static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);

/* Function Definitions */
static real_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[8]
{
  real_T (*y)[8];
  y = e_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
  static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *K_vr,
  const char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(sp, emlrtAlias(K_vr), &thisId);
  emlrtDestroyArray(&K_vr);
  return y;
}

static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = f_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T (*e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[8]
{
  real_T (*ret)[8];
  static const int32_T dims[1] = { 8 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 1U, dims);
  ret = (real_T (*)[8])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}
  static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *in1,
  const char_T *identifier))[8]
{
  real_T (*y)[8];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(in1), &thisId);
  emlrtDestroyArray(&in1);
  return y;
}

static const mxArray *emlrt_marshallOut(const real_T u)
{
  const mxArray *y;
  const mxArray *m;
  y = NULL;
  m = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m);
  return y;
}

static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  real_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, &dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void inertial_pos_control_ddxr_ddyr_ddphir_fun_api(const mxArray * const prhs[14],
  int32_T nlhs, const mxArray *plhs[3])
{
  real_T (*in1)[8];
  real_T K_vr;
  real_T K_p;
  real_T K_dphir;
  real_T K_phi;
  real_T v_max;
  real_T dphi_max;
  real_T dxr;
  real_T dyr;
  real_T dphir;
  real_T xr;
  real_T yr;
  real_T phir;
  real_T K_slow;
  real_T ddxr;
  real_T ddyr;
  real_T ddphir;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  in1 = emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "in1");
  K_vr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "K_vr");
  K_p = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[2]), "K_p");
  K_dphir = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "K_dphir");
  K_phi = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "K_phi");
  v_max = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[5]), "v_max");
  dphi_max = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[6]), "dphi_max");
  dxr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[7]), "dxr");
  dyr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[8]), "dyr");
  dphir = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[9]), "dphir");
  xr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[10]), "xr");
  yr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[11]), "yr");
  phir = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[12]), "phir");
  K_slow = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[13]), "K_slow");

  /* Invoke the target function */
  inertial_pos_control_ddxr_ddyr_ddphir_fun(&st, *in1, K_vr, K_p, K_dphir, K_phi,
    v_max, dphi_max, dxr, dyr, dphir, xr, yr, phir, K_slow, &ddxr, &ddyr,
    &ddphir);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(ddxr);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(ddyr);
  }

  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOut(ddphir);
  }
}

/* End of code generation (_coder_inertial_pos_control_ddxr_ddyr_ddphir_fun_api.c) */
