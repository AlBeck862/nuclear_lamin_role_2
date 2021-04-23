function colVector = cascadingColours(num_slices)
% CASCADINGCOLOURS Create a vector of sequential colours based on the
% number of time points (slices) contained within a given image stack.

colVector = zeros(num_slices,3);
colStep = floor(255/num_slices);

colVector(1,:) = [0 255 255];

for c = 1:num_slices-1
    colVector(c+1,:) = [0 255-(c*colStep) 255];
end

% Normalize for compatibility with the plot function
colVector = colVector/255;

end