function [phaseDistribution, Z] = GetPhaseNSteps(images)

[~,~,nImages] = size(images);

c        = (2/nImages)*exp(-1i*(0:nImages-1)*2*pi/nImages);
h        = zeros(1,1,nImages);
h(1,1,:) = c;

Z = sum(images.*h,3);
phaseDistribution = angle(Z);

end