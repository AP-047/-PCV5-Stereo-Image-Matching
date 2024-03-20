clear all;
close all;

% Parameters
windowSize = 16; % Try with 11x11 window
searchRange = 48; % Search range of 15 pixels

% Read images
leftImg = imread('left.png');
rightImg = imread('right.png');

% Convert images to double precision
leftImg = im2double(leftImg);
rightImg = im2double(rightImg);

% Initialize disparity map
disparityMap = zeros(size(leftImg));

% Define window's half size
halfWin = floor(windowSize / 2);

% Iterate over each pixel in the left image
for i = 1 + halfWin : size(leftImg, 1) - halfWin
    for j = 1 + halfWin : size(leftImg, 2) - halfWin
        % Extract window from the left image
        leftWindow = leftImg(i - halfWin:i + halfWin, j - halfWin:j + halfWin);

        % Initialize variables for the best match
        bestOffset = 0;
        maxCorr = -Inf;

        % Define search boundaries
        searchStart = max(j - searchRange, 1 + halfWin);
        searchEnd = min(j + searchRange, size(rightImg, 2) - halfWin);

        % Search for the best match in the right image
        for k = searchStart:searchEnd
            % Extract window from the right image
            rightWindow = rightImg(i - halfWin:i + halfWin, k - halfWin:k + halfWin);

            % Compute normalized cross-correlation manually
            meanLeft = mean_manual(leftWindow(:));
            meanRight = mean_manual(rightWindow(:));
            stdLeft = sqrt(var_manual(leftWindow(:)));
            stdRight = sqrt(var_manual(rightWindow(:)));
            ncc = sum(sum((leftWindow - meanLeft) .* (rightWindow - meanRight))) / (windowSize^2 * stdLeft * stdRight);

            % Update the best match if the current correlation is higher
            if ncc > maxCorr
                maxCorr = ncc;
                bestOffset = j - k;
            end
        end

        % Assign the disparity value to the map
        disparityMap(i, j) = bestOffset;
    end
end

% Display the raw disparity map
figure;
imshow(disparityMap, []);
colormap('gray'); % Use gray colormap for display
colorbar;
title('Raw Disparity Map');

% Custom function to calculate mean
function m = mean_manual(data)
    m = sum(data) / numel(data);
end

% Custom function to calculate variance
function v = var_manual(data)
    m = mean_manual(data);
    v = sum((data - m) .^ 2) / (numel(data) - 1);
end
