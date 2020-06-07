function v = uFB(in1,in2)
%UFB
%    V = UFB(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    07-Jun-2020 11:42:14

w1 = in2(1,:);
w2 = in2(2,:);
w3 = in2(3,:);
z4 = in1(4,:);
z5 = in1(5,:);
z6 = in1(6,:);
z7 = in1(7,:);
z8 = in1(8,:);
t2 = cos(z4);
t3 = sin(z4);
t4 = z4.*2.0;
t5 = z7.^2;
t16 = z7.*7.464282352941176e-3;
t17 = z7.*2.090835392980722e-2;
t20 = z5.*7.275862130948636e-2;
t25 = z5.*6.493749673638682;
t6 = t2.^2;
t7 = sin(t4);
t8 = t3.^2;
t9 = t2.*z7.*z8.*4.508e-1;
t12 = t2.*1.994930875e-4;
t14 = t3.*1.0724748384e-10;
t18 = -t16;
t19 = -t17;
t24 = t2.*t3.*2.139513167784796e-14;
t27 = t3.*1.932700469060221e-9;
t29 = t3.*1.662431635466839e-14;
t33 = t2.*1.133180532546843e-12;
t10 = t7.*z7.*z8.*4.554437878787879e-2;
t13 = t6.*4.49657419225e-5;
t15 = t6.*1.2086791428768e-11;
t21 = t8.*5.20852249933514e-9;
t22 = t12+9.08773621875e-5;
t26 = t3.*t6.*5.606471679904819e-10;
t30 = t3.*t6.*4.822462680186929e-15;
t34 = t2.*t8.*1.039064234705584e-12;
t35 = t6.*2.554188920360585e-13;
t37 = t8.*8.073674334265432e-13;
t38 = t6.*t8.*2.342050785026386e-13;
t11 = -t10;
t23 = 1.0./t22;
t28 = -t26;
t31 = -t30;
t32 = t13-1.550089173138068e-4;
t36 = -t35;
t39 = -t38;
t40 = t14+t21+5.680299737437486e-9;
t41 = t24+t33+t34;
t42 = t15+t27+t28-4.166639697395127e-11;
t43 = t29+t31+t36+t37+t39+8.804971123180858e-13;
t44 = 1.0./(t29-t30+t36+t37+t39+8.804971123180858e-13);
t45 = t40.*t44.*4.491194675094697e-5;
t46 = t41.*t44.*2.975e-2;
t47 = t45+t46;
t48 = t23.*t32.*t47.*z8;
t49 = -t48;
t51 = z7.*(t48-z6).*(-1.61e+2./5.0e+1);
t52 = z7.*(t48-z6).*(1.61e+2./5.0e+1);
t53 = t3.*z7.*(t48-z6).*(-2.254e-1);
t50 = t49+z6;
t54 = t9+t19+t25+t52;
t55 = t11+t18+t20+t53;
v = [w1-t44.*t54.*(t6.*8.363203272615786e-11-t8.*3.905219265589605e-10+t6.*t8.*1.132845030404171e-10-2.883019448000656e-10).*8.850625e-4-t42.*t44.*(t10+t16-t20+t3.*z7.*(t48-z6).*2.254e-1).*8.850625e-4;w2-t42.*t44.*t54.*8.850625e-4-t44.*(t6.*8.584806753614885e-9-2.959412084247702e-8).*(t10+t16-t20+t3.*z7.*(t48-z6).*2.254e-1).*8.850625e-4;w3-t44.*(t3.*3.276090229454028e-13+t8.*1.591048018937218e-11+1.735161870832496e-11).*(t3.*2.211174+t48.*3.132773109243698e-3-z6.*3.132773109243698e-3-z8.*9.32e-5+t5.*t7.*2.277218939393939e-2+t2.*z5.*z7.*2.254e-1)+t44.*(t2.*1.280339560818409e-9+t2.*t3.*2.4173582857536e-11+t2.*t8.*1.174000971350141e-9).*(t48.*(-9.956359014193912e-1)+z6.*9.956359014193912e-1+z8.*3.132773109243698e-3+t3.*t5.*2.254e-1+z5.*z7.*(1.61e+2./5.0e+1)+t3.*z8.^2.*2.254e-1).*8.850625e-4];