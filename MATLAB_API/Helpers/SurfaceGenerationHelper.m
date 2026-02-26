classdef SurfaceGenerationHelper
    methods(Static)
        function vaseSurface = Vase(vase, meshGridSize, units)
            center = (meshGridSize/2)*units;
            vaseCenter = vase.Length/2;

            widthFactor  = (vase.Width /vase.SecondInteriorSlitPoint(2))/2;


            % Estimates 3rd order polinomy that defines the center of the vase.
            vasePoints = [0, vase.NozzleHeight;vase.FirstInteriorSlitPoint;vase.SecondInteriorSlitPoint;...
                [vase.Length, vase.ExteriorSlitHeight]];

            f = fit(vasePoints(:,1), vasePoints(:,2), 'poly3');

            % Generates vase surface
            pCoeff = [f.p1, f.p2, f.p3, f.p4];
            polinomy = @(x,pCoeff)(pCoeff(1)*(x.^3)) + (pCoeff(2)*(x.^2)) + (pCoeff(3)*(x.^1)) + (pCoeff(4)*(x.^0));

            vaseEq = @(x, y) sqrt((polinomy(x, pCoeff).^2) - (((y-center(2))/widthFactor).^2));

            [X,Y] = meshgrid(((0:meshGridSize(1)-1)*units)-(center(1)-vaseCenter), (0:meshGridSize(2)-1)*units);

            Z= real(vaseEq(X, Y));

            % Clean mesh outside vase boundaries
            vaseCenterPixels = round(vaseCenter/units);
            pixelsCenter = meshGridSize/2;
            widthVasePixels = round((vase.Width/units)/2);

            Z(:, 1:pixelsCenter(1)-vaseCenterPixels)=0;
            Z(:, pixelsCenter(1)+vaseCenterPixels:meshGridSize(1))=0;
            Z(1:pixelsCenter(2)-widthVasePixels, :)=0;
            Z(pixelsCenter(2)+widthVasePixels:meshGridSize(2), :)=0;

            vaseSurface= Z;

        end

        function semiSphere = SemiSphere(r, heightOffset, meshGridSize, units)

            [X,Y] = meshgrid((0:meshGridSize(1)-1)*units, (0:meshGridSize(2)-1)*units);

            center = (meshGridSize/2)*units;

            Z= real(sqrt((r^2) - ((X-center).^2) - ((Y-center).^2)) + heightOffset);

            Z(Z==heightOffset) = 0;

            semiSphere = Z;

        end
    end
end