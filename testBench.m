clc, clear, close all;

numbits = 1024;
numtrials = 1E3;
M = 2;
k = log2(M);
P = 10; % max power allowable by transmitters
snrD = 0:1:10;
snrR = snrD; %only analyzing symmetric networks


r = 50; % bits/s
W = 100; % Hz , guessing
R = k*(2*r)/W;
outageBitThreshold = numbits*0.005; %dB. SNR at receiver below which we consider receipt an "outage"


symbolPeriod = 1E-2;
coherenceTime = 1; %should be much greater than symbol period for slow fading
dopplerShift = 1/coherenceTime; 


outageResults = struct(...
    'direct',      zeros(1,length(snrD)),...
    'amplify',     zeros(1,length(snrD)),...
    'decode',      zeros(1,length(snrD)),...
    'selection',   zeros(1,length(snrD)),...
    'incremental', zeros(1,length(snrD))...
);

bigR = struct(...
    'direct',      zeros(1,length(snrD)),...
    'amplify',     zeros(1,length(snrD)),...
    'decode',      zeros(1,length(snrD)),...
    'selection',   zeros(1,length(snrD)),...
    'incremental', zeros(1,length(snrD))...
);

snrDnorm = struct(...
    'direct',      zeros(1,length(snrD)),...
    'amplify',     zeros(1,length(snrD)),...
    'decode',      zeros(1,length(snrD)),...
    'selection',   zeros(1,length(snrD)),...
    'incremental', zeros(1,length(snrD))...
);

channelSD = rayleighchan(symbolPeriod,dopplerShift);
channelSD.StorePathGains = true;
channelSR = rayleighchan(symbolPeriod,dopplerShift);
channelSR.StorePathGains = true;
channelRD = rayleighchan(symbolPeriod,dopplerShift);
channelRD.StorePathGains = true;


tic;        
h = waitbar(0,'wait!');
for ii = 1:length(snrD)
    for jj = 1:numtrials
   
        dirResult  = directTransmission(snrD(ii),P,M,numbits,channelSD,outageBitThreshold);
        ampResult = amplifyAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold);
        decResult = decodeAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold);
        [secResult,secRate] = selectionDecodeAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold,R);
        [incResult,incRate] = incrementalAmplifyAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageBitThreshold,R);
        
        outageResults.direct(ii) = outageResults.direct(ii) + dirResult;
        outageResults.amplify(ii) = outageResults.amplify(ii) + ampResult;
        outageResults.decode(ii) = outageResults.decode(ii) + decResult;
        outageResults.selection(ii) = outageResults.selection(ii) + secResult;
        outageResults.incremental(ii) = outageResults.incremental(ii) + incResult;
        
        bigR.selection(ii) = secRate + bigR.selection(ii);
        bigR.incremental(ii) = incRate + bigR.incremental(ii);
        
        
    end
    bigR.direct(ii) = R;
    bigR.amplify(ii) = R/2;
    bigR.decode(ii) = R/2;
    bigR.selection(ii) = bigR.selection(ii)/numtrials;
    bigR.incremental(ii) = bigR.incremental(ii)/numtrials;
    snrDnorm.direct(ii) = snrD(ii) - 10*log10(2^bigR.direct(ii)-1);
    snrDnorm.amplify(ii) = snrD(ii) - 10*log10(2^bigR.amplify(ii)-1);
    snrDnorm.decode(ii) = snrD(ii) - 10*log10(2^bigR.decode(ii)-1);
    snrDnorm.selection(ii) = snrD(ii) - 10*log10(2^bigR.selection(ii)-1);
    snrDnorm.incremental(ii) = snrD(ii) - 10*log10(2^bigR.incremental(ii)-1);
    
    waitbar(ii/length(snrD));
    
    timeest = (toc * length(snrD)) / ii - toc;
    disp(['ii = ' int2str(ii) ' - Seconds Left : ' num2str(timeest) ' - Minutes Left : ' num2str(timeest/60)]);
end
close(h);


figure;
semilogy(snrDnorm.amplify,outageResults.amplify/numtrials,'rs-');hold on;
semilogy(snrDnorm.direct,outageResults.direct/numtrials,'b*-');
semilogy(snrDnorm.decode,outageResults.decode/numtrials,'kx-');
semilogy(snrDnorm.selection,outageResults.selection/numtrials,'go-');
semilogy(snrDnorm.incremental,outageResults.incremental/numtrials,'md-');

hold off;
legend('amplify and forward','direct transmission','decode and forward','selection decode and forward','incremental amplify and forward');




