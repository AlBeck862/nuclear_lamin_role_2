% Based on the area calculation tutorial via: https://www.mathworks.com/help/images/identifying-round-objects.html

files = dir([pwd '/source/*.png']);
N = length(files);

for i = 1:N
    filename = files(i).name;
    image = imread([pwd strcat(['/source/' filename])]);

    imshow(image)

    % Convert the image to black and white in order to prepare for boundary tracing using bwboundaries
    I = rgb2gray(image);
    bw = imbinarize(I);
    imshow(bw)
   
    % Fill a gap in the pen's cap --> probably not necessary for nuclear membrane detection
    se = strel('disk',4);
    bw = imclose(bw,se);
    imshow(bw)

    % Fill any holes, so that regionprops can be used to estimate the area enclosed by each of the boundaries
    bw = imfill(bw,'holes');
    imshow(bw)

    % Concentrate only on the exterior boundaries. Option 'noholes' will accelerate the processing by preventing bwboundaries from searching for inner contours
    [B,L] = bwboundaries(bw,'noholes');

    % Display the label matrix and draw each boundary
    imshow(label2rgb(L,@jet,[.5 .5 .5]))

    % Remove whitespace around the subsequently-defined figures
    iptsetpref('ImshowBorder','tight');

    figure(i)
    imshow(image)
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
    end
    
    % Save the figure as shown as a PNG image file
    set(gcf,'InvertHardCopy','off')
    saveas(figure(i),[pwd strcat(['/outlined/' 'outlined_' filename])])
end


% % This metric is equal to 1 only for a circle and it is less than one for any other shape.
% 
% stats = regionprops(L,'Area','Centroid');
% 
% threshold = 0.94;
% 
% % loop over the boundaries
% for k = 1:length(B)
% 
%   % obtain (X,Y) boundary coordinates corresponding to label 'k'
%   boundary = B{k};
% 
%   % compute a simple estimate of the object's perimeter
%   delta_sq = diff(boundary).^2;    
%   perimeter = sum(sqrt(sum(delta_sq,2)));
%   
%   % obtain the area calculation corresponding to label 'k'
%   area = stats(k).Area;
%   
%   % compute the roundness metric
%   metric = 4*pi*area/perimeter^2;
%   
%   % display the results
%   metric_string = sprintf('%2.2f',metric);
% 
%   % mark objects above the threshold with a black circle
%   if metric > threshold
%     centroid = stats(k).Centroid;
%     plot(centroid(1),centroid(2),'ko');
%   end
%   
%   text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
%        'FontSize',14,'FontWeight','bold')
%   
% end
% 
% title(['Metrics closer to 1 indicate that ',...
%        'the object is approximately round'])