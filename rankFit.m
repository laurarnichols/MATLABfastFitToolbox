function [ sorted ] = rankFit( x, y, population)

[nInds, ~] = size(population);

chiSquared = zeros(nInds, 1);

a1 = population(:,1);
beta = population(:,2);
tau = population(:,3);

startHeight = y(1);

% Try to fit each combo in your population
for i = 1:nInds
    yFit = a1(i) - (a1(i)-startHeight)*exp(-(x/tau(i)).^beta(i));
    chiSquared(i) = sum((yFit - y).^2)/length(x);
end
        
%--------------------------------------------------------------------------
% Sort by chiSquared
[~, index] = sort(chiSquared);

sorted = zeros(size(population));
for i = 1:length(population)
    sorted(i,:) = population(index(i),:);
end

end

