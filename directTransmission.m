function [ isoutage ] = directTransmission( snrD,P,M,numbits,channelSD,outageBitThreshold )
%DIRECTTRANSMISSION - see amplifyAndForward() for docs

k = log2(M);
bits = randi([0,1],1,numbits);
msg = bi2de(reshape(bits,k,size(bits,2)/k).','left-msb')';
x = qammod(msg,M);
x = x*P / std(x); %scale transmission power to P

n0Dlinear = std(x)/10^(snrD/10);

xSD = filter(channelSD,x);
xSDn = awgn(xSD,snrD,'measured');
nSD = xSDn - x;

measuredSnrD = 10*log10(var(x)/var(nSD));
%equalize
xSDnEq = xSDn ./ channelSD.PathGains.';


%isoutage = measuredSnrD < outageBitThreshold;

% scatterplot(xSDn);
yn = qamdemod(xSDnEq,M,0,'gray');
yn = de2bi(yn,'left-msb')';
[numerr,ratioerr] = biterr(bits,yn);
isoutage = numerr >= outageBitThreshold;
end

