% MATLAB current environment cleaning.
clc;
clear;
close all;

% Current file path
filepath = fileparts(mfilename('fullpath'));

% Adds the needed functions to the matlab path
run ([filepath '\MATLAB_API\MATLAB_APIMain.m'])

% Modify depending of the folder, the naming convention is
% AdquiredCompositeAWB, where A, indicates the number of steps(8 or 12), and B indicate the temporal frequency(2, 3, or 4) 
steps = 8;
w1 = 2;

imagesPath = filepath + "\AquiredComposite" + string(steps) + "W" + string(w1) + "\";

[imagesHighFreq, nImages] = ImageHelper.LoadChannelImages(imagesPath,'.png', ColorChannel.Red);

% Loads the system pixel size
load([[filepath, '\CalibrationFiles\'],'tmnPxlMatlab.mat'], 'tmnPxlMatlab');
experimentalSystem.tmnPxlMatlab = tmnPxlMatlab;

% Loads the camera parameters
load([[filepath, '\CalibrationFiles\'],'cameraParameters.mat']);
experimentalSystem.cameraParameters = cameraParameters;

% Loads the phase to height convertion constant
load([[filepath, '\CalibrationFiles\'],'K.mat']);
experimentalSystem.K = K;

% Remove camera lens distortion
imagesHighFreq = ImageHelper.RemoveImagesDistortion(imagesHighFreq, experimentalSystem.cameraParameters, nImages, 1);

capturedPhases = nImages/ steps;

imagesIndex = zeros(capturedPhases,1);
phases = zeros(1024,1280,2);
phasesZLow = zeros(1024,1280,2);
phasesZHigh = zeros(1024,1280,2);

G = 6;
W = @(x) angle(exp(1i*x));

% Retrive the phase 
for i = 1: capturedPhases
    imageIndex = (steps*(i-1))+1;
    imagesIndex(i) = imageIndex;

    images = imagesHighFreq(:,:,imageIndex:imageIndex+steps-1);

    [~, zHighFreq] = GetPhaseNSteps(images);

    [~, zLowFreq] = GetPhaseNStepsKW0(images, w1);

    phasesZLow(:,:,i) = zLowFreq;
    phasesZHigh(:,:,i) = zHighFreq;

    if(i ==1), continue, end

    phasesZHigh(:,:,i) = zHighFreq.* exp(-1i*angle(phasesZHigh(:,:,1)));
    phasesZLow(:,:,i) = zLowFreq.* exp(-1i*angle(phasesZLow(:,:,1)));

    Phi1 = angle(phasesZLow(:,:,i));
    PhiG = angle(phasesZHigh(:,:,i));

    phases(:,:,i) = G*Phi1 + W(PhiG - G*Phi1);

end

% Phase convertion from rads to millimeters 
convertedPhase = experimentalSystem.K.*phases(:,:,i);
convertedPhase(convertedPhase<0) = 0;

load([[userpath, '\APIs\Calibration\'],'tmnPxlMatlab.mat']);

[nrows, ncols] = size(convertedPhase);
x = 0:experimentalSystem.tmnPxlMatlab:(nrows-1)*experimentalSystem.tmnPxlMatlab;
y = 0:experimentalSystem.tmnPxlMatlab:(ncols-1)*experimentalSystem.tmnPxlMatlab;

figure;
subplot(1,2, 1)
imagesc(y, x, convertedPhase);
xlabel('X Axis [mm]')
ylabel('Y Axis [mm]')
c = colorbar;
c.Label.String = 'Height [mm]';
title('Height Map')
daspect([1, 1, 1])


subplot(1,2, 2)
surf(y,x,flip(convertedPhase,1), LineStyle="none")
colormap('gray')
title('Three-dimensional map')
daspect([1, 1, 1])
xlabel('X Axis [mm]')
ylabel('Y Axis [mm]')
xlim([0 y(ncols)]);
ylim([0 x(nrows)]);
daspect([1, 1, 1])