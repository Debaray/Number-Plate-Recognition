%Image Acquisition
I = imread('img/carplate8.jpg');
Iresize = imresize(I, [480 NaN]);%resize image
figure;
subplot(221);imshow(Iresize);title('resized image');
%Pre-Processing
Igray = rgb2gray(Iresize);%rbgtogray
subplot(222);imshow(Igray);title('rgbtogray image');
Ifilter = medianFilter(Igray);%apply median filter
subplot(223);imshow(Ifilter);title('median filtered image');
%Edge Detection by Prewitt Operator:
im = edge(Igray, 'prewitt');
subplot(224);imshow(im);title('Edge detection by Prewitt');

%Candidate Plate Area detection by Morphological Opening and Closing Operations:
se = strel('disk',3);%structural element
imd = imdilate(im,se);
figure;
subplot(221);imshow(imd);title('Morphological Dilation Operation');
imf = imfill(imd,'holes');
subplot(222);imshow(imf);title('After filling holes');
ime = imerode(imf, strel('diamond', 10));
subplot(223);imshow(ime);title('Morphological Erotion Operation');
%Actual Number Plate Area Extraction
Iprops=regionprops(ime,'BoundingBox','Area', 'Image');%image region
area = Iprops.Area;%take image region area
count = numel(Iprops);%count the number of element in Iprops
maxarea= area;%initialize area
boundingBox = Iprops.BoundingBox;%extract bounding box
for i = 1:count
    if(maxarea < Iprops(i).Area)
        maxarea = Iprops(i).Area;
        boundingBox = Iprops(i).BoundingBox;
    end
end
img = imcrop(Igray, boundingBox);
subplot(224);imshow(img);title('Actual Number Plate Area Extraction');
%Extracted Plate Region Enhancement
imc = imbinarize(img);
img_re = imresize(imc, [240 NaN]);
figure;
%Enhanced Plate Region
se_n = strel('disk',3); 
 op1 = imopen(img_re, se_n);

target1 = imcomplement(op1);
% target1 = bwareaopen(target1, 650);%remove object that contains less than 700 pixels
subplot(221);imshow(target1);title('Enhanced Plate Region');
%Character Segmentation:
 [h, w] = size(target1);
Charprops=regionprops(target1,'BoundingBox','Area','Image');
count = numel(Charprops);

noPlate=[]; % Initializing the variable of number plate string.

for i=1:count
   ow = length(Charprops(i).Image(1,:));
   oh = length(Charprops(i).Image(:,1));
   if ow<(h/2) && oh>(h/3)
       letter=readLetter(Charprops(i).Image); % Reading the letter corresponding the binary image 'N'.
       figure; imshow(Charprops(i).Image);
       noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
   end
end
countChar = 0;
for i = 1: length(noPlate)
    countChar = countChar+1;
end

%Character Recognition
fileID=fopen('character.txt','wt');
fprintf(fileID,'%s\n',noPlate);
fprintf(fileID,'\nTotal Number of Character = %d',countChar);
fclose(fileID);
