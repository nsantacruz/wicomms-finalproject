clc, clear, close all;

numbits = 1024;
M = 2;
k = log2(M);
snr = 20;
channel = [1,0.2,0.7];


bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);
xc = conv(channel,x);
xc = xc(1:length(x));
xcn = awgn(xc,snr,'measured');
yn = qamdemod(xcn,M,0,'gray');
yn = de2bi(yn,'left-msb')';

[numerr,ratioerr] = biterr(bits,yn)




