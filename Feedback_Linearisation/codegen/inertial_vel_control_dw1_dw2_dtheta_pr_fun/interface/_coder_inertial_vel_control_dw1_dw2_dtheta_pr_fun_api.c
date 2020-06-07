/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_inertial_vel_control_dw1_dw2_dtheta_pr_fun_api.c
 *
 * Code generation for function '_coder_inertial_vel_control_dw1_dw2_dtheta_pr_fun_api'
 *
 */

/* Include files */
#include "_coder_inertial_vel_control_dw1_dw2_dtheta_pr_fun_api.h"
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun.h"
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun_data.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static real_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[8];
static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *in2,
  const char_T *identifier))[3];
static real_T (*d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[3];
static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *Kv, const
  char_T *identifier);
static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *in1, const
  char_T *identifier))[8];
static const mxArray *emlrt_marshallOut(const real_T u);
static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static real_T (*g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[8];
static real_T (*h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[3];
static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);

/* Function Definitions */
static real_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[8]
{
  real_T (*y)[8];
  y = g_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
  static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *in2,
  const char_T *identifier))[3]
{
  real_T (*y)[3];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(sp, emlrtAlias(in2), &thisId);
  emlrtDestroyArray(&in2);
  return y;
}

static real_T (*d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[3]
{
  real_T (*y)[3];
  y = h_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
  static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *Kv,
  const char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = f_emlrt_marshallIn(sp, emlrtAlias(Kv), &thisId);
  emlrtDestroyArray(&Kv);
  return y;
}

static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *in1, const
  char_T *identifier))[8]
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

static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = i_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T (*g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[8]
{
  real_T (*ret)[8];
  static const int32_T dims[1] = { 8 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 1U, dims);
  ret = (real_T (*)[8])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}
  static real_T (*h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[3]
{
  real_T (*ret)[3];
  static const int32_T dims[1] = { 3 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 1U, dims);
  ret = (real_T (*)[3])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  real_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, &dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void inertial_vel_control_dw1_dw2_dtheta_pr_fun_api(const mxArray * const prhs
  [17], int32_T nlhs, const mxArray *plhs[3])
{
  real_T (*in1)[8];
  real_T (*in2)[3];
  real_T Kv;
  real_T Kdphi;
  real_T Kr;
  real_T Kw1;
  real_T Kw2;
  real_T theta_p_max;
  real_T w1_max;
  real_T w2_max;
  real_T theta_pr;
  real_T dxr;
  real_T dyr;
  real_T dphir;
  real_T fss_minus1_dvy_mvxdphi;
  real_T K_slow_dtheta_p;
  real_T K_slow_theta_p;
  real_T dtheta_pr;
  real_T dw1;
  real_T dw2;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  in1 = emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "in1");
  in2 = c_emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "in2");
  Kv = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[2]), "Kv");
  Kdphi = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "Kdphi");
  Kr = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "Kr");
  Kw1 = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[5]), "Kw1");
  Kw2 = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[6]), "Kw2");
  theta_p_max = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[7]), "theta_p_max");
  w1_max = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[8]), "w1_max");
  w2_max = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[9]), "w2_max");
  theta_pr = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[10]), "theta_pr");
  dxr = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[11]), "dxr");
  dyr = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[12]), "dyr");
  dphir = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[13]), "dphir");
  fss_minus1_dvy_mvxdphi = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[14]),
    "fss_minus1_dvy_mvxdphi");
  K_slow_dtheta_p = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[15]),
    "K_slow_dtheta_p");
  K_slow_theta_p = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[16]),
    "K_slow_theta_p");

  /* Invoke the target function */
  inertial_vel_control_dw1_dw2_dtheta_pr_fun(&st, *in1, *in2, Kv, Kdphi, Kr, Kw1,
    Kw2, theta_p_max, w1_max, w2_max, theta_pr, dxr, dyr, dphir,
    fss_minus1_dvy_mvxdphi, K_slow_dtheta_p, K_slow_theta_p, &dtheta_pr, &dw1,
    &dw2);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(dtheta_pr);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(dw1);
  }

  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOut(dw2);
  }
}

/* End of code generation (_coder_inertial_vel_control_dw1_dw2_dtheta_pr_fun_api.c) */
