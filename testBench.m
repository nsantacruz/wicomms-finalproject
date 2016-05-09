clc, clear, close all;

numbits = 1024;
numtrials = 1E4;
M = 2;

P = 10; % max power allowable by transmitters
snrD = 0:2:15;
snrR = snrD; %only analyzing symmetric networks


r = 50; % bits/s
W = 100; % Hz , guessing
R = (2*r)/W;
outageThreshold = 5; %dB. SNR at receiver below which we consider receipt an "outage"
snrDnorm = 10.^(snrD/10) / (2^R-1); %CONVERT SNR TO LINEAR!!!!

symbolPeriod = 1E-4;
coherenceTime = 10; %should be much greater than symbol period for slow fading
dopplerShift = 1/coherenceTime; 


outageResults = struct(...
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
   
        dirResult = directTransmission(snrD(ii),P,M,numbits,channelSD,outageThreshold);
        ampResult = amplifyAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageThreshold);
        decResult = decodeAndForward(snrD(ii),snrR(ii),P,M,numbits,channelSD,channelSR,channelRD,outageThreshold);
        
        outageResults.direct(ii) = outageResults.direct(ii) + dirResult;
        outageResults.amplify(ii) = outageResults.amplify(ii) + ampResult;
        outageResults.decode(ii) = outageResults.decode(ii) + decResult;
    end
    waitbar(ii/length(snrD));
    
    timeest = (toc * length(snrD)) / ii - toc;
    disp(['ii = ' int2str(ii) ' - Seconds Left : ' num2str(timeest) ' - Minutes Left : ' num2str(timeest/60)]);
end
close(h);

figure;
semilogy(snrD,outageResults.amplify/numtrials);hold on;
semilogy(snrD,outageResults.direct/numtrials);
semilogy(snrD,outageResults.decode/numtrials);
hold off;
legend('amplify and forward','direct transmission','decode and forward');




