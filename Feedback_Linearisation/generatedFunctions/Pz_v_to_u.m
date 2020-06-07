function u = Pz_v_to_u(in1,in2)
%PZ_V_TO_U
%    U = PZ_V_TO_U(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    07-Jun-2020 11:42:16

vin1 = in2(1,:);
vin2 = in2(2,:);
vin3 = in2(3,:);
z4 = in1(4,:);
t2 = cos(z4);
t3 = sin(z4);
t4 = t3.*2.254e-1;
t5 = t4-4.859317844784973e-3;
u = [vin1.*3.451396087846903+t5.*vin2;(vin3.*(t2.^2.*1.13056722548e+11-3.89736706389e+11).*(-1.06951871657754e-5))./(t2.*5.36452e+6+2.443761e+6);t5.*vin1+vin2.*(t3.^2.*4.554437878787879e-2+3.362303647058824e-2)];