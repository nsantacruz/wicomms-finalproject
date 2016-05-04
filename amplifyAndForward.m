function [ outageProb ] = amplifyAndForward( snrD,snrR,M,numbits,channelSD,channelSR,channelRD )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
k = log2(M);
bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);
xSD = filter(channelSD,x);
xSDn = awgn(xSD,snrD,'measured');
yn = qamdemod(xSDn,M,0,'gray');
yn = de2bi(yn,'left-msb')';

[numerr,ratioerr] = biterr(bits,yn)

end

