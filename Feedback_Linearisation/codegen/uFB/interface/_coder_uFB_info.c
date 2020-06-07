/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_uFB_info.c
 *
 * Code generation for function '_coder_uFB_info'
 *
 */

/* Include files */
#include "_coder_uFB_info.h"
#include "emlrt.h"
#include "rt_nonfinite.h"
#include "tmwtypes.h"

/* Function Declarations */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void);

/* Function Definitions */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char * data[18] = {
    "789ced5dcd6fe3c615e77e628360db5eda20489064112068b08029796dc9db1eb2fa966cebc3df5e25813c128712d7248726a9cf934e452f4572cbbda702b9ec"
    "21057ae8618ffd038a14c8a94051a0b7dcda6b4951636b1971a9f5cc52263d03c8d2f849eff7de1bce4fcf6f8663ee46a97c83e3b89f714e8b7de33cdfb71e37",
    "adc72fa6bfbfc9bddcdcf21bd3e7f75c7ddcee70b7cf3f87e5f6e3ab69bf8554130e4ca7a302059e7f52408aa402d5dc1f6a90d3a181e41e1426125192e1bea4"
    "c06d34d3294a5647c9cf88ce3bb6c87e9de9c0d6e95e57e1f48e7161a13cdb398fc7df66fce566fcbd3d271eb372ec3f74f5b999f7dd9c917f9efb32f31bfec0",
    "80bac11f01d3402a5f40a82dc34656977a903f42faa9a1811634f8323065d0e433e52c9f87506882d669635b5221d025039892f5c93654a10e4c28e4bb6acbfe"
    "8dc177f3e91565ea978d7b42e8d72d4fbf6e4df4b790134d5a78773df1ee4ef40ba8db94e105de9f08f10a9e788e7e2cffbcb47d3c19ba9a8eda3a503eb22f30",
    "6b8c52fbdba934bfbb1a8b3f6ef2264272130d78a8c8bc2c3579c51941288b5d95b722658d8c5f9cee722f372fbbddcfb8bdc5dd9bbe7a92cc7cf28f5470784e"
    "bb2e78030f7d8b5e77bff2c0c3d71d960f577760b2dfed8cc0eea3cd787daf2bc82390bbb0a3e683e36707e7d10f4a7f58e7ef98d0ee777decc6f21612a0be22",
    "595f9aba0ae415a30564a0af60d625e75d77f3b207378cf7974be261fd7b3e7858fedae3663f1e4ea2c63fc461e31f3a719b8ee1ac1f271e76d2e38df13ffff5"
    "29e3e1b0f3f028b55112e3894c2fb979749878b4666e8c5a0769c6c3cbe6e1af09edfed4c76e2c77f130d03479b83721159c7b97d49a6ce5edd3f763fb3442fb",
    "7eee631f968b532b1a1da00a56828cf149ffae69fae063391d9ef60eeb94b683e46df3bb0f196f879db713a7eba7477bc782da94eb8f3791517f5a4b4b85e8f0"
    "f6759bdf8bfa75cfd5bff0ebde44bf64181ad00db8acbac57342bc8a279ea31fcb49be6fed08d9dfb83856f61805c8bfdb6fbdcff837ecfc7b9641bbb54433b6",
    "bb512cef0ab1ce61b22bef6719ff5e75fe1d13fa7555ea1b97e56756df98ff8c1bab6f0483c7ea1b74f4b3f5bdf97ef9adef19923ae9b3f53dbfba9415a940d7"
    "f7c66c7def0de205c5bbf5a274067a62a7bc557a9a3b3c2e9a694d5bcb478777c33a7fc7847693e5bf9875d9fadeebe5bfce18cefa71e26127451efe1fcb7faf",
    "2e0fffd2030f5f87589e149adb427a3f69f62a05252e8b402f3f5ae3180f2f9b87bf26b49badefbd1affaad69f4e3cec66eb7be1c063eb7b74f447757e8f09fd"
    "ba2af9f5f5aa2fb3fc3a6a782cbfa6a39fd597e7fb75c7d3af3b4efe8cfa50a78817c5fa32d20c7e12a760ebcb7fffc3f7df33de7d437841f1ee30f658ed9432",
    "fd6a11aa869a384834eb8522171dde0debfc1d13dafda18fdd58eeca7f2523dd9564b3a456ba0ad4a5d6d27897f4fbb2ed89e7e8c7f2d71a37a3037428f04ef6"
    "ebfcb487f127e9b03b8ac1ded7f7c71fefb37cf8aaf2f2c2fb2d629ab465e45ad56c4dca77d6f73752cdf56a84eeeb7beef1f945e35873f5b999f7cdda4f8997",
    "1f88b2397949eb3a78c7c77e2c9f5b9fc8b597c6cb5776dce6d62570b8569400f9f7f9b74f18ff869d7fb35b7b3b49091eb407fab02b17125b4a3c118bd0be8b"
    "b0cf638dd0fefbaebedb7e2c970cd5c9e14cfbd891e5d52148c7abea89e7e8c7f24b7d5f8ad2000a1ab2868b7f295ec1d6233efbe66dc6bb61e7ddadf52dad16",
    "2f9e0a9d363c2b827e72c754a2b4df2decbc7b4268bfff7d77a264a5df9db0f2eca6279ea31fcbc979d68953f0fb22b8df329e0d3fcf1e14da72fc481ef63772"
    "4633a3547af17c0e46a8be40ba7e7eeca11fc711cb69f3ec0351d20d539468d5813ff0f103cb2db31a96390d11e932425a03f5a02ecaa8df68d987e42d6f9ff1",
    "8b4be261fd27aebe1b0fcb89f6253ac3fa8af805597f78f1d77fdf61eb7261e767632b37c86547a3dae66075adbc1acbeca4e2b108f1f37f3c3ebf681c7fe7a1"
    "1fc711cbdff4bc7ef0ea37343a50d6ec0d0cb4f2d9dbaefe85dfb7cff367bbbfe43ab5a40a7050524d6aebb0791f3bb09c465e1dec39164f922c9f0e3f5fc7b5",
    "fd7a516dad5506eab35e3e56c9e9854121427c1dd6f91bf63ab11fdfb73ac0de1ec7eac41ecfb8b13a713078ac4e4c473fcb8f2fe7b75fbdd732450183f0f2f3"
    "1bad2f9fdf6769bde09d48055f5f7e71ebcf1f317e0e3b3fafe513a5a18886e5c261bcdf1948aa82947284f261c6cf97f37b117eb66fbe63fcbc083f9fdf6ec7",
    "f839227841f1f35e6df59992ce0d0b4266071cc1b279f8ac7a10a1fba2a3b2fe7742e8c7ebd68b49f182bebf8ed58569e139edbae0b1ba301dfda1e5d911d491"
    "d10d705f1b3b4f9e9d277f75f82f683c769e3c1dfda4f3b8e6ea7333ef23da3fbce07d73bf27b4ffd73ef663f9bcf3dad2920a74d7f143b4d609977d4e1bf0c1",
    "c7728ae738cd0b272e4704992727d839c7e1e7edbd4aa2551ec910e8f51d35db958bc6f17a3a42f588a8ce6f523effd8c72f2c77f3790f49424ad7c1302f03d3"
    "84aaa4b65fb2ebe49276b99b975db8d1daa7fc850f1e96531adf39e1738636409e19ffb7c9f629879db7479bc5479903ed58d9695685d4b1582c0f946a313abc",
    "fdc2e3f38bc6b1eea11fc711cb69e5db4e85a321ca08980d7c781a47efba60e756b8f108ff6e62e7565c0b3c766e051dfda4f5e6230ffd388e584e8b8f556456"
    "40a5aa97aca9ddb6c89816fff99d9b29192a50b9f09e5751f2c473f46339857d1476a49651b7f8e107764e5be8f956a897370f1367b5b5fe4e5d13373692ab7d",
    "219d890edf867d1e8f09ed67e7687ae139fad9399ab4f09c765df0d8399a74f447251f1e13faf19e8f1f583effff7d8832424ea164593c4d3a8e079e788e7e2c"
    "a7fbff3e26715be8ff0150dc7fbcced6fbc2cfcb87d5b36c574f6f67536ae2ece906ec65aae2301d7e5efe3f7e1cc7c5",
    "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 38728U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xResult;
  mxArray *xEntryPoints;
  const char * epFieldName[6] = { "Name", "NumberOfInputs", "NumberOfOutputs",
    "ConstantInputs", "FullPath", "TimeStamp" };

  mxArray *xInputs;
  const char * propFieldName[4] = { "Version", "ResolvedFunctions",
    "EntryPoints", "CoverageInfo" };

  xEntryPoints = emlrtCreateStructMatrix(1, 1, 6, epFieldName);
  xInputs = emlrtCreateLogicalMatrix(1, 2);
  emlrtSetField(xEntryPoints, 0, "Name", emlrtMxCreateString("uFB"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", emlrtMxCreateDoubleScalar(2.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs", emlrtMxCreateDoubleScalar
                (1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath", emlrtMxCreateString(
    "C:\\Users\\Watson\\Google_Drive\\Workspaces\\Matlab\\CMD\\Feedback_Linearisation\\generatedFunctions\\uFB.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp", emlrtMxCreateDoubleScalar
                (737817.41954861116));
  xResult = emlrtCreateStructMatrix(1, 1, 4, propFieldName);
  emlrtSetField(xResult, 0, "Version", emlrtMxCreateString(
    "9.7.0.1261785 (R2019b) Update 3"));
  emlrtSetField(xResult, 0, "ResolvedFunctions", (mxArray *)
                emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

/* End of code generation (_coder_uFB_info.c) */
