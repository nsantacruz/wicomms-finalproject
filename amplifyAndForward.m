function [ isoutage ] = amplifyAndForward( bits,x,xSDn,xSRn,snrD,snrR,P,M,channelSD,channelSR,channelRD,outageBitThreshold )
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
n0Dlinear = var(x)/10^(snrD/10);

n0Rlinear = var(x)/10^(snrR/10);

n0Rdb = 10*log10(n0Rlinear);

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
yn = qamdemod(xMRC,M,0,'gray');
yn = reshape(de2bi(yn,'left-msb')',1,length(bits));

[numerr,ratioerr] = biterr(bits,yn);

isoutage = numerr >= outageBitThreshold;

end

