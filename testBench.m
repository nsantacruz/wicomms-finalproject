clc, clear, close all;

numbits = 1024;
M = 2;
snrD = 10;
snrR = 20;
r = 50; % bits/s
W = 100; % Hz , guessing
R = (2*r)/W;
SNRnorm = snrD / (2^R-1);

symbolPeriod = 1E-4;
coherenceTime = 10; %should be much greater than symbol period for slow fading
dopplerShift = 1/coherenceTime; 
channelSD = rayleighchan(symbolPeriod,dopplerShift);
channelSD.StorePathGains = true;
channelSR = rayleighchan(symbolPeriod,dopplerShift);
channelSR.StorePathGains = true;
channelRD = rayleighchan(symbolPeriod,dopplerShift);
channelRD.StorePathGains = true;

amplifyAndForward(snrD,snrR,M,numbits,channelSD,channelSR,channelRD);





