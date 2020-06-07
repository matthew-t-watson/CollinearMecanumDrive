classdef optimisationTypeEnum
    %optimisationTypeEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        none
        step
        manual
        QR_decomp
        QP_YALMIP
        SOS
        SOS_velocity
        SOS_velocity_circular
        recursive_vel_ineqs_YALMIP
        gridded_vel_ineqs_YALMIP
        recursive_vel_ineqs_fast
        recursive_SOCP_vel_ineqs
    end
end