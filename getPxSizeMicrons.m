function pxSizeMicrons = getPxSizeMicrons(outlinedImageName)
% GETPXSIZEMICRONS Take outlined image name, find corresponding 
% non-outlined image, retrieve pixel size data in microns.
% Return that micron-unit pixel size.

% Remove "outlined_" from the image name
imageName = erase(outlinedImageName,'outlined_');

% Load the non-outlined image's information
im_info = imfinfo([pwd strcat(['/source/' imageName])]);

% Retrieve XResolution and YResolution (pixels per micron)
pxPerMicronX = im_info(1).XResolution;
pxPerMicronY = im_info(1).YResolution;

% Check if the resolution values are in microns, otherwise, raise an error
fullDescription = im_info(1).ImageDescription;
if ~contains(lower(fullDescription),'micron')
    error('The pixel unit must be microns.')
end

% Compare XResolution and YResolution as a failsafe --> if they agree, return 1/(XResolution) (microns per pixel --> pixel size in microns)
if pxPerMicronX==pxPerMicronY
    pxSizeMicrons = 1/pxPerMicronX;
else
    error('Pixels must be square.')
end

end