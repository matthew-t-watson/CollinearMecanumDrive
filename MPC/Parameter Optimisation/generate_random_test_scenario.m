function [ref, x0] = generate_random_test_scenario(length, range, seed)

rng(seed);

% x0 = [zeros(1,3) 2*(rand(1,5) - 0.5)] .* [0 0 0 0.3 1 1 0.5 0.5];
x0 = zeros(1,8);

for i=1:length
    if i == 1
        ref(:,i) = ([randn(1,3) zeros(1,5)].*range)';
    else
        ref(:,i) = ref(:,i-1) + ([randn(1,3) zeros(1,5)].*range)';
    end
end

end