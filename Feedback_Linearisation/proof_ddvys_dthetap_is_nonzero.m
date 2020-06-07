

% syms vx vy dphi thetap a b c d e f g h i real
% ddvy_ss_dtheta_pr = -vx*dphi - b*sin(thetap)*dphi^2 + (-d*vy+sin(thetap)*(e*dphi^2-g) + h*vx*dphi)/(cos(thetap)+i);
% 
% % Calculate Hessian
% H = hessian(ddvy_ss_dtheta_pr,[vx vy dphi thetap]);
% 
% % Lets ignore vy since this is only there because of friction
% H = hessian(subs(ddvy_ss_dtheta_pr, vy, 0),[vx dphi thetap]);
% 
% eigenValues = eig(H);


% Ideally we would now show that the eigenvalues remain negative for a
% region of interest. However, they are far too complex to do anything
% useful with.
% eig(H)

%% Numerical method
syms theta_p(t) vx(t) vy(t) dphi(t);
ddvy_ss_dtheta_pr = formula(functionalDerivative(modelData.pv.dvy_ss, theta_p));
temp = sym('temp',[1 4]);
ddvy_ss_dtheta_pr = subs(ddvy_ss_dtheta_pr, [theta_p(t) vx(t) vy(t) dphi(t)], temp);
syms theta_p vx vy dphi real;
ddvy_ss_dtheta_pr = simplify(subs(ddvy_ss_dtheta_pr, temp, [theta_p vx vy dphi]), 100);


% H = simplify(hessian(ddvy_ss_dtheta_pr,[vx vy dphi theta_p]), 100);
% eigenValues = eig(H);


fun = matlabFunction(ddvy_ss_dtheta_pr, 'Vars', [theta_p vx vy dphi]);

theta_pr_range = linspace(-pi/2,pi/2);
clear val;
for i=1:1000    
    valid = false;
    while valid == false
        vxVal = 10*randn; vyVal = 10*randn; dphiVal = 30*randn;
        fun_fss_minus1_dvy0 = @(toSolve) f_solve_fdvy_theta_p_x([0;0;0;toSolve;vxVal;vyVal;dphiVal;0],zeros(3,1),0);
        [fss_minus1_dvy0, fval] = newtonRaphson(fun_fss_minus1_dvy0,0);
        if abs(fval) < 1e-12 && abs(fss_minus1_dvy0) <= pi/2
            valid = true;
        end
    end
    val(:,i) = fun(theta_pr_range, vxVal, vyVal, dphiVal);
end

figure; plot(theta_pr_range, val);

xlim([-pi/2 pi/2]);
ylim([-20 0]);
xlabel('\(\theta_{pr}\)')
ylabel('\(\frac{df_{\dot{v}_{y,ss}}(\theta_{pr})}{d\theta_{pr}}\)')

cleanfigure;
% matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\CMD\d_dvyss_dtheta_pr_values.tex', 'width', '0.7\linewidth', 'height', '0.3\linewidth', 'parseStrings', false, 'extraTikzpictureOptions', 'trim axis left, trim axis right')





