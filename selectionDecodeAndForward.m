function [ isoutage,rate ] = selectionDecodeAndForward( bits,x,xSDn,xSRn,snrD,snrR,P,M,channelSD,channelSR,channelRD,outageBitThreshold,R )
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
SELECTION_THRESHOLD = 0.05;

n0Dlinear = var(x)/10^(snrD/10);

n0Rlinear = var(x)/10^(snrR/10);


if ~any(abs(channelSR.PathGains) < SELECTION_THRESHOLD)    
    %DECODE AND FORWARD
    xSRnEq = xSRn ./ channelSR.PathGains.';
    xSRdecoded = qamdemod(xSRnEq,M,0,'gray');
    xSRdecoded = reshape(de2bi(xSRdecoded,'left-msb')',1,length(bits));
    xSRdecoded = bi2de(reshape(xSRdecoded,k,size(xSRdecoded,2)/k).','left-msb')';
    xforward = qammod(xSRdecoded,M);
    xforward = xforward*sqrt(P)/ std(xforward); %scale transmission power to P
    xRD = filter(channelRD,xforward);
    xRDn = awgn(xRD,snrD,'measured');
    
    %equalize
    xSDnEq = xSDn ./ channelSD.PathGains.';
    xRDnEq = xRDn ./ channelRD.PathGains.';
    xSDnEq = sqrt(P)*xSDnEq/std(xSDnEq);
    xRDnEq = sqrt(P)*xRDnEq/std(xRDnEq);


    [xMRC] = maximalRatioCombine(xSDnEq,xRDnEq,channelSD.PathGains,channelRD.PathGains,n0Dlinear,n0Rlinear);
    xMRC = xMRC / std(xMRC);
    yn = qamdemod(xMRC,M,0,'gray');
    yn = reshape(de2bi(yn,'left-msb')',1,length(bits));
    
    rate = R/2;
else
    xSDnEq = xSDn ./ channelSD.PathGains.';
    yn = qamdemod(xSDnEq,M,0,'gray');
    yn = reshape(de2bi(yn,'left-msb')',1,length(bits));
    
    rate = R;
end
    
    %DIRECT
%nMRC = xMRC - x;
%measuredSnrD = 10*log10(var(x)/var(nMRC));  
%measuredSnrD = 10*log10(std(xMRC)/n0Dlinear);
%isoutage = measuredSnrD < outageBitThreshold;

%  scatterplot(xMRC);
%  scatterplot(xSDnEq);
%  scatterplot(xRDnEq);


[numerr,ratioerr] = biterr(bits,yn);

isoutage = numerr >= outageBitThreshold;
end

