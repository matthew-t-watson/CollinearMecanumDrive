/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * body_vel_control_dw1_dw2_dtheta_pr_fun.c
 *
 * Code generation for function 'body_vel_control_dw1_dw2_dtheta_pr_fun'
 *
 */

/* Include files */
#include "body_vel_control_dw1_dw2_dtheta_pr_fun.h"
#include "mwmathutil.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void body_vel_control_dw1_dw2_dtheta_pr_fun(const emlrtStack *sp, const real_T
  in1[8], const real_T in2[3], real_T Kv, real_T Kdphi, real_T Kr, real_T Kw1,
  real_T Kw2, real_T theta_p_max, real_T w1_max, real_T w2_max, real_T theta_pr,
  real_T fss_minus1_dvy0, real_T vxr, real_T vyr, real_T dphir, real_T
  K_slow_dtheta_p, real_T K_slow_theta_p, real_T *dtheta_pr, real_T *dw1, real_T
  *dw2)
{
  real_T dtheta_pr_tmp_tmp;
  real_T b_dtheta_pr_tmp_tmp;
  real_T dtheta_pr_tmp;
  real_T a_tmp;
  real_T b_a_tmp;
  real_T b_dtheta_pr_tmp;
  real_T c_dtheta_pr_tmp;
  real_T d_dtheta_pr_tmp;
  real_T e_dtheta_pr_tmp;
  real_T f_dtheta_pr_tmp;
  real_T g_dtheta_pr_tmp;
  real_T h_dtheta_pr_tmp;
  real_T i_dtheta_pr_tmp;
  real_T j_dtheta_pr_tmp;
  real_T k_dtheta_pr_tmp;
  real_T l_dtheta_pr_tmp;
  real_T m_dtheta_pr_tmp;
  real_T n_dtheta_pr_tmp;
  (void)sp;

  /* BODY_VEL_CONTROL_DW1_DW2_DTHETA_PR_FUN */
  /*     [DTHETA_PR,DW1,DW2] = BODY_VEL_CONTROL_DW1_DW2_DTHETA_PR_FUN(IN1,IN2,KV,KDPHI,KR,KW1,KW2,THETA_P_MAX,W1_MAX,W2_MAX,THETA_PR,FSS_MINUS1_DVY0,VXR,VYR,DPHIR,K_SLOW_DTHETA_P,K_SLOW_THETA_P) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.4. */
  /*     27-Jan-2020 10:02:10 */
  dtheta_pr_tmp_tmp = muDoubleScalarCos(theta_pr);
  b_dtheta_pr_tmp_tmp = muDoubleScalarSin(theta_pr);
  dtheta_pr_tmp = muDoubleScalarSin(theta_pr * 2.0);
  a_tmp = theta_p_max * theta_p_max;
  b_a_tmp = theta_pr * theta_pr - a_tmp;
  b_dtheta_pr_tmp = in1[4] * in2[1];
  c_dtheta_pr_tmp = in1[6] * in2[0];
  d_dtheta_pr_tmp = in1[6] * in2[1];
  e_dtheta_pr_tmp = in1[6] * in1[6];
  f_dtheta_pr_tmp = e_dtheta_pr_tmp * muDoubleScalarCos(theta_pr * 2.0);
  a_tmp = fss_minus1_dvy0 * theta_pr - a_tmp;
  g_dtheta_pr_tmp = in1[4] * in1[6];
  h_dtheta_pr_tmp = e_dtheta_pr_tmp * dtheta_pr_tmp;
  i_dtheta_pr_tmp = (in1[5] * 0.99563590141939118 + e_dtheta_pr_tmp *
                     b_dtheta_pr_tmp_tmp * 0.2254) + g_dtheta_pr_tmp * 3.22;
  j_dtheta_pr_tmp = fss_minus1_dvy0 - theta_pr;
  k_dtheta_pr_tmp = dtheta_pr_tmp_tmp * dtheta_pr_tmp_tmp;
  l_dtheta_pr_tmp = b_dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp;
  m_dtheta_pr_tmp = dtheta_pr_tmp_tmp * l_dtheta_pr_tmp;
  n_dtheta_pr_tmp = ((((muDoubleScalarSin(theta_pr) * 1.6624316354668391E-14 -
                        dtheta_pr_tmp_tmp * dtheta_pr_tmp_tmp *
                        2.554188920360585E-13) + b_dtheta_pr_tmp_tmp *
                       b_dtheta_pr_tmp_tmp * 8.0736743342654317E-13) -
                      dtheta_pr_tmp_tmp * dtheta_pr_tmp_tmp *
                      b_dtheta_pr_tmp_tmp * 4.8224626801869287E-15) -
                     dtheta_pr_tmp_tmp * dtheta_pr_tmp_tmp *
                     (b_dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp) *
                     2.342050785026386E-13) + 8.8049711231808578E-13;
  *dtheta_pr = muDoubleScalarExp(-K_slow_dtheta_p * muDoubleScalarAbs(in1[7]) -
    K_slow_theta_p * muDoubleScalarAbs(in1[3] - theta_pr)) * ((Kr *
    j_dtheta_pr_tmp * a_tmp - b_a_tmp * (((((((((b_dtheta_pr_tmp *
    2.07010441457416E+31 + c_dtheta_pr_tmp * 2.07010441457416E+31) +
    b_dtheta_pr_tmp * dtheta_pr_tmp_tmp * 9.415106672479785E+31) +
    c_dtheta_pr_tmp * dtheta_pr_tmp_tmp * 9.415106672479785E+31) +
    d_dtheta_pr_tmp * b_dtheta_pr_tmp_tmp * 2.8981461804038229E+30) +
    b_dtheta_pr_tmp * k_dtheta_pr_tmp * 1.0692406484316949E+32) +
    c_dtheta_pr_tmp * k_dtheta_pr_tmp * 1.0692406484316949E+32) +
    d_dtheta_pr_tmp * dtheta_pr_tmp * 9.8420188514876134E+30) + d_dtheta_pr_tmp *
    dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp * 6.3619818581685849E+30) + in1[6] *
    in2[1] * muDoubleScalarSin(theta_pr * 2.0) * dtheta_pr_tmp_tmp *
    2.160510253219621E+31) / (a_tmp * ((((((((((dtheta_pr_tmp_tmp *
    4.7782880722288249E+32 + e_dtheta_pr_tmp * dtheta_pr_tmp_tmp *
    1.449073090201912E+30) + k_dtheta_pr_tmp * 1.048925076111493E+33) +
    l_dtheta_pr_tmp * 1.048925076111493E+33) + f_dtheta_pr_tmp *
    9.8420188514876134E+30) + e_dtheta_pr_tmp * k_dtheta_pr_tmp *
    3.1809909290842919E+30) + e_dtheta_pr_tmp * l_dtheta_pr_tmp *
    3.1809909290842919E+30) + in1[5] * b_dtheta_pr_tmp_tmp *
    1.256495091399306E+31) - g_dtheta_pr_tmp * b_dtheta_pr_tmp_tmp *
    3.26561160810378E+30) + f_dtheta_pr_tmp * dtheta_pr_tmp_tmp *
    2.160510253219621E+31) + h_dtheta_pr_tmp * b_dtheta_pr_tmp_tmp *
    1.08025512660981E+31))) + Kv * (b_a_tmp * b_a_tmp) * (in1[5] - vyr) *
    ((((b_dtheta_pr_tmp_tmp * 1.0724748384E-10 + l_dtheta_pr_tmp *
        5.20852249933514E-9) + 5.6802997374374863E-9) * i_dtheta_pr_tmp *
      4.4911946750946972E-5 / (((((b_dtheta_pr_tmp_tmp * 1.6624316354668391E-14
    - k_dtheta_pr_tmp * 2.554188920360585E-13) + l_dtheta_pr_tmp *
    8.0736743342654317E-13) - k_dtheta_pr_tmp * b_dtheta_pr_tmp_tmp *
    4.8224626801869287E-15) - k_dtheta_pr_tmp * l_dtheta_pr_tmp *
    2.342050785026386E-13) + 8.8049711231808578E-13) - ((dtheta_pr_tmp_tmp *
    1.133180532546843E-12 + dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp *
    2.1395131677847961E-14) + m_dtheta_pr_tmp * 1.039064234705584E-12) * (((in1
    [5] * -0.003132773109243698 + b_dtheta_pr_tmp_tmp * 2.211174) +
    h_dtheta_pr_tmp * 0.02277218939393939) + g_dtheta_pr_tmp * dtheta_pr_tmp_tmp
    * 0.2254) / n_dtheta_pr_tmp) + (((dtheta_pr_tmp_tmp * 1.280339560818409E-9 +
    muDoubleScalarCos(theta_pr) * muDoubleScalarSin(theta_pr) *
    2.4173582857536E-11) + m_dtheta_pr_tmp * 1.174000971350141E-9) *
    i_dtheta_pr_tmp * 0.0008850625 / n_dtheta_pr_tmp - ((b_dtheta_pr_tmp_tmp *
    3.2760902294540281E-13 + l_dtheta_pr_tmp * 1.5910480189372179E-11) +
    1.735161870832496E-11) * (((in1[5] * -0.003132773109243698 +
    muDoubleScalarSin(theta_pr) * 2.211174) + in1[6] * in1[6] * dtheta_pr_tmp *
    0.02277218939393939) + in1[4] * in1[6] * muDoubleScalarCos(theta_pr) *
    0.2254) / n_dtheta_pr_tmp) * (((muDoubleScalarSin(theta_pr) *
    1.0724748384E-10 + b_dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp *
    5.20852249933514E-9) + 5.6802997374374863E-9) * 4.4911946750946972E-5 /
    n_dtheta_pr_tmp + ((muDoubleScalarCos(theta_pr) * 1.133180532546843E-12 +
                        muDoubleScalarCos(theta_pr) * muDoubleScalarSin(theta_pr)
                        * 2.1395131677847961E-14) + dtheta_pr_tmp_tmp *
                       (b_dtheta_pr_tmp_tmp * b_dtheta_pr_tmp_tmp) *
                       1.039064234705584E-12) * 0.02975 / n_dtheta_pr_tmp) *
     (k_dtheta_pr_tmp * 4.49657419225E-5 - 0.0001550089173138068) /
     (dtheta_pr_tmp_tmp * 0.0001994930875 + 9.08773621875E-5)) /
    (j_dtheta_pr_tmp * a_tmp));
  a_tmp = in2[0] * in2[0] - w1_max * w1_max;
  *dw1 = -Kw1 * in2[0] - Kv * (a_tmp * a_tmp) * (in1[4] - vxr);
  a_tmp = in2[1] * in2[1] - w2_max * w2_max;
  *dw2 = -Kw2 * in2[1] + Kdphi * (a_tmp * a_tmp) * (dphir - in1[6]);
}

/* End of code generation (body_vel_control_dw1_dw2_dtheta_pr_fun.c) */