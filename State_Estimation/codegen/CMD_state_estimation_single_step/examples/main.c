/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 02-Aug-2019 13:28:47
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "CMD_state_estimation_single_step.h"
#include "main.h"

/* Function Declarations */
static void argInit_10x1_real_T(double result[10]);
static void argInit_3x1_real_T(double result[3]);
static void argInit_4x1_real_T(double result[4]);
static void argInit_5x5_real_T(double result[25]);
static void argInit_7x1_real_T(double result[7]);
static double argInit_real_T(void);
static void main_CMD_state_estimation_single_step(void);

/* Function Definitions */

/*
 * Arguments    : double result[10]
 * Return Type  : void
 */
static void argInit_10x1_real_T(double result[10])
{
  int idx0;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 10; idx0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx0] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[3]
 * Return Type  : void
 */
static void argInit_3x1_real_T(double result[3])
{
  int idx0;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 3; idx0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx0] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[4]
 * Return Type  : void
 */
static void argInit_4x1_real_T(double result[4])
{
  int idx0;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 4; idx0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx0] = argInit_real_T();
  }
}

/*
 * Arguments    : double result[25]
 * Return Type  : void
 */
static void argInit_5x5_real_T(double result[25])
{
  int idx0;
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 5; idx0++) {
    for (idx1 = 0; idx1 < 5; idx1++) {
      /* Set the value of the array element.
         Change this value to the value that the application requires. */
      result[idx0 + 5 * idx1] = argInit_real_T();
    }
  }
}

/*
 * Arguments    : double result[7]
 * Return Type  : void
 */
static void argInit_7x1_real_T(double result[7])
{
  int idx0;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 7; idx0++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx0] = argInit_real_T();
  }
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_CMD_state_estimation_single_step(void)
{
  double dv1[10];
  double dv2[25];
  double dv3[3];
  double dv4[7];
  double dv5[4];
  double state_out[10];
  double P_new[25];
  double ignoring_accel;

  /* Initialize function 'CMD_state_estimation_single_step' input arguments. */
  /* Initialize function input argument 'state_in'. */
  /* Initialize function input argument 'P_old'. */
  /* Initialize function input argument 'u'. */
  /* Initialize function input argument 'z'. */
  /* Initialize function input argument 'theta_i_prev'. */
  /* Call the entry-point 'CMD_state_estimation_single_step'. */
  argInit_10x1_real_T(dv1);
  argInit_5x5_real_T(dv2);
  argInit_3x1_real_T(dv3);
  argInit_7x1_real_T(dv4);
  argInit_4x1_real_T(dv5);
  CMD_state_estimation_single_step(dv1, dv2, dv3, dv4, dv5, argInit_real_T(),
    state_out, P_new, &ignoring_accel);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  CMD_state_estimation_single_step_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_CMD_state_estimation_single_step();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
