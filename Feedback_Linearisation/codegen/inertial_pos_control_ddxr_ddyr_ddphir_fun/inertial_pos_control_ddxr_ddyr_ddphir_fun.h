/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inertial_pos_control_ddxr_ddyr_ddphir_fun.h
 *
 * Code generation for function 'inertial_pos_control_ddxr_ddyr_ddphir_fun'
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
#include "inertial_pos_control_ddxr_ddyr_ddphir_fun_types.h"

/* Function Declarations */
void inertial_pos_control_ddxr_ddyr_ddphir_fun(const emlrtStack *sp, const
  real_T in1[8], real_T K_vr, real_T K_p, real_T K_dphir, real_T K_phi, real_T
  v_max, real_T dphi_max, real_T dxr, real_T dyr, real_T dphir, real_T xr,
  real_T yr, real_T phir, real_T K_slow, real_T *ddxr, real_T *ddyr, real_T
  *ddphir);

/* End of code generation (inertial_pos_control_ddxr_ddyr_ddphir_fun.h) */
