/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inertial_vel_control_dw1_dw2_dtheta_pr_fun.h
 *
 * Code generation for function 'inertial_vel_control_dw1_dw2_dtheta_pr_fun'
 *
 */

#pragma once

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "inertial_vel_control_dw1_dw2_dtheta_pr_fun_types.h"

/* Function Declarations */
void inertial_vel_control_dw1_dw2_dtheta_pr_fun(const emlrtStack *sp, const
  real_T in1[8], const real_T in2[3], real_T Kv, real_T Kdphi, real_T Kr, real_T
  Kw1, real_T Kw2, real_T theta_p_max, real_T w1_max, real_T w2_max, real_T
  theta_pr, real_T dxr, real_T dyr, real_T dphir, real_T fss_minus1_dvy_mvxdphi,
  real_T K_slow_dtheta_p, real_T K_slow_theta_p, real_T *dtheta_pr, real_T *dw1,
  real_T *dw2);

/* End of code generation (inertial_vel_control_dw1_dw2_dtheta_pr_fun.h) */
