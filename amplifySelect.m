function [ isoutage ] = amplifySelect( snrD,snrR,P,M,numbits,channelSD,channelSR,channelRD,outageThreshold )
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
x = x*P / std(x); %scale transmission power to P


n0Dlinear = std(x)/10^(snrD/10);

n0Rlinear = std(x)/10^(snrR/10);

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


xMRC = maximalRatioCombine(xSDnEq,xRDnEq,channelSD.PathGains,channelRD.PathGains,n0Dlinear);

measuredSnrD = 10*log10(std(xMRC)/n0Dlinear);
isoutage = measuredSnrD < outageThreshold;

% scatterplot(xMRC);
% scatterplot(xSDnEq);
% scatterplot(xRDnEq);
%yn = qamdemod(xMRC,M,0,'gray');
%yn = de2bi(yn,'left-msb')';

%[numerr,ratioerr] = biterr(bits,yn);

end
