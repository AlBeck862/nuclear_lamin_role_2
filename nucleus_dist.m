% Angle plot (=1) or radius plot (=0)?
angle_plot = 1;

% Get the number of iamge stacks (.tif format)
files = dir([pwd '/outlined/*.tif']);
N = length(files);

% For plotting (radius plots only to eliminate border-related artifacts)
start = 12; %remove the first "start" data points from each image's data
stop = 5; %remove the last "stop" data points from each image's data

% Loop over every tif file in the source folder
for i = 1:N
    clearvars colVector
    
    % Get the number of slices in the image file
    im_info = imfinfo([pwd strcat(['/outlined/' files(i).name])]);
    num_slices = size(im_info);
    num_slices = num_slices(1);
    
    % Colour values to represent the time axis
    colVector = cascadingColours(num_slices);
    
    % Fetch the size of each pixel in microns
    pxSizeMicrons = getPxSizeMicrons(files(i).name);
    
    % For plotting
	figure(i)
    
    % Loop over all slices in the image file
    for j = 1:num_slices
        % Initialize a new figure for each imported slice --> for image visualization
        image = imread([pwd strcat(['/outlined/' files(i).name])],j);
        
        % Isolate the outline only: this works because of the decrement lines in outline_nuclei
        bw = imbinarize(rgb2gray(image),0.99999);

        % Obtain a mask that includes the outline and the inside of the the nucleus
        filled_mask = imfill(bw,'holes');
        
        region_data = regionprops(filled_mask,'area','centroid'); %get information regarding regions
        centroids = cat(1,region_data.Centroid); %get all centroids (x,y pairs)
        areas = cat(1,region_data.Area); %get area of all regions
        centroids = round(centroids(areas==max(areas),:)); %keep only the centroid of the largest region (the nucleus)

        % Distances from each pixel to the nearest boundary pixel
        distances = bwdist(bw);
        
        % Multiply the distances matrix with the mask --> zero out every pixel that lies outside the nucleus
        inside_distances = distances.*filled_mask;
        
        gray_im = rgb2gray(image); %convert the image to grayscale
        im_size = size(gray_im); %get image size (x,y)
        only_nucleus_gray_im = gray_im.*cast(filled_mask,'uint8'); %only keep the nucleus, zero-out all other pixels
        
        avg_line_values = zeros(1,100000); %storage for intensity values along a line
        k = 0;
        y_end_vals_right = 0:im_size(2);
        for y_end_right = y_end_vals_right %cycle through y-values (endpoints of each line) --> right edge of the image
            k = k+1;
            line_values = improfile(only_nucleus_gray_im,[centroids(1),im_size(1)],[centroids(2),y_end_right]); %get the pixel values along a line
            line_values(isnan(line_values))=0; %remove NaN values, if any
            line_values(line_values==255)=0; %remove 255 values (the added border)
            line_values_clean = line_values(find(line_values)); %keep only nonzero values along that line (only within the nucleus)
            avg_line_values(k) = mean(line_values_clean); %calculate the average pixel value for that line and store it for plotting
        end
        
        x_end_vals_top = 0:im_size(1);
        for x_end_top = x_end_vals_top %cycle through x-values (endpoints of each line) --> top edge of the image
            k = k+1;
            line_values = improfile(only_nucleus_gray_im,[centroids(1),x_end_top],[centroids(2),0]); %get the pixel values along a line
            line_values(isnan(line_values))=0; %remove NaN values, if any
            line_values(line_values==255)=0; %remove 255 values (the added border)
            line_values_clean = line_values(find(line_values)); %keep only nonzero values along that line (only within the nucleus)
            avg_line_values(k) = mean(line_values_clean); %calculate the average pixel value for that line and store it for plotting
        end
        
        y_end_vals_left = 0:im_size(2);
        for y_end_left = y_end_vals_left %cycle through y-values (endpoints of each line) --> right edge of the image
            k = k+1;
            line_values = improfile(only_nucleus_gray_im,[centroids(1),0],[centroids(2),y_end_left]); %get the pixel values along a line
            line_values(isnan(line_values))=0; %remove NaN values, if any
            line_values(line_values==255)=0; %remove 255 values (the added border)
            line_values_clean = line_values(find(line_values)); %keep only nonzero values along that line (only within the nucleus)
            avg_line_values(k) = mean(line_values_clean); %calculate the average pixel value for that line and store it for plotting
        end
        
        x_end_vals_bottom = 0:im_size(1);
        for x_end_bottom = x_end_vals_top %cycle through x-values (endpoints of each line) --> top edge of the image
            k = k+1;
            line_values = improfile(only_nucleus_gray_im,[centroids(1),x_end_bottom],[centroids(2),im_size(2)]); %get the pixel values along a line
            line_values(isnan(line_values))=0; %remove NaN values, if any
            line_values(line_values==255)=0; %remove 255 values (the added border)
            line_values_clean = line_values(find(line_values)); %keep only nonzero values along that line (only within the nucleus)
            avg_line_values(k) = mean(line_values_clean); %calculate the average pixel value for that line and store it for plotting
        end
        
        avg_line_values_no_zeros = avg_line_values(find(avg_line_values)); %remove excess indices from the storage vector
        avg_line_values_no_zeros = (avg_line_values_no_zeros-mean(avg_line_values_no_zeros))/std(avg_line_values_no_zeros); %standardize the data
        
        angles_y_right = atan2d(y_end_vals_right-centroids(2),im_size(1)-centroids(1));
        angles_x_top = atan2d(0-centroids(2),x_end_vals_top-centroids(1));
        angles_y_left = atan2d(y_end_vals_left-centroids(2),0-centroids(1));
        angles_x_bottom = atan2d(im_size(2)-centroids(2),x_end_vals_top-centroids(1));
        
        angles = [angles_y_right,angles_x_top,angles_y_left,angles_x_bottom]; %concatenate to form a global angles vector      
        
        % Sort the data for correct plotting
        [angles,idxs] = sort(angles);
        avg_line_values_no_zeros = avg_line_values_no_zeros(idxs);
        
        % Plot the average pixel intensity of each line as a function of the line's angle
        if angle_plot == 1
            plot(angles,avg_line_values_no_zeros,'color',colVector(j,:))
            hold on
        end
        
        vectorized_im = gray_im(:); %convert the image to a 1D vector
        vectorized_dists = inside_distances(:); %convert the distance matrix to a 1D vector
        nonzero_dists = find(vectorized_dists); %indices of nonzero distances
        
        im_data = vectorized_im(nonzero_dists); %keep relevant data points only
        dist_data = round(vectorized_dists(nonzero_dists),0); %keep relevant data points only and round the distances
        unique_dists = unique(dist_data); %unique distances
        
        num = 0;
        for k = unique_dists'
            num = num+1;
            avg_vals(num) = mean(im_data(dist_data==k));
        end
        
        % Convert distances from pixels to microns
        micron_unique_dists = pxSizeMicrons*unique_dists;
        micron_dists = pxSizeMicrons*dist_data;

        % Standardize the data
        avg_vals = (avg_vals-mean(avg_vals))/std(avg_vals);
        
        % Stacked lines with no error bars
        if angle_plot == 0
            plot(micron_unique_dists(start:end-stop),avg_vals(start:end-stop),'color',colVector(j,:))
            hold on
        end
        
        % Necessary for the plot to be displayed
        pause(0.01)
        
        % Empty key variables before loading the next image
        clearvars image bw filled_mask distances inside_distances norm_dist
        clearvars norm_inside_dist gray_im vectorized_im vectorized_dists 
        clearvars nonzero_dists im_data dist_data unique_dists avg_vals err
        clearvars micron_dists micron_unique_dists line_values avg_line_values
        clearvars avg_line_values_no_zeros angles_y_right angles_x_top
        clearvars angles_y_left angles_x_bottom angles idxs y_end_vals_right
        clearvars x_end_vals_top y_end_vals_left x_end_vals_bottom

    end
    
    if angle_plot == 0
        xlabel('Distance From the Nuclear Membrane (Microns)')
        ylabel('Standardized Average Grayscale Pixel Intensity')
        colormap(colVector)
        c = colorbar;
        c.Ticks = [0 1];
        c.TickLabels = {'Start','End'};
    %     xlim([0 round(max_xticks,1)])
    %     ylim([0 255])
        xtickformat('%.1f')
    %     xticks(0:0.5:round(max_xticks,1))
        stackName = erase(files(i).name,'outlined_');
        title_str = strcat(['Lamin Distribution Within the Cell Nucleus as a Function of Radius: ' stackName]);
        title(title_str)
    else
        xlabel('Angle (Degrees)')
        ylabel('Standardized Average Grayscale Pixel Intensity')
        colormap(colVector)
        c = colorbar;
        c.Ticks = [0 1];
        c.TickLabels = {'Start','End'};
        stackName = erase(files(i).name,'outlined_');
        title_str = strcat(['Lamin Distribution Within the Cell Nucleus as a Function of Angle: ' stackName]);
        title(title_str)
    end
    
end