//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: calculate_cinf.cpp
//
// MATLAB Coder version            : 4.0
// C/C++ source code generated on  : 30-Jul-2019 16:20:28
//

// Include Files
#include "calculate_cinf.h"

// Function Definitions

//
// r = zeros(numel(r_reduced)*(8/3),1);
//  for i=1:numel(r_reduced/3)
//      r((i-1)*nx+(1:3)) = r_reduced((i-1)*3+(1:3));
//  end
// Arguments    : const real_T x[8]
//                const real_T r[36]
//                real_T cinf[4]
// Return Type  : void
//
void calculate_cinf(const real_T x[8], const real_T r[36], real_T cinf[4])
{
  int32_T i0;
  real_T b_x[3];
  int32_T i1;
  static const real_T a[12] = { -1.3422739431640853, 1.3422739431640922,
    1.3422739431640915, -1.3422739431640864, 0.98016621514323587,
    0.980166215143231, 0.98016621514322955, 0.98016621514323343,
    1.0871744928014138, 0.652304695680848, -0.65230469568084759,
    -1.0871744928014124 };

  for (i0 = 0; i0 < 3; i0++) {
    b_x[i0] = x[i0] - r[33 + i0];
  }

  for (i0 = 0; i0 < 4; i0++) {
    cinf[i0] = 0.0;
    for (i1 = 0; i1 < 3; i1++) {
      cinf[i0] += a[i0 + (i1 << 2)] * b_x[i1];
    }
  }
}

//
// Arguments    : void
// Return Type  : void
//
void calculate_cinf_initialize()
{
}

//
// File trailer for calculate_cinf.cpp
//
// [EOF]
//
