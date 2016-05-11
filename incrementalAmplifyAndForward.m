function [ isoutage,rate ] = incrementalAmplifyAndForward( snrD,snrR,P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold,R )
%AMPLIFYANDFORWARD - implements the amplify and forward cooperative
%algorithm
%snrD, snrR - snr at destination and relay, respectively
%P - power limit of source and relay transmitters
%M - qam modulation order
%numbits - duh
%channelSD,channelSR,channelRD - rayleighchan objects for channel b/w
%source and destination, source and relay, relay and destination
%respectively
%outageThreshold - snr at destination below which the transmission is
%considered an outage, in dB.
%RETURNS - isoutage, a boolean indicating whether the final received signal
%at destination is below outageThreshold
k = log2(M);
bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);
x = x*sqrt(P) / std(x); %scale transmission power to P


n0Dlinear = var(x)/10^(snrD/10);

n0Rlinear = var(x)/10^(snrR/10);

n0Rdb = 10*log10(n0Rlinear);


xSD = filter(channelSD,x);
xSDn = awgn(xSD,snrD,'measured');

xSR = filter(channelSR,x);
xSRn = awgn(xSR,snrR,'measured');

%AMPLIFY APPROPRIATELY
hmag = channelSR.PathGains' .* channelSR.PathGains.';
beta = sqrt(P ./ (hmag' * P + n0Rlinear^2))';
xSRnEq = xSRn ./ channelSR.PathGains.';
xSRnEq = beta.*xSRnEq;
xRD = filter(channelRD,xSRnEq);
xRDn = awgn(xRD,snrD,'measured');

%equalize
xSDnEq = xSDn ./ channelSD.PathGains.';
xRDnEq = xRDn ./ channelRD.PathGains.';
xSDnEq = sqrt(P)*xSDnEq/std(xSDnEq);
xRDnEq = sqrt(P)*xRDnEq/std(xRDnEq);


[xMRC] = maximalRatioCombine(xSDnEq,xRDnEq,channelSD.PathGains,channelRD.PathGains,n0Dlinear,n0Rlinear+n0Dlinear);
xMRC = xMRC / std(xMRC);
%nMRC = xMRC - x;
%measuredSnrD = 10*log10(var(x)/var(nMRC));  
%measuredSnrD = 10*log10(std(xMRC)/n0Dlinear);
%isoutage = measuredSnrD < outageBitThreshold;

%  scatterplot(xMRC);
%  scatterplot(xSDnEq);
%  scatterplot(xRDnEq);
ynAandF = qamdemod(xMRC,M,0,'gray');
ynAandF = de2bi(ynAandF,'left-msb')';

ynDirect = qamdemod(xSDnEq,M,0,'gray');
ynDirect = de2bi(ynDirect,'left-msb')';

[numerrAandF,~] = biterr(bits,ynAandF);
[numerrDirect,~] = biterr(bits,ynDirect);


isoutage = numerrDirect >= outageBitThreshold;
rate = R;
if isoutage
    isoutage = numerrAandF >= outageBitThreshold;
    rate = R/2;
end

end

