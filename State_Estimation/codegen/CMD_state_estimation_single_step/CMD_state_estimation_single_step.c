/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: CMD_state_estimation_single_step.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 02-Aug-2019 13:28:47
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "CMD_state_estimation_single_step.h"

/* Type Definitions */
#ifndef typedef_extendedKalmanFilter
#define typedef_extendedKalmanFilter

typedef struct {
  double pState[5];
  double pStateCovariance[25];
  double pProcessNoise[25];
  double pMeasurementNoise[49];
  boolean_T pIsValidStateTransitionFcn;
  boolean_T pIsValidMeasurementFcn;
} extendedKalmanFilter;

#endif                                 /*typedef_extendedKalmanFilter*/

/* Variable Definitions */
static extendedKalmanFilter ekf;
static boolean_T ekf_not_empty;
static double accel__norm_error;

/* Function Declarations */
static void ExtendedKalmanFilter_correct(extendedKalmanFilter *obj, const double
  z[7], const double varargin_1[3], const double varargin_2[4], double
  varargin_3, double x_corr[5], double P_corr[25]);
static void b_sqrt(double *x);
static double b_xnrm2(int n, const double x[8], int ix0);
static void c_CMD_state_estimation_single_s(void);
static void c_ExtendedKalmanFilter_set_Meas(extendedKalmanFilter *obj, const
  double value[49]);
static void c_ExtendedKalmanFilter_set_Stat(extendedKalmanFilter *obj, const
  double value[25]);
static extendedKalmanFilter *c_extendedKalmanFilter_extended
  (extendedKalmanFilter *EKF, const double varargin_3[5]);
static void d_extendedKalmanFilter_extended(extendedKalmanFilter **EKF, const
  double varargin_3[5]);
static int ixamax(int n, const double x[2], int ix0);
static void mrdivide(double A[35], const double B[49]);
static double rt_hypotd(double u0, double u1);
static void xgeqp3(double A[8], double tau[2], int jpvt[2]);
static double xnrm2(const double x[8], int ix0);

/* Function Definitions */

/*
 * Arguments    : extendedKalmanFilter *obj
 *                const double z[7]
 *                const double varargin_1[3]
 *                const double varargin_2[4]
 *                double varargin_3
 *                double x_corr[5]
 *                double P_corr[25]
 * Return Type  : void
 */
static void ExtendedKalmanFilter_correct(extendedKalmanFilter *obj, const double
  z[7], const double varargin_1[3], const double varargin_2[4], double
  varargin_3, double x_corr[5], double P_corr[25])
{
  int i0;
  int i;
  double zcov[49];
  double x[5];
  double P[25];
  double t2;
  double t3;
  double t4;
  double t5;
  double t8;
  double t11;
  double b_x[35];
  double b_varargin_3[35];
  double t7;
  double gain[35];
  double dHdx[49];
  double b_dHdx[35];
  double b_varargin_2[7];
  int i1;
  double d0;
  double b_z[7];
  double b_P[25];
  double b_gain[25];
  if (!obj->pIsValidMeasurementFcn) {
    obj->pIsValidMeasurementFcn = true;
  }

  for (i0 = 0; i0 < 49; i0++) {
    zcov[i0] = obj->pMeasurementNoise[i0];
  }

  for (i = 0; i < 5; i++) {
    x[i] = obj->pState[i];
  }

  for (i0 = 0; i0 < 25; i0++) {
    P[i0] = obj->pStateCovariance[i0];
  }

  /* MEASUREMENT_JACOBIAN_FUNCTION */
  /*     H_X = MEASUREMENT_JACOBIAN_FUNCTION(IN1,IN2,IN3,DT) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.1. */
  /*     02-Aug-2019 13:28:46 */
  t2 = sin(x[0]);
  t3 = cos(x[0]);
  t4 = x[4] - varargin_1[1];
  t5 = varargin_3 * 33.613445378151262;
  t8 = varargin_1[2] * t2 * 2.1176470588235294 + t3 * t4 * 2.1176470588235294;
  t11 = varargin_1[2] * t2 * 3.5294117647058822 + t3 * t4 * 3.5294117647058822;
  b_x[0] = -varargin_3 * t11;
  b_x[1] = -varargin_3 * t8;
  b_x[2] = varargin_3 * t8;
  b_x[3] = varargin_3 * t11;
  b_x[4] = t3;
  b_x[5] = -t2;
  b_x[6] = -varargin_1[2] * t3 + t2 * t4;
  b_x[7] = varargin_3 * -33.613445378151262;
  b_x[8] = t5;
  b_x[9] = -t5;
  b_x[10] = t5;
  b_x[11] = 0.0;
  b_x[12] = 0.0;
  b_x[13] = 0.0;
  b_x[14] = varargin_3 * -33.613445378151262;
  b_x[15] = -t5;
  b_x[16] = -t5;
  b_x[17] = -t5;
  b_x[18] = 0.0;
  b_x[19] = 0.0;
  b_x[20] = 0.0;
  b_x[21] = varargin_3;
  b_x[22] = varargin_3;
  b_x[23] = varargin_3;
  b_x[24] = varargin_3;
  b_x[25] = 0.0;
  b_x[26] = 0.0;
  b_x[27] = 0.0;
  b_x[28] = varargin_3 * t2 * -3.5294117647058822;
  b_x[29] = varargin_3 * t2 * -2.1176470588235294;
  b_x[30] = varargin_3 * t2 * 2.1176470588235294;
  b_x[31] = varargin_3 * t2 * 3.5294117647058822;
  b_x[32] = 0.0;
  b_x[33] = 0.0;
  b_x[34] = -t3;
  b_varargin_3[0] = -varargin_3 * t11;
  b_varargin_3[1] = -varargin_3 * t8;
  b_varargin_3[2] = varargin_3 * t8;
  b_varargin_3[3] = varargin_3 * t11;
  b_varargin_3[4] = t3;
  b_varargin_3[5] = -t2;
  b_varargin_3[6] = -varargin_1[2] * t3 + t2 * t4;
  b_varargin_3[7] = varargin_3 * -33.613445378151262;
  b_varargin_3[8] = t5;
  b_varargin_3[9] = -t5;
  b_varargin_3[10] = t5;
  b_varargin_3[11] = 0.0;
  b_varargin_3[12] = 0.0;
  b_varargin_3[13] = 0.0;
  b_varargin_3[14] = varargin_3 * -33.613445378151262;
  b_varargin_3[15] = -t5;
  b_varargin_3[16] = -t5;
  b_varargin_3[17] = -t5;
  b_varargin_3[18] = 0.0;
  b_varargin_3[19] = 0.0;
  b_varargin_3[20] = 0.0;
  b_varargin_3[21] = varargin_3;
  b_varargin_3[22] = varargin_3;
  b_varargin_3[23] = varargin_3;
  b_varargin_3[24] = varargin_3;
  b_varargin_3[25] = 0.0;
  b_varargin_3[26] = 0.0;
  b_varargin_3[27] = 0.0;
  b_varargin_3[28] = varargin_3 * t2 * -3.5294117647058822;
  b_varargin_3[29] = varargin_3 * t2 * -2.1176470588235294;
  b_varargin_3[30] = varargin_3 * t2 * 2.1176470588235294;
  b_varargin_3[31] = varargin_3 * t2 * 3.5294117647058822;
  b_varargin_3[32] = 0.0;
  b_varargin_3[33] = 0.0;
  b_varargin_3[34] = -t3;

  /* MEASUREMENT_FUNCTION */
  /*     H_X = MEASUREMENT_FUNCTION(IN1,IN2,IN3,DT) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.1. */
  /*     02-Aug-2019 13:28:46 */
  t2 = x[1] * 33.613445378151262;
  t3 = x[2] * 33.613445378151262;
  t4 = cos(x[0]);
  t5 = sin(x[0]);
  t11 = x[4] - varargin_1[1];
  t7 = varargin_1[2] * t4 * 2.1176470588235294;
  t8 = t5 * t11 * 3.5294117647058822;
  for (i0 = 0; i0 < 5; i0++) {
    for (i = 0; i < 7; i++) {
      b_dHdx[i + 7 * i0] = b_varargin_3[i + 7 * i0];
      gain[i0 + 5 * i] = 0.0;
      for (i1 = 0; i1 < 5; i1++) {
        gain[i0 + 5 * i] += P[i0 + 5 * i1] * b_x[i + 7 * i1];
      }
    }
  }

  for (i0 = 0; i0 < 7; i0++) {
    for (i = 0; i < 5; i++) {
      b_varargin_3[i0 + 7 * i] = 0.0;
      for (i1 = 0; i1 < 5; i1++) {
        b_varargin_3[i0 + 7 * i] += b_dHdx[i0 + 7 * i1] * P[i1 + 5 * i];
      }
    }

    for (i = 0; i < 7; i++) {
      d0 = 0.0;
      for (i1 = 0; i1 < 5; i1++) {
        d0 += b_varargin_3[i0 + 7 * i1] * b_dHdx[i + 7 * i1];
      }

      dHdx[i0 + 7 * i] = d0 + zcov[i0 + 7 * i];
    }
  }

  mrdivide(gain, dHdx);
  b_varargin_2[0] = varargin_2[0] - varargin_3 * (((((-x[3] + varargin_1[0]) +
    t2) + t3) + t8) - varargin_1[2] * t4 * 3.5294117647058822);
  b_varargin_2[1] = varargin_2[1] + varargin_3 * (((((x[3] - varargin_1[0]) + t2)
    - t3) + t7) - t5 * t11 * 2.1176470588235294);
  b_varargin_2[2] = varargin_2[2] - varargin_3 * (((((-x[3] + varargin_1[0]) +
    t2) + t3) + t7) - t5 * t11 * 2.1176470588235294);
  b_varargin_2[3] = varargin_2[3] + varargin_3 * (((((x[3] - varargin_1[0]) + t2)
    - t3) + t8) - varargin_1[2] * t4 * 3.5294117647058822);
  b_varargin_2[4] = t5;
  b_varargin_2[5] = t4;
  b_varargin_2[6] = -varargin_1[2] * t5 - t4 * t11;
  for (i0 = 0; i0 < 7; i0++) {
    b_z[i0] = z[i0] - b_varargin_2[i0];
  }

  for (i0 = 0; i0 < 5; i0++) {
    d0 = 0.0;
    for (i = 0; i < 7; i++) {
      d0 += gain[i0 + 5 * i] * b_z[i];
    }

    for (i = 0; i < 5; i++) {
      b_gain[i0 + 5 * i] = 0.0;
      for (i1 = 0; i1 < 7; i1++) {
        b_gain[i0 + 5 * i] += gain[i0 + 5 * i1] * b_x[i1 + 7 * i];
      }
    }

    for (i = 0; i < 5; i++) {
      t11 = 0.0;
      for (i1 = 0; i1 < 5; i1++) {
        t11 += b_gain[i0 + 5 * i1] * P[i1 + 5 * i];
      }

      b_P[i0 + 5 * i] = P[i0 + 5 * i] - t11;
    }

    x[i0] += d0;
  }

  for (i = 0; i < 5; i++) {
    for (i0 = 0; i0 < 5; i0++) {
      P[i0 + 5 * i] = b_P[i0 + 5 * i];
    }

    obj->pState[i] = x[i];
  }

  memcpy(&obj->pStateCovariance[0], &P[0], 25U * sizeof(double));
  for (i = 0; i < 5; i++) {
    x_corr[i] = obj->pState[i];
  }

  for (i0 = 0; i0 < 25; i0++) {
    P_corr[i0] = obj->pStateCovariance[i0];
  }
}

/*
 * Arguments    : double *x
 * Return Type  : void
 */
static void b_sqrt(double *x)
{
  *x = sqrt(*x);
}

/*
 * Arguments    : int n
 *                const double x[8]
 *                int ix0
 * Return Type  : double
 */
static double b_xnrm2(int n, const double x[8], int ix0)
{
  double y;
  double scale;
  int kend;
  int k;
  double absxk;
  double t;
  y = 0.0;
  if (!(n < 1)) {
    if (n == 1) {
      y = fabs(x[ix0 - 1]);
    } else {
      scale = 3.3121686421112381E-170;
      kend = (ix0 + n) - 1;
      for (k = ix0; k <= kend; k++) {
        absxk = fabs(x[k - 1]);
        if (absxk > scale) {
          t = scale / absxk;
          y = 1.0 + y * t * t;
          scale = absxk;
        } else {
          t = absxk / scale;
          y += t * t;
        }
      }

      y = scale * sqrt(y);
    }
  }

  return y;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void c_CMD_state_estimation_single_s(void)
{
  ekf_not_empty = false;
  accel__norm_error = 1.0;
}

/*
 * Arguments    : extendedKalmanFilter *obj
 *                const double value[49]
 * Return Type  : void
 */
static void c_ExtendedKalmanFilter_set_Meas(extendedKalmanFilter *obj, const
  double value[49])
{
  int k;
  double ex;
  double y[7];
  int exponent;
  for (k = 0; k < 7; k++) {
    y[k] = fabs(value[k + 7 * k]);
  }

  ex = y[0];
  for (k = 0; k < 6; k++) {
    if (ex < y[k + 1]) {
      ex = y[k + 1];
    }
  }

  if (!(ex <= 2.2250738585072014E-308)) {
    frexp(ex, &exponent);
  }

  memcpy(&obj->pMeasurementNoise[0], &value[0], 49U * sizeof(double));
}

/*
 * Arguments    : extendedKalmanFilter *obj
 *                const double value[25]
 * Return Type  : void
 */
static void c_ExtendedKalmanFilter_set_Stat(extendedKalmanFilter *obj, const
  double value[25])
{
  int k;
  double ex;
  double y[5];
  int exponent;
  for (k = 0; k < 5; k++) {
    y[k] = fabs(value[k + 5 * k]);
  }

  ex = y[0];
  for (k = 0; k < 4; k++) {
    if (ex < y[k + 1]) {
      ex = y[k + 1];
    }
  }

  if (!(ex <= 2.2250738585072014E-308)) {
    frexp(ex, &exponent);
  }

  memcpy(&obj->pStateCovariance[0], &value[0], 25U * sizeof(double));
}

/*
 * Arguments    : extendedKalmanFilter *EKF
 *                const double varargin_3[5]
 * Return Type  : extendedKalmanFilter *
 */
static extendedKalmanFilter *c_extendedKalmanFilter_extended
  (extendedKalmanFilter *EKF, const double varargin_3[5])
{
  extendedKalmanFilter *b_EKF;
  b_EKF = EKF;
  d_extendedKalmanFilter_extended(&b_EKF, varargin_3);
  return b_EKF;
}

/*
 * Arguments    : extendedKalmanFilter **EKF
 *                const double varargin_3[5]
 * Return Type  : void
 */
static void d_extendedKalmanFilter_extended(extendedKalmanFilter **EKF, const
  double varargin_3[5])
{
  int i;
  for (i = 0; i < 5; i++) {
    (*EKF)->pState[i] = varargin_3[i];
  }

  for (i = 0; i < 25; i++) {
    (*EKF)->pStateCovariance[i] = 0.0;
  }

  for (i = 0; i < 5; i++) {
    (*EKF)->pStateCovariance[i + 5 * i] = 1.0;
  }

  (*EKF)->pIsValidStateTransitionFcn = false;
  (*EKF)->pIsValidMeasurementFcn = false;
  (*EKF)->pIsValidMeasurementFcn = false;
  (*EKF)->pIsValidStateTransitionFcn = false;
  for (i = 0; i < 25; i++) {
    (*EKF)->pProcessNoise[i] = 0.0;
  }

  for (i = 0; i < 5; i++) {
    (*EKF)->pProcessNoise[i + 5 * i] = 1.0;
  }
}

/*
 * Arguments    : int n
 *                const double x[2]
 *                int ix0
 * Return Type  : int
 */
static int ixamax(int n, const double x[2], int ix0)
{
  int idxmax;
  int ix;
  double smax;
  int k;
  double s;
  if (n < 1) {
    idxmax = 0;
  } else {
    idxmax = 1;
    if (n > 1) {
      ix = ix0 - 1;
      smax = fabs(x[ix0 - 1]);
      for (k = 2; k <= n; k++) {
        ix++;
        s = fabs(x[ix]);
        if (s > smax) {
          idxmax = k;
          smax = s;
        }
      }
    }
  }

  return idxmax;
}

/*
 * Arguments    : double A[35]
 *                const double B[49]
 * Return Type  : void
 */
static void mrdivide(double A[35], const double B[49])
{
  double b_A[49];
  int k;
  int j;
  signed char ipiv[7];
  int c;
  int jAcol;
  int jy;
  int ix;
  double smax;
  int iy;
  int i;
  double s;
  memcpy(&b_A[0], &B[0], 49U * sizeof(double));
  for (k = 0; k < 7; k++) {
    ipiv[k] = (signed char)(1 + k);
  }

  for (j = 0; j < 6; j++) {
    c = j << 3;
    jAcol = 0;
    ix = c;
    smax = fabs(b_A[c]);
    for (k = 2; k <= 7 - j; k++) {
      ix++;
      s = fabs(b_A[ix]);
      if (s > smax) {
        jAcol = k - 1;
        smax = s;
      }
    }

    if (b_A[c + jAcol] != 0.0) {
      if (jAcol != 0) {
        ipiv[j] = (signed char)((j + jAcol) + 1);
        ix = j;
        iy = j + jAcol;
        for (k = 0; k < 7; k++) {
          smax = b_A[ix];
          b_A[ix] = b_A[iy];
          b_A[iy] = smax;
          ix += 7;
          iy += 7;
        }
      }

      k = (c - j) + 7;
      for (i = c + 1; i < k; i++) {
        b_A[i] /= b_A[c];
      }
    }

    iy = c;
    jy = c + 7;
    for (jAcol = 1; jAcol <= 6 - j; jAcol++) {
      smax = b_A[jy];
      if (b_A[jy] != 0.0) {
        ix = c + 1;
        k = (iy - j) + 14;
        for (i = 8 + iy; i < k; i++) {
          b_A[i] += b_A[ix] * -smax;
          ix++;
        }
      }

      jy += 7;
      iy += 7;
    }
  }

  for (j = 0; j < 7; j++) {
    jy = 5 * j;
    jAcol = 7 * j;
    for (k = 1; k <= j; k++) {
      iy = 5 * (k - 1);
      if (b_A[(k + jAcol) - 1] != 0.0) {
        for (i = 0; i < 5; i++) {
          A[i + jy] -= b_A[(k + jAcol) - 1] * A[i + iy];
        }
      }
    }

    smax = 1.0 / b_A[j + jAcol];
    for (i = 0; i < 5; i++) {
      A[i + jy] *= smax;
    }
  }

  for (j = 6; j >= 0; j--) {
    jy = 5 * j;
    jAcol = 7 * j - 1;
    for (k = j + 2; k < 8; k++) {
      iy = 5 * (k - 1);
      if (b_A[k + jAcol] != 0.0) {
        for (i = 0; i < 5; i++) {
          A[i + jy] -= b_A[k + jAcol] * A[i + iy];
        }
      }
    }
  }

  for (jAcol = 5; jAcol >= 0; jAcol--) {
    if (ipiv[jAcol] != jAcol + 1) {
      iy = ipiv[jAcol] - 1;
      for (jy = 0; jy < 5; jy++) {
        smax = A[jy + 5 * jAcol];
        A[jy + 5 * jAcol] = A[jy + 5 * iy];
        A[jy + 5 * iy] = smax;
      }
    }
  }
}

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_hypotd(double u0, double u1)
{
  double y;
  double a;
  double b;
  a = fabs(u0);
  b = fabs(u1);
  if (a < b) {
    a /= b;
    y = b * sqrt(a * a + 1.0);
  } else if (a > b) {
    b /= a;
    y = a * sqrt(b * b + 1.0);
  } else {
    y = a * 1.4142135623730951;
  }

  return y;
}

/*
 * Arguments    : double A[8]
 *                double tau[2]
 *                int jpvt[2]
 * Return Type  : void
 */
static void xgeqp3(double A[8], double tau[2], int jpvt[2])
{
  int k;
  int iy;
  int i;
  double work[2];
  int i_i;
  double temp;
  int pvt;
  double vn1[2];
  double vn2[2];
  int ix;
  double atmp;
  double temp2;
  int i2;
  int lastv;
  int lastc;
  int exitg1;
  k = 1;
  for (iy = 0; iy < 2; iy++) {
    jpvt[iy] = 1 + iy;
    work[iy] = 0.0;
    temp = xnrm2(A, k);
    vn2[iy] = temp;
    k += 4;
    vn1[iy] = temp;
  }

  for (i = 0; i < 2; i++) {
    i_i = i + (i << 2);
    pvt = (i + ixamax(2 - i, vn1, i + 1)) - 1;
    if (pvt + 1 != i + 1) {
      ix = pvt << 2;
      iy = i << 2;
      for (k = 0; k < 4; k++) {
        temp = A[ix];
        A[ix] = A[iy];
        A[iy] = temp;
        ix++;
        iy++;
      }

      iy = jpvt[pvt];
      jpvt[pvt] = jpvt[i];
      jpvt[i] = iy;
      vn1[pvt] = vn1[i];
      vn2[pvt] = vn2[i];
    }

    atmp = A[i_i];
    temp2 = 0.0;
    temp = b_xnrm2(3 - i, A, i_i + 2);
    if (temp != 0.0) {
      temp = rt_hypotd(A[i_i], temp);
      if (A[i_i] >= 0.0) {
        temp = -temp;
      }

      if (fabs(temp) < 1.0020841800044864E-292) {
        iy = 0;
        i2 = (i_i - i) + 4;
        do {
          iy++;
          for (k = i_i + 1; k < i2; k++) {
            A[k] *= 9.9792015476736E+291;
          }

          temp *= 9.9792015476736E+291;
          atmp *= 9.9792015476736E+291;
        } while (!(fabs(temp) >= 1.0020841800044864E-292));

        temp = rt_hypotd(atmp, b_xnrm2(3 - i, A, i_i + 2));
        if (atmp >= 0.0) {
          temp = -temp;
        }

        temp2 = (temp - atmp) / temp;
        atmp = 1.0 / (atmp - temp);
        i2 = (i_i - i) + 4;
        for (k = i_i + 1; k < i2; k++) {
          A[k] *= atmp;
        }

        for (k = 1; k <= iy; k++) {
          temp *= 1.0020841800044864E-292;
        }

        atmp = temp;
      } else {
        temp2 = (temp - A[i_i]) / temp;
        atmp = 1.0 / (A[i_i] - temp);
        i2 = (i_i - i) + 4;
        for (k = i_i + 1; k < i2; k++) {
          A[k] *= atmp;
        }

        atmp = temp;
      }
    }

    tau[i] = temp2;
    A[i_i] = atmp;
    if (i + 1 < 2) {
      atmp = A[i_i];
      A[i_i] = 1.0;
      if (tau[0] != 0.0) {
        lastv = 4;
        iy = i_i + 3;
        while ((lastv > 0) && (A[iy] == 0.0)) {
          lastv--;
          iy--;
        }

        lastc = 1;
        iy = 5;
        do {
          exitg1 = 0;
          if (iy <= lastv + 4) {
            if (A[iy - 1] != 0.0) {
              exitg1 = 1;
            } else {
              iy++;
            }
          } else {
            lastc = 0;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      } else {
        lastv = 0;
        lastc = 0;
      }

      if (lastv > 0) {
        if (lastc != 0) {
          ix = i_i;
          temp = 0.0;
          for (iy = 5; iy <= lastv + 4; iy++) {
            temp += A[iy - 1] * A[ix];
            ix++;
          }

          work[0] = temp;
        }

        if (!(-tau[0] == 0.0)) {
          pvt = 4;
          k = 0;
          iy = 1;
          while (iy <= lastc) {
            if (work[k] != 0.0) {
              temp = work[k] * -tau[0];
              ix = i_i;
              i2 = lastv + pvt;
              for (iy = pvt; iy < i2; iy++) {
                A[iy] += A[ix] * temp;
                ix++;
              }
            }

            k++;
            pvt += 4;
            iy = 2;
          }
        }
      }

      A[i_i] = atmp;
    }

    iy = i + 2;
    while (iy < 3) {
      if (vn1[1] != 0.0) {
        temp = fabs(A[4 + i]) / vn1[1];
        temp = 1.0 - temp * temp;
        if (temp < 0.0) {
          temp = 0.0;
        }

        temp2 = vn1[1] / vn2[1];
        temp2 = temp * (temp2 * temp2);
        if (temp2 <= 1.4901161193847656E-8) {
          vn1[1] = b_xnrm2(3 - i, A, i + 6);
          vn2[1] = vn1[1];
        } else {
          vn1[1] *= sqrt(temp);
        }
      }

      iy = 3;
    }
  }
}

/*
 * Arguments    : const double x[8]
 *                int ix0
 * Return Type  : double
 */
static double xnrm2(const double x[8], int ix0)
{
  double y;
  double scale;
  int k;
  double absxk;
  double t;
  y = 0.0;
  scale = 3.3121686421112381E-170;
  for (k = ix0; k <= ix0 + 3; k++) {
    absxk = fabs(x[k - 1]);
    if (absxk > scale) {
      t = scale / absxk;
      y = 1.0 + y * t * t;
      scale = absxk;
    } else {
      t = absxk / scale;
      y += t * t;
    }
  }

  return scale * sqrt(y);
}

/*
 * Extract needed parts of state
 * Arguments    : const double state_in[10]
 *                const double P_old[25]
 *                const double u[3]
 *                const double z[7]
 *                const double theta_i_prev[4]
 *                double dt
 *                double state_out[10]
 *                double P_new[25]
 *                double *ignoring_accel
 * Return Type  : void
 */
void CMD_state_estimation_single_step(const double state_in[10], const double
  P_old[25], const double u[3], const double z[7], const double theta_i_prev[4],
  double dt, double state_out[10], double P_new[25], double *ignoring_accel)
{
  int i;
  double x_old[5];
  double tol;
  static const double value[25] = { 1.0E-11, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0E-15, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0E-15 };

  int rankR;
  static const signed char b_value[49] = { 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0,
    0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0,
    0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 10 };

  double dv0[49];
  int j;
  static const signed char a[4] = { 10, 0, 0, 10 };

  double Q[25];
  double P[25];
  double Jacobian[25];
  double b_Jacobian[25];
  double M[12];
  double b_x_old;
  double B[4];
  double A[8];
  double tau[2];
  int jpvt[2];
  double Dx[2];
  for (i = 0; i < 3; i++) {
    x_old[i] = state_in[i + 3];
  }

  for (i = 0; i < 2; i++) {
    x_old[i + 3] = state_in[i + 8];
  }

  if (!ekf_not_empty) {
    c_extendedKalmanFilter_extended(&ekf, x_old);
    ekf_not_empty = true;

    /*  theta_p */
    /*  vx vy */
    /*  b_p b_q */
    /*  encoders */
    /*  accel */
    /*  q */
    memcpy(&ekf.pProcessNoise[0], &value[0], 25U * sizeof(double));
    for (rankR = 0; rankR < 49; rankR++) {
      ekf.pMeasurementNoise[rankR] = b_value[rankR];
    }
  }

  for (i = 0; i < 5; i++) {
    ekf.pState[i] = x_old[i];
  }

  c_ExtendedKalmanFilter_set_Stat(&ekf, P_old);
  tol = z[4] * z[4] + z[5] * z[5];
  b_sqrt(&tol);
  accel__norm_error = 0.99 * accel__norm_error + 0.010000000000000009 * fabs(1.0
    - tol);

  /*  Increase accelerometer measurement variance if measuring centripetal acceleration */
  if (accel__norm_error > 0.01) {
    *ignoring_accel = 1.0;
    i = 1000000;
  } else {
    *ignoring_accel = 0.0;
    i = 1;
  }

  /*  scale = (1+exp(500*abs(sqrt(z(5)^2 + z(6)^2) - 1))); */
  /*  if scale > 1e9 */
  /*      scale = 1e9; */
  /*  end */
  memcpy(&dv0[0], &ekf.pMeasurementNoise[0], 49U * sizeof(double));
  for (rankR = 0; rankR < 2; rankR++) {
    for (j = 0; j < 2; j++) {
      dv0[(j + 7 * (4 + rankR)) + 4] = a[j + (rankR << 1)] * i;
    }
  }

  c_ExtendedKalmanFilter_set_Meas(&ekf, dv0);

  /*  Predict & update */
  if (!ekf.pIsValidStateTransitionFcn) {
    ekf.pIsValidStateTransitionFcn = true;
  }

  memcpy(&Q[0], &ekf.pProcessNoise[0], 25U * sizeof(double));
  for (i = 0; i < 5; i++) {
    x_old[i] = ekf.pState[i];
  }

  memcpy(&P[0], &ekf.pStateCovariance[0], 25U * sizeof(double));

  /* STATE_TRANSITION_JACOBIAN_FUNCTION */
  /*     F_X_U = STATE_TRANSITION_JACOBIAN_FUNCTION(IN1,IN2,DT) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.1. */
  /*     02-Aug-2019 13:28:46 */
  Jacobian[0] = 1.0;
  Jacobian[1] = 0.0;
  Jacobian[2] = 0.0;
  Jacobian[3] = 0.0;
  Jacobian[4] = 0.0;
  Jacobian[5] = 0.0;
  Jacobian[6] = 1.0;
  Jacobian[7] = 0.0;
  Jacobian[8] = 0.0;
  Jacobian[9] = 0.0;
  Jacobian[10] = 0.0;
  Jacobian[11] = 0.0;
  Jacobian[12] = 1.0;
  Jacobian[13] = 0.0;
  Jacobian[14] = 0.0;
  Jacobian[15] = -dt;
  Jacobian[16] = 0.0;
  Jacobian[17] = 0.0;
  Jacobian[18] = 1.0;
  Jacobian[19] = 0.0;
  Jacobian[20] = 0.0;
  Jacobian[21] = 0.0;
  Jacobian[22] = 0.0;
  Jacobian[23] = 0.0;
  Jacobian[24] = 1.0;
  for (rankR = 0; rankR < 5; rankR++) {
    for (j = 0; j < 5; j++) {
      b_Jacobian[j + 5 * rankR] = Jacobian[j + 5 * rankR];
    }
  }

  /* STATE_TRANSITION_FUNCTION */
  /*     F_X_U = STATE_TRANSITION_FUNCTION(IN1,IN2,DT) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.1. */
  /*     02-Aug-2019 13:28:46 */
  ekf.pState[0] = x_old[0] - dt * (x_old[3] - u[0]);
  ekf.pState[1] = x_old[1];
  ekf.pState[2] = x_old[2];
  ekf.pState[3] = x_old[3];
  ekf.pState[4] = x_old[4];
  for (rankR = 0; rankR < 5; rankR++) {
    for (j = 0; j < 5; j++) {
      Jacobian[rankR + 5 * j] = 0.0;
      for (i = 0; i < 5; i++) {
        Jacobian[rankR + 5 * j] += b_Jacobian[rankR + 5 * i] * P[i + 5 * j];
      }
    }
  }

  for (rankR = 0; rankR < 5; rankR++) {
    for (j = 0; j < 5; j++) {
      tol = 0.0;
      for (i = 0; i < 5; i++) {
        tol += Jacobian[rankR + 5 * i] * b_Jacobian[j + 5 * i];
      }

      ekf.pStateCovariance[rankR + 5 * j] = tol + Q[rankR + 5 * j];
    }
  }

  ExtendedKalmanFilter_correct(&ekf, z, u, theta_i_prev, dt, x_old, P_new);

  /*  Calculate new states not included in EKF */
  /*  forward kinematics matrix */
  M[0] = -(5656.85424949238 * cos(0.78539816339744828 + state_in[2])) / 119.0;
  M[4] = -(5656.85424949238 * sin(0.78539816339744828 + state_in[2])) / 119.0;
  M[8] = 3.5294117647058822;
  M[1] = 5656.85424949238 * sin(0.78539816339744828 + state_in[2]) / 119.0;
  M[5] = -(5656.85424949238 * cos(0.78539816339744828 + state_in[2])) / 119.0;
  M[9] = 2.1176470588235294;
  M[2] = -(5656.85424949238 * cos(0.78539816339744828 + state_in[2])) / 119.0;
  M[6] = -(5656.85424949238 * sin(0.78539816339744828 + state_in[2])) / 119.0;
  M[10] = -2.1176470588235294;
  M[3] = 5656.85424949238 * sin(0.78539816339744828 + state_in[2]) / 119.0;
  M[7] = -(5656.85424949238 * cos(0.78539816339744828 + state_in[2])) / 119.0;
  M[11] = -3.5294117647058822;

  /*  Calculate change in position */
  /*  Is this sign correct? */
  /* Dx = M\Dtheta_i; % Unknown Dphi */
  tol = u[2] * cos(state_in[3]) + (u[1] - state_in[9]) * sin(state_in[3]);
  b_x_old = x_old[0] - state_in[3];
  for (rankR = 0; rankR < 4; rankR++) {
    B[rankR] = ((z[rankR] - theta_i_prev[rankR]) + b_x_old) - M[8 + rankR] * dt *
      tol;
  }

  for (rankR = 0; rankR < 2; rankR++) {
    for (j = 0; j < 4; j++) {
      A[j + (rankR << 2)] = M[j + (rankR << 2)];
    }
  }

  xgeqp3(A, tau, jpvt);
  rankR = 0;
  tol = 4.0 * fabs(A[0]) * 2.2204460492503131E-16;
  while ((rankR < 2) && (!(fabs(A[rankR + (rankR << 2)]) <= tol))) {
    rankR++;
  }

  for (j = 0; j < 2; j++) {
    Dx[j] = 0.0;
    if (tau[j] != 0.0) {
      tol = B[j];
      for (i = j + 1; i + 1 < 5; i++) {
        tol += A[i + (j << 2)] * B[i];
      }

      tol *= tau[j];
      if (tol != 0.0) {
        B[j] -= tol;
        for (i = j + 1; i + 1 < 5; i++) {
          B[i] -= A[i + (j << 2)] * tol;
        }
      }
    }
  }

  for (i = 0; i < rankR; i++) {
    Dx[jpvt[i] - 1] = B[i];
  }

  for (j = rankR - 1; j + 1 > 0; j--) {
    Dx[jpvt[j] - 1] /= A[j + (j << 2)];
    i = 1;
    while (i <= j) {
      Dx[jpvt[0] - 1] -= Dx[jpvt[j] - 1] * A[j << 2];
      i = 2;
    }
  }

  /*  With Dphi knowledge, appears to improve performance */
  /*  + Dx(3); */
  for (i = 0; i < 2; i++) {
    state_out[i] = state_in[i] + Dx[i];
  }

  state_out[2] = state_in[2] + dt * (u[2] * cos(state_in[3]) + u[1] * sin
    (state_in[3]));
  state_out[3] = x_old[0];
  state_out[4] = x_old[1];
  state_out[5] = x_old[2];
  state_out[6] = u[2] * cos(state_in[3]) + (u[1] - state_in[9]) * sin(state_in[3]);
  state_out[7] = u[0] - state_in[8];
  state_out[8] = x_old[3];
  state_out[9] = x_old[4];
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void CMD_state_estimation_single_step_initialize(void)
{
  c_CMD_state_estimation_single_s();
}

/*
 * File trailer for CMD_state_estimation_single_step.c
 *
 * [EOF]
 */
