%tif testing

files = dir([pwd '/source/*.tif']);
N = length(files);

for i = 1:N
    
    % Get the number of slices in the image file
    im_info = imfinfo([pwd strcat(['/source/' files(i).name])]);
    num_slices = size(im_info);
    num_slices = num_slices(1);

    % For each slice, process and save
    for j = 1:num_slices
        im = imread([pwd strcat(['/source/' files(i).name])],j);
        imshow(im)
        imwrite(im,[pwd strcat(['/outlined/outlined_' files(i).name])],'writemode','append')
    end
    
end