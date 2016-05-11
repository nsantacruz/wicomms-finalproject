function [ isoutage ] = directTransmission( bits,x,xSDn,snrD,P,M,channelSD,outageBitThreshold )
%DIRECTTRANSMISSION - see amplifyAndForward() for docs
%equalize
k = log2(M);
xSDnEq = xSDn ./ channelSD.PathGains.';


%isoutage = measuredSnrD < outageBitThreshold;

% scatterplot(xSDn);
yn = qamdemod(xSDnEq,M,0,'gray');
yn = reshape(de2bi(yn,'left-msb')',1,length(bits));
[numerr,ratioerr] = biterr(bits,yn);
isoutage = numerr >= outageBitThreshold;
end

