function [phaseDistribution, Z] = GetPhaseNStepsKW0(images, K)

[~,~,nImages] = size(images);

phaseShifts = (0:nImages-1)*(((K*2*pi)/nImages));
c        = (2/nImages)*exp(-1i*phaseShifts);
h        = zeros(1,1,nImages);
h(1,1,:) = c;

Z = sum(images.*h,3);
phaseDistribution = angle(Z);

end