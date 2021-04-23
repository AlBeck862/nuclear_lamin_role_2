% Based on the area calculation tutorial via: https://www.mathworks.com/help/images/identifying-round-objects.html

% Remove whitespace around the subsequently-defined figures
iptsetpref('ImshowBorder','tight');

% Check for all tif files in the source folder
files = dir([pwd '/source/*.tif']);
N = length(files);

% Loop over every tif file in the source folder
for i = 1:N
    % Get the number of slices in the image file
    im_info = imfinfo([pwd strcat(['/source/' files(i).name])]);
    num_slices = size(im_info);
    num_slices = num_slices(1);
    
    % Loop over all slices in the image file
    for j = 1:num_slices
        % Initialize a new figure for each imported slice
        figure(str2double(strcat([num2str(i) num2str(j)]))) %ensure a meaninful and unique number for each figure ('ij')
        image = imread([pwd strcat(['/source/' files(i).name])],j);
        
        % Decrement by 1 everywhere that isn't zero (necessary for thresholding later)
        idx = image~=0; %get indices that aren't zero
        image = image - cast(idx,'uint8'); %decrement by 1 at those indices (idx is 1 at the relevant indices)
        
        % Convert the image to black and white after converting to grayscale (if not already grayscale)
        try
            I = rgb2gray(image);
            bw = imbinarize(I);
        catch
            bw = imbinarize(image);
        end
        imshow(bw)

        % Define objects as having a very large neighbourhood and fill accordingly
        se = strel('disk',6); %USUALLY SET TO 6
        bw = imclose(bw,se);
        imshow(bw)

        % Fill any remaining holes
        bw = imfill(bw,'holes');
        imshow(bw)

        % Concentrate only on the exterior boundaries. Option 'noholes' prevents bwboundaries from searching for inner contours.
        [B,L] = bwboundaries(bw,'noholes');

        % Skip empty images (no nucleus boundary drawn)
        if isempty(B)
            continue
        end
        
        % Display the label matrix and draw each boundary
        imshow(label2rgb(L,@jet,[.5 .5 .5]))
        
        
        % Generate the boundary image
        imshow(image)
        hold on
        for k = 1:length(B)
          boundary = B{k};
          plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
        end
        
        % Save the figure as shown as a tif image file (tif files will be stacks, as imported)
        set(gcf,'InvertHardCopy','off')
        imwrite(getframe(gcf).cdata,[pwd strcat(['/outlined/outlined_' files(i).name])],'writemode','append') %save to the outlined folder
    end
end

% Close all figure windows
close all