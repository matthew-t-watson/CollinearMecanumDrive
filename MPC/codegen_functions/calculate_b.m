function [ b ] = calculate_b( x, r, Fr, Fx, t )

b = t - Fr*r - Fx*x;

end

