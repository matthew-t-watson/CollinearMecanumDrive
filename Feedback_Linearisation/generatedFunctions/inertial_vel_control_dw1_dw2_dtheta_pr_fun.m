function [dtheta_pr,dw1,dw2] = inertial_vel_control_dw1_dw2_dtheta_pr_fun(in1,in2,Kv,Kdphi,Kr,Kw1,Kw2,theta_p_max,w1_max,w2_max,theta_pr,dxr,dyr,dphir,fss_minus1_dvy_mvxdphi,K_slow_dtheta_p,K_slow_theta_p)
%INERTIAL_VEL_CONTROL_DW1_DW2_DTHETA_PR_FUN
%    [DTHETA_PR,DW1,DW2] = INERTIAL_VEL_CONTROL_DW1_DW2_DTHETA_PR_FUN(IN1,IN2,KV,KDPHI,KR,KW1,KW2,THETA_P_MAX,W1_MAX,W2_MAX,THETA_PR,DXR,DYR,DPHIR,FSS_MINUS1_DVY_MVXDPHI,K_SLOW_DTHETA_P,K_SLOW_THETA_P)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    07-Jun-2020 11:40:57

state3 = in1(3,:);
state4 = in1(4,:);
state5 = in1(5,:);
state6 = in1(6,:);
state7 = in1(7,:);
state8 = in1(8,:);
w1 = in2(1,:);
w2 = in2(2,:);
t2 = cos(fss_minus1_dvy_mvxdphi);
t3 = cos(state3);
t4 = cos(state4);
t5 = cos(theta_pr);
t6 = sin(fss_minus1_dvy_mvxdphi);
t7 = sin(state3);
t8 = sin(state4);
t9 = sin(theta_pr);
t10 = fss_minus1_dvy_mvxdphi.*theta_pr;
t11 = state6.*state7;
t12 = state5.*w2;
t13 = state7.*w1;
t14 = fss_minus1_dvy_mvxdphi.*2.0;
t15 = state4.*2.0;
t16 = state7.^2;
t17 = theta_pr.*2.0;
t18 = theta_pr.^2;
t19 = theta_p_max.^2;
t30 = -theta_pr;
t35 = state5.*state7.*(1.61e+2./5.0e+1);
t49 = state6.*3.132773109243698e-3;
t51 = state6.*9.956359014193912e-1;
t20 = cos(t14);
t21 = t2.^2;
t22 = t4.^2;
t23 = t5.^2;
t24 = sin(t14);
t25 = t6.^2;
t26 = sin(t15);
t27 = t8.^2;
t28 = sin(t17);
t29 = t9.^2;
t31 = -t11;
t32 = -t19;
t33 = fss_minus1_dvy_mvxdphi+t30;
t34 = t12+t13;
t39 = state5.*state7.*t4.*2.254e-1;
t40 = state5.*state7.*t5.*2.254e-1;
t41 = t8.*t16.*2.254e-1;
t42 = t9.*t16.*2.254e-1;
t43 = t8.*2.211174;
t44 = t9.*2.211174;
t47 = t8.*1.0724748384e-10;
t48 = t9.*1.0724748384e-10;
t50 = -t49;
t54 = t4.*t8.*2.139513167784796e-14;
t55 = t5.*t9.*2.139513167784796e-14;
t56 = t8.*1.662431635466839e-14;
t57 = t9.*1.662431635466839e-14;
t62 = t4.*1.133180532546843e-12;
t63 = t5.*1.133180532546843e-12;
t36 = t18+t32;
t37 = t10+t32;
t45 = t16.*t26.*2.277218939393939e-2;
t46 = t16.*t28.*2.277218939393939e-2;
t52 = t27.*5.20852249933514e-9;
t53 = t29.*5.20852249933514e-9;
t58 = t8.*t22.*4.822462680186929e-15;
t59 = t9.*t23.*4.822462680186929e-15;
t64 = t4.*t27.*1.039064234705584e-12;
t65 = t5.*t29.*1.039064234705584e-12;
t66 = t35+t41+t51;
t67 = t35+t42+t51;
t68 = t22.*2.554188920360585e-13;
t69 = t23.*2.554188920360585e-13;
t72 = t27.*8.073674334265432e-13;
t73 = t29.*8.073674334265432e-13;
t74 = t22.*t27.*2.342050785026386e-13;
t75 = t23.*t29.*2.342050785026386e-13;
t38 = 1.0./t37;
t60 = -t58;
t61 = -t59;
t70 = -t68;
t71 = -t69;
t76 = -t74;
t77 = -t75;
t78 = t39+t43+t45+t50;
t79 = t40+t44+t46+t50;
t80 = t47+t52+5.680299737437486e-9;
t81 = t48+t53+5.680299737437486e-9;
t82 = t54+t62+t64;
t83 = t55+t63+t65;
t84 = t56+t60+t70+t72+t76+8.804971123180858e-13;
t85 = t57+t61+t71+t73+t77+8.804971123180858e-13;
t86 = 1.0./(t56-t58+t70+t72+t76+8.804971123180858e-13);
t87 = 1.0./(t57-t59+t71+t73+t77+8.804971123180858e-13);
dtheta_pr = exp(-K_slow_theta_p.*abs(state4+t30)-K_slow_dtheta_p.*abs(state8)).*(Kr.*t33.*t37-(Kv.*t36.^2.*t38.*(state6+dxr.*t7-dyr.*t3).*(state5.*state7-t67.*t81.*t87.*4.491194675094697e-5+t79.*t83.*t87-((t81.*t87.*4.491194675094697e-5+t83.*t87.*2.975e-2).*(t23.*4.49657419225e-5-1.550089173138068e-4).*(t67.*t87.*(t5.*1.280339560818409e-9+t5.*t9.*2.4173582857536e-11+t5.*t29.*1.174000971350141e-9).*8.850625e-4-t79.*t87.*(t9.*3.276090229454028e-13+t29.*1.591048018937218e-11+1.735161870832496e-11)))./(t5.*1.994930875e-4+9.08773621875e-5)))./t33)-(t36.*t38.*(t12.*-1.487621313562313e+30-t13.*1.487621313562313e+30+t2.*t12.*9.415106672479785e+31+t2.*t13.*9.415106672479785e+31+t12.*t21.*1.069240648431695e+32+t13.*t21.*1.069240648431695e+32-t2.*t34.*9.741667833290163e+31-t21.*t34.*1.069240648431695e+32+state7.*t6.*w2.*2.898146180403823e+30+state7.*t24.*w2.*9.842018851487613e+30+state7.*t2.*t6.*w2.*6.361981858168585e+30+state7.*t2.*t24.*w2.*2.160510253219621e+31))./(t2.*4.778288072228825e+32+t21.*1.048925076111493e+33+t25.*1.048925076111493e+33+state6.*t6.*1.256495091399306e+31+t2.*t16.*1.449073090201912e+30+t16.*t20.*9.842018851487613e+30+t16.*t21.*3.180990929084292e+30+t16.*t25.*3.180990929084292e+30-state5.*state7.*t6.*3.26561160810378e+30+t2.*t16.*t20.*2.160510253219621e+31+t6.*t16.*t24.*1.08025512660981e+31);
if nargout > 1
    dw1 = state6.*w2+Kw1.*(t11-w1)-state7.*(t66.*t80.*t86.*4.491194675094697e-5-t78.*t82.*t86+((t80.*t86.*4.491194675094697e-5+t82.*t86.*2.975e-2).*(t22.*4.49657419225e-5-1.550089173138068e-4).*(t66.*t86.*(t4.*1.280339560818409e-9+t4.*t8.*2.4173582857536e-11+t4.*t27.*1.174000971350141e-9).*8.850625e-4-t78.*t86.*(t8.*3.276090229454028e-13+t27.*1.591048018937218e-11+1.735161870832496e-11)))./(t4.*1.994930875e-4+9.08773621875e-5))+(Kv.*(t11-w1+w1_max).^2.*(-state5+dxr.*t3+dyr.*t7).*(t31+w1+w1_max).^2)./w1_max;
end
if nargout > 2
    dw2 = -Kw2.*w2+Kdphi.*(w2.^2-w2_max.^2).^2.*(dphir-state7);
end
