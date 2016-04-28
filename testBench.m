clc, clear, close all;

numbits = 1024;
M = 2;
k = log2(M);
snr = 20;
symbolPeriod = 1E-4;
coherenceTime = 10; %should be much greater than symbol period for slow fading
dopplerShift = 1/coherenceTime; 
channel = rayleighchan(symbolPeriod,dopplerShift);
channel.StorePathGains = true;


bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);
xc = filter(channel,x);
xcn = awgn(xc,snr,'measured');
yn = qamdemod(xcn,M,0,'gray');
yn = de2bi(yn,'left-msb')';

[numerr,ratioerr] = biterr(bits,yn)




