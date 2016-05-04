function [ outageProb ] = amplifyAndForward( snrD,snrR,P,M,numbits,channelSD,channelSR,channelRD )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
k = log2(M);
bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);

n0Dlinear = std(x(:))/10^(snrD/10);

n0Rlinear = std(x(:))/10^(snrR/10);
n0Rdb = 10*log10(n0Rlinear);


xSD = filter(channelSD,x);
xSDn = awgn(xSD,snrD,'measured');

xSR = filter(channelSR,x);
xSRn = awgn(xSR,snrR,'measured');

%AMPLIFY APPROPRIATELY
%beta = sqrt(P / (channelSR.PathGains * P + n0SRlinear));
beta = 1;
xSRnEq = xSRn ./ channelSR.PathGains.';
xRD = filter(channelRD,beta.*xSRnEq);
xRDn = awgn(xRD,snrD,'measured');

%equalize
xSDnEq = xSDn ./ channelSD.PathGains.';
xRDnEq = xRDn ./ channelRD.PathGains.';

xMRC = maximalRatioCombine(xSDnEq,xRDnEq,channelSD.PathGains,channelRD.PathGains,n0Dlinear);
scatterplot(xMRC);
scatterplot(xSDn);
scatterplot(xRDn);
yn = qamdemod(xMRC,M,0,'gray');
yn = de2bi(yn,'left-msb')';

[numerr,ratioerr] = biterr(bits,yn)

end
