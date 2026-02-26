% MATLAB current environment cleaning.
clc;
clear;
close all;

% Current file path
filepath = fileparts(mfilename('fullpath'));

% Adds the needed functions to the matlab path
run ([filepath '\MATLAB_API\MATLAB_APIMain.m'])

% Loads the system pixel size
experimentalSystem = load([[filepath, '\CalibrationFiles\'],'tmnPxlMatlab.mat']);

% Surface size definition
nrows = 500;
ncols = 500;

% Generates test surface
surface = SurfaceGenerationHelper.Vase(Vase(), [nrows, ncols], experimentalSystem.tmnPxlMatlab);

x = 0:experimentalSystem.tmnPxlMatlab:(nrows-1)*experimentalSystem.tmnPxlMatlab;
ShowThreeDimensionalMap(x, surface);


%RMSE as a function of the variance of noise added to the simulated patterns, for 8- and 12-step PSA utilizing
% composite fringe patterns with different temporal frequencies.
fringePitch = 36;
steps = [8, 12];
noise = 0:8;
RMSEW0 =zeros(9,5);
b0 = 0.5; % fringeModulation
w1 = [2 3 4];
for i=1:9
    RMSEW0(i,:) = [...
        GetErrorCompositePatterns(fringePitch, steps(1), noise(i), surface,b0,w1(1)),...
        GetErrorCompositePatterns(fringePitch, steps(1), noise(i), surface,b0,w1(2)),...
        GetErrorCompositePatterns(fringePitch, steps(2), noise(i), surface,b0,w1(1)),...
        GetErrorCompositePatterns(fringePitch, steps(2), noise(i), surface,b0,w1(2)),...
        GetErrorCompositePatterns(fringePitch, steps(2), noise(i), surface,b0,w1(3))];
end

noiseVar = ((((noise)/100).^2)/6);
PlotErrors(noiseVar, RMSEW0, "Normalized noise variance $\sigma^2$",'southeast', true);
xlim([0 noiseVar(9)])

% RMSE as a function of the fringe modulation b0 in simulated composite fringe patterns for 8- and 12-step PSA. 
% Utilizing composite fringe patterns with different temporal frequencies and added noise variance
RMSEC =zeros(9,5, 3);
b0 = (5:.5:9)/10;
noise = [2,4,6];
positions = ["northeast","north","north"];
for x=1:3
    for i=1:9
        RMSEC(i,:, x) = [...
            GetErrorCompositePatterns(fringePitch, steps(1), noise(x), surface,b0(i),w1(1)),...
            GetErrorCompositePatterns(fringePitch, steps(1), noise(x), surface,b0(i),w1(2)),...
            GetErrorCompositePatterns(fringePitch, steps(2), noise(x), surface,b0(i),w1(1)),...
            GetErrorCompositePatterns(fringePitch, steps(2), noise(x), surface,b0(i),w1(2)),...
            GetErrorCompositePatterns(fringePitch, steps(2), noise(x), surface,b0(i),w1(3))];
    end
    PlotErrors(b0/2, RMSEC(:,:, x), "Fringe modulation $b_0$", positions(x), false);
end


% RMSE as a function of the variance of noise added to the simulated patterns, for n-step PSA utilizing high-
% and low-frequency patterns and composite patterns with a temporal frequency of ω1 = 2ω0 and fringe modulation b0
% of 0.35, 0.4, and 0.45.
RMSE =zeros(9,5);
steps = [8; 4;6;8;12];
b0 = [.7,.8,.9];
noise = 0:8;
noiseVar = ((((noise)/100).^2)/6);
for x=1:3
    for i=1:9
        RMSE(i,:) =[...
            GetErrorCompositePatterns(fringePitch, steps(1), noise(i), surface, b0(x), w1(1)),...
            GetErrorDualFreqPatterns(fringePitch, steps(2), noise(i), surface),...
            GetErrorDualFreqPatterns(fringePitch, steps(3), noise(i), surface),...
            GetErrorDualFreqPatterns(fringePitch, steps(4), noise(i), surface),...
            GetErrorDualFreqPatterns(fringePitch, steps(5), noise(i), surface),...
            GetErrorCompositePatterns(fringePitch, steps(5), noise(i), surface, b0(x), w1(1))];
    end
    PlotErrors(noiseVar, RMSE,"Normalized noise variance $\sigma^2$",'northwest', true);
    legend({'8-Step PSA Composite','4-Step PSA Dual-Freq','6-Step PSA Dual-Freq','8-Step PSA Dual-Freq','12-Step PSA Dual-Freq','12-Step PSA Composite'})
    ylim([0,.14])
    xlim([0 noiseVar(9)])
end


function error = GetErrorDualFreqPatterns(period, stepNumber, noisePercent, object)

% Fringe patterns parameters definition
[nrows, ncols] = size(object);
capturedPhases=2;

G = 6;

cameraVerticalResolution = 1280;

lowFreq = cameraVerticalResolution/(period*G);

lowFreqCarrier = ((0:2*pi/1280:(2*pi - (2*pi/1280)))*lowFreq);
lowFreqCarrier = -ones(ncols, 1)* lowFreqCarrier(1:nrows);

step = (2*pi)/stepNumber;
phaseShifts = 0:step:(2*pi)-step;

incDegree = 18.3;
variance= ((noisePercent/100).^2)/6;

% Patterns generation
planeHighFreq = zeros(nrows, ncols, stepNumber);
objectHighFreq = planeHighFreq;
planeLowFreq = planeHighFreq;
objectLowFreq = planeHighFreq;

for i=1:stepNumber
    planeHighFreq(:,:,i) = (.5 + (.5*cos((G*lowFreqCarrier) + phaseShifts(i))));
    objectHighFreq(:,:,i) = (.5 + (.5*cos((G*lowFreqCarrier) + (G*(1/lowFreq)*tand(incDegree)*object) + phaseShifts(i))));

    planeLowFreq(:,:,i) = (.5 + (.5*cos(lowFreqCarrier + phaseShifts(i))));
    objectLowFreq(:,:,i) = (.5 + (.5*cos(lowFreqCarrier + ((1/lowFreq)*tand(incDegree)*object) + phaseShifts(i))));

    if(variance==0), continue; end

    planeHighFreq(:,:,i) = imnoise(planeHighFreq(:,:,i), "gaussian", 0, variance);
    objectHighFreq(:,:,i) = imnoise(objectHighFreq(:,:,i), "gaussian", 0, variance);

    planeLowFreq(:,:,i) = imnoise(planeLowFreq(:,:,i), "gaussian", 0, variance);
    objectLowFreq(:,:,i) = imnoise(objectLowFreq(:,:,i), "gaussian", 0, variance);
end

imagesHighFreq = cat(3, planeHighFreq, objectHighFreq);
imagesLowFreq = cat(3, planeLowFreq, objectLowFreq);

% Phase retrieval
phases = zeros(nrows, ncols, capturedPhases);
phasesZLow = phases;
phasesZHigh = phases;

W = @(x) angle(exp(1i*x));
imagesIndex = zeros(capturedPhases,1);
for i = 1: capturedPhases
    imageIndex = (stepNumber*(i-1))+1;
    imagesIndex(i) = imageIndex;

    images = imagesHighFreq(:,:,imageIndex:imageIndex+stepNumber-1);
    [~, zHighFreq] = GetPhaseNSteps(images);

    images = imagesLowFreq(:,:,imageIndex:imageIndex+stepNumber-1);
    [~, zLowFreq] = GetPhaseNSteps(images);

    phasesZLow(:,:,i) = zLowFreq;
    phasesZHigh(:,:,i) = zHighFreq;

    if(i ==1)
        continue
    end

    zHighFreq = zHighFreq.* exp(-1i*angle(phasesZHigh(:,:,1)));
    zLowFreq = zLowFreq.* exp(-1i*angle(phasesZLow(:,:,1)));
    Phi1 = angle(zLowFreq);
    PhiG = angle(zHighFreq);

    phases(:,:,i) = G*Phi1 + W(PhiG - G*Phi1);

end

K = 1/((1/lowFreq)*G*tand(incDegree));
phaseCalibrationDouble = phases(:,:,i)*K;

% Error calculation between the retrieved phase and the ideal object
error = sqrt(sum(sum((object- phaseCalibrationDouble).^2))/(nrows*ncols));

end

function error = GetErrorCompositePatterns(period, stepNumber, noisePercent, object, b0, w0)

% Fringe patterns parameters definition

G = 6;

cameraVerticalResolution = 1280;

[nrows, ncols] = size(object);
capturedPhases=2;

lowFreq = cameraVerticalResolution/(period*G);

lowFreqCarrier = ((0:2*pi/1280:(2*pi - (2*pi/1280)))*lowFreq);
lowFreqCarrier = -ones(ncols, 1)* lowFreqCarrier(1:nrows);

step = (2*pi)/stepNumber;
phaseShifts = 0:step:(2*pi)-step;

b1 =1-b0;
incDegree = 18.3;

variance= ((noisePercent/100).^2)/6;

% Patterns generation
planeComposite = zeros(nrows, ncols, stepNumber);
objectComposite = planeComposite;

for i=1:stepNumber
    planeComposite(:,:,i) = (.5 + ((.5*b0)*cos((G*lowFreqCarrier) + phaseShifts(i)))+...
        ((.5*b1)*cos(lowFreqCarrier + (w0*phaseShifts(i)))));

    objectComposite(:,:,i) = (.5 + ((.5*b0)*cos((G*lowFreqCarrier) + (G*(1/lowFreq)*tand(incDegree)*object) + phaseShifts(i)))...
        +((.5*b1)*cos(lowFreqCarrier + ((1/lowFreq)*tand(incDegree)*object) + (w0*phaseShifts(i)))));

    if(variance==0), continue; end

    planeComposite(:,:,i) = imnoise(planeComposite(:,:,i), "gaussian", 0, variance);
    objectComposite(:,:,i) = imnoise(objectComposite(:,:,i), "gaussian", 0, variance);
end

compositeImages =cat(3, planeComposite, objectComposite);

phases = zeros(nrows, ncols, capturedPhases);
phasesZLow = phases;
phasesZHigh = phases;


% Phase retrieval
W = @(x) angle(exp(1i*x));
imagesIndex = zeros(capturedPhases,1);

for i = 1: capturedPhases
    imageIndex = (stepNumber*(i-1))+1;
    imagesIndex(i) = imageIndex;

    images = compositeImages(:,:,imageIndex:imageIndex+stepNumber-1);

    [~, zHighFreq] = GetPhaseNSteps(images);

    [~, zLowFreq] = GetPhaseNStepsKW0(images, w0);

    if(i ==1)
        phasesZLow(:,:,i) = zLowFreq;
        phasesZHigh(:,:,i) = zHighFreq;
        continue
    end

    phasesZHigh(:,:,i) = zHighFreq.* exp(-1i*angle(phasesZHigh(:,:,1)));
    phasesZLow(:,:,i) = zLowFreq.* exp(-1i*angle(phasesZLow(:,:,1)));

    Phi1 = angle(phasesZLow(:,:,i));
    PhiG = angle(phasesZHigh(:,:,i));

    phases(:,:,i) = G*Phi1 + W(PhiG - G*Phi1);

end
K = 1/((1/lowFreq)*G*tand(incDegree));
phaseCalibrationComposite = phases(:,:,i)*K;

% Error calculation between the retrieved phase and the ideal object
error = sqrt(sum(sum((object- phaseCalibrationComposite).^2))/(nrows*ncols));

end