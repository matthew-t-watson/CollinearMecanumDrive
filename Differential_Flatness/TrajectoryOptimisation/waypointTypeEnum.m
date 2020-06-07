classdef waypointTypeEnum
    %WAYPOINTTYPEENUM Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        boundary, 
        velocityConstraint, 
        position, 
        velocity, 
        acceleration, 
        velocityBoundary, 
        unconstrained % Used when we just want to use a SOS constraint on either side of the constraint
        velocityConstraintPlusPosition
    end
end

