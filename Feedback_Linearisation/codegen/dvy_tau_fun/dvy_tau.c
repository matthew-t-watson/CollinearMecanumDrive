/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * dvy_tau.c
 *
 * Code generation for function 'dvy_tau'
 *
 */

/* Include files */
#include "dvy_tau.h"
#include "mwmathutil.h"
#include "rt_nonfinite.h"

/* Function Definitions */
real_T dvy_tau(const emlrtStack *sp, const real_T in1[8], const real_T in2[4])
{
  real_T t2;
  real_T t3;
  real_T t4;
  real_T t5;
  real_T t6;
  real_T out1_tmp;
  (void)sp;

  /* DVY_TAU */
  /*     OUT1 = DVY_TAU(IN1,IN2) */
  /*     This function was generated by the Symbolic Math Toolbox version 8.4. */
  /*     07-Jun-2020 14:20:45 */
  t2 = muDoubleScalarCos(in1[3]);
  t3 = muDoubleScalarSin(in1[3]);
  t4 = in1[6] * in1[6];
  t5 = t2 * t2;
  t6 = t3 * t3;
  t5 = 1.0 / (((((t3 * 1.6624316354668391E-14 - t3 * t5 * 4.8224626801869287E-15)
                 + -(t5 * 2.554188920360585E-13)) + t6 * 8.0736743342654317E-13)
               + -(t5 * t6 * 2.342050785026386E-13)) + 8.8049711231808578E-13);
  out1_tmp = in1[4] * in1[6];
  return t5 * ((t3 * 1.0724748384E-10 + t6 * 5.20852249933514E-9) +
               5.6802997374374863E-9) * ((((((((in1[5] * 0.99563590141939118 +
    in1[7] * 0.003132773109243698) + in2[0] * 33.613445378151262) + in2[1] *
    33.613445378151262) + in2[2] * 33.613445378151262) + in2[3] *
    33.613445378151262) + out1_tmp * 3.22) + t3 * t4 * 0.2254) + in1[7] * in1[7]
    * t3 * 0.2254) * -4.4911946750946972E-5 - t5 * ((t2 * 1.133180532546843E-12
    + t2 * t3 * 2.1395131677847961E-14) + t2 * t6 * 1.039064234705584E-12) *
    ((((((((in1[5] * 0.003132773109243698 + in1[7] * 9.32E-5) - t3 * 2.211174) +
          in2[0]) + in2[1]) + in2[2]) + in2[3]) - t4 * muDoubleScalarSin(in1[3] *
       2.0) * 0.02277218939393939) - out1_tmp * t2 * 0.2254);
}

/* End of code generation (dvy_tau.c) */
