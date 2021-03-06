function [ combo ] = maximalRatioCombine( sig1,sig2,h1,h2,N01,N02)
%MAXIMALRATIOCOMBINE - combine signals, maximally
% sig1, sig2 - received signals
% h1,h2 - path gains associated with each signal
if nargin < 6
    N02=N01;
end
a1 = (h1'.*h1.') / N01;
a2 = (h2'.*h2.') / N02;
% std(sig1)
% std(sig2)
% a1
% a2
combo = a1.*sig1 + a2.*sig2;
combo = combo / std(combo);

end

