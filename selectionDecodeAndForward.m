function [ isoutage,rate ] = selectionDecodeAndForward( snrD,snrR,P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold,R )
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

SELECTION_THRESHOLD = 0.7;

n0Dlinear = var(x)/10^(snrD/10);

n0Rlinear = var(x)/10^(snrR/10);

n0Rdb = 10*log10(n0Rlinear);


xSD = filter(channelSD,x);
xSDn = awgn(xSD,snrD,'measured');

xSR = filter(channelSR,x);
xSRn = awgn(xSR,snrR,'measured');



yn = qamdemod(xSDn,M,0,'gray');
yn = de2bi(yn,'left-msb')';
rate = R;

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
if (isoutage)    
    %DECODE AND FORWARD
    xSRnEq = xSRn ./ channelSR.PathGains.';
    xSRdecoded = qamdemod(xSRnEq,M,0,'gray');
    xSRdecoded = de2bi(xSRdecoded,'left-msb')';
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


    [xMRC] = maximalRatioCombine(xSDnEq,xRDnEq,channelSD.PathGains,channelRD.PathGains,n0Dlinear,n0Dlinear + n0Rlinear);
    xMRC = xMRC / std(xMRC);
    yn = qamdemod(xMRC,M,0,'gray');
    yn = de2bi(yn,'left-msb')';
    
    rate = R/2;
<<<<<<< HEAD
    [numerr,ratioerr] = biterr(bits,yn);
=======
else
    xSDnEq = xSDn ./ channelSD.PathGains.';
    yn = qamdemod(xSDnEq,M,0,'gray');
    yn = de2bi(yn,'left-msb')';
    
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
>>>>>>> 3b06f72e20ab4bb9f32c930b85f138d5316329db

    isoutage = numerr >= outageBitThreshold;
end
end

