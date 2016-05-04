function [ combo ] = maximalRatioCombine( sig1,sig2,h1,h2,N0)
%MAXIMALRATIOCOMBINE - combine signals, maximally
% sig1, sig2 - received signals
% h1,h2 - path gains associated with each signal

a1 = h1'.*h1.' / N0;
a2 = h2'.*h2.' / N0;

combo = a1.*sig1 + a2.*sig2;

end

