classdef ImageHelper
    methods(Static)
        function SaveImages(images, extension, directoryPath)
            %TODO mandar imagenes en vez de arreglos soluciona muchos de los problemas
            % de manipulacion
            [~,~, nChannels, nImages] = size(images);
            
            
            for i = 1 : nImages
                imagePath = strcat(directoryPath, string(i), extension);
                imwrite(uint8(images(:,:,:,i)),imagePath);
            end

        end

        function [images, nImages, nChannels] = LoadImages(directoryPath, extension)
            [imageFilesPath, nImages] = FilesHelper.GetFolderFullFileNames(directoryPath, extension);

            image = imread(imageFilesPath(1));

            [nRows, nCols, nChannels] = size(image);

            images = zeros (nRows,nCols,nChannels,nImages);
            images(:,:,:,1) = image;

            for i = 2: nImages
                image1 = imread(imageFilesPath(i));
                images(:,:,:,i) = image1;
            end
            images = squeeze(images);
        end

        function images = RemoveImagesDoubleDistortion(images, correctionParameters, nImages, nChannels)
            images = ImageHelper.RemoveImagesDistortion(images, correctionParameters.CameraParameters, nImages, nChannels);

            images = ImageHelper.RemoveImagesDistortion(images, correctionParameters.ProjectorParameters, nImages, nChannels);
        end

        function images = RemoveImagesDistortion(images, cameraParameters, nImages, nChannels)
            for i =1 : nImages
                if(nChannels==1)
                    images(:,:,i) = undistortImage(images(:,:,i),cameraParameters);
                    continue;
                end
                images(:,:,:,i) = undistortImage(images(:,:,:,i),cameraParameters);
            end
        end

        function [images, nImages] = LoadUndistortedImages(directoryPath, extension, cameraParameters)
            [images, nImages] = ImageHelper.LoadImages(directoryPath, extension);

            images = ImageHelper.RemoveImagesDistortion(images, cameraParameters, nImages, 3);
        end

        function images = LoadChannelUndistortedImages(directoryPath, extension, cameraParameters, nChannel)
            [images1, nImages] = ImageHelper.LoadImages(directoryPath, extension);
            images = ImageHelper.RemoveImagesDistortion(squeeze(images1(:,:,nChannel,:)), cameraParameters, nImages, 1);
        end

        function imagesConverted = ConvertImages2BW(images)
            imagesConverted = squeeze(sum(double(images(:,:,:,:)), 3)/3);
        end

        function [images, nImages] = LoadImagesBW(directoryPath, extension)
            [images, nImages] = ImageHelper.LoadImages(directoryPath, extension);

            images = ImageHelper.ConvertImages2BW(images);
        end

        function [images, nImages] = LoadChannelImages(directoryPath, extension, channel)
            [images, nImages] = ImageHelper.LoadImages(directoryPath, extension);

            images = squeeze(images(:,:,uint8(channel),:));
        end

        function [images, nImages] = LoadUndistortedImagesBW(directoryPath, extension, cameraParameters)
            [images, nImages] = ImageHelper.LoadImagesBW(directoryPath, extension);
            images = ImageHelper.RemoveImagesDistortion(images, cameraParameters, nImages, 1);
        end

        function images = ConvertImages2OneColoredChannel(images, nChannel)
            [nRows, nCols, nChannels, nImages] = size(images);

            if(nImages == 1)
                nImages = nChannels;
            else
                images = ImageHelper.ConvertImages2BW(images);
            end

            channel = zeros(nRows, nCols, nImages);

            switch nChannel
                case 1
                    images = ImageHelper.ConvertImages2Rgb(images, channel, channel);
                case 2
                    images = ImageHelper.ConvertImages2Rgb(channel, images, channel);
                case 3
                    images = ImageHelper.ConvertImages2Rgb(channel, channel, images);
            end
        end

        function images = ConvertImages2Rgb(imagesR, imagesG, imagesB)
            [nRows, nCols, nImages] = size(imagesR);

            images = zeros(nRows, nCols, 3, nImages);

            for i =1 : nImages
                images(:,:,1,i) = imagesR(:,:,i);
                images(:,:,2,i) = imagesG(:,:,i);
                images(:,:,3,i) = imagesB(:,:,i);
            end
        end
    end
end