x = imread('24_training.tif'); %load the color image
%x = imread('25_test.tif');
figure(1); imshow(x);
title('Original image');
xg = x(:,:,2); %decide to work on green channel image
xg(find(xg<20)) = 0; %make background all 0

%segment the foreground area
xt = xg; 
xf = xg;
xt(find(xt>=20)) = 1;
xf(find(xf>=20)) = 255;
figure(2); imshow(xf);
title('Foreground area');

%segment the background area
xc = imcomplement(xf); %complement of foreground(background)
se = strel('square',7); %define a filter
xc = imdilate(xc,se); %dilate background to cover circle edge
figure(3); imshow(xc);
title('background image');

%enhance the contrast of vessel and reduce noise 
xg = adapthisteq(xg); %adaptive histogram equalization
figure(4); imshow(xg);
title('Contrast image');
xg = medfilt2(xg); %median filter to reduce noise while keep edge
figure(5); imshow(xg);
title('Reduced noise image');

%find average value of foreground
foreground = xg.*xt;
n = sum(sum(xt));
m = sum(sum(foreground))/n;
xg(find(xg<10)) = m;

%find adaptive threshhold and make it binary image
T = adaptthresh(xg, 0.72,'NeighborhoodSize', 25);
M = imbinarize(xg,T);
xoutput = M|xc;%union with white background
figure(6); imshow(xoutput, []);
title('Union image');

%add a white filled circle at center to cover noise
[h,w] = size(xoutput);
xoutput = im2uint16(xoutput);%convert to int16 image
output = insertShape(xoutput,'FilledCircle',[w/2 h/2 25],'color','white','Opacity',1);
output = imcomplement(output);%complement to get result
output = im2bw(output,0.5);%convert to binary image
output = bwareaopen(output,15);%delete component less than 15 pixels
output = 255 * mat2gray(output);%convert scale to [0,255]
figure(7); imshow(output, []);
title('Output image');

%load the vessel ground truth
truth = imread('24_manual.gif');
figure(8); imshow(truth, []);
title('Truth image');

%Evaluate the segmentation accuracy
tst = zeros(h,w);
tst(find(output == truth))=1;
figure(9); imshow(tst, []);
title('Diffenrence image');
accuracy = 100*sum(sum(tst))/(h*w) %accuracy = 95.0497
imwrite(output,'24_trainingmap.tif','tiff')
%imwrite(output,'25_testmap.tif','tiff')
