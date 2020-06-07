/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: CMD_state_estimation_single_step.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 02-Aug-2019 13:28:47
 */

#ifndef CMD_STATE_ESTIMATION_SINGLE_STEP_H
#define CMD_STATE_ESTIMATION_SINGLE_STEP_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "CMD_state_estimation_single_step_types.h"

/* Function Declarations */
extern void CMD_state_estimation_single_step(const double state_in[10], const
  double P_old[25], const double u[3], const double z[7], const double
  theta_i_prev[4], double dt, double state_out[10], double P_new[25], double
  *ignoring_accel);
extern void CMD_state_estimation_single_step_initialize(void);

#endif

/*
 * File trailer for CMD_state_estimation_single_step.h
 *
 * [EOF]
 */
