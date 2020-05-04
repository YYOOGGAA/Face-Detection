%---------------------------------------------------------------------%
% Apply SVM library from https://www.csie.ntu.edu.tw/~cjlin/libsvm/
% @author: B06901144@NTU
% @date  : 202005
%
% This M file is used to find the skin area of the input image.
% It's the fist file needed to be run before faceDetect,m.
% 
% Using SVM to classify the color of the image.
% The traing data was built by me.
%
%---------------------------------------------------------------------%

addpath('D:\MATLAB\R2019a\libsvm-3.24');
addpath('D:\MATLAB\R2019a\libsvm-3.24\windows');

feature_a = zeros(208,3);
% colume 1: Y colume2: Cb colume3: Cr

label_a = zeros(208,1);

%read training data
file_path = '\training_data\notskin\';
img_path_list = dir(strcat(file_path,'*.jpg'));
img_num = length(img_path_list);
if img_num > 0 
        for j = 1:img_num 
            image_name = img_path_list(j).name;
            image =  double(imread(strcat(file_path,image_name))); 
            
            R=image(1,1,1);
            G=image(1,1,2);
            B=image(1,1,3);
            Y=0.299*R+0.587*G+0.114*B;
            Cb=-0.169*R-0.331*G+0.500*B+128;
            Cr=0.500*R-0.419*G-0.081*B+128;
            
            feature_a(j,1) = Y;
            feature_a(j,2) = Cb;
            feature_a(j,3) =Cr;
            label_a(j,1) = 2;
        end
end

file_path = '\training_data\skin\';
img_path_list = dir(strcat(file_path,'*.jpg'));
img_num = length(img_path_list);
if img_num > 0 
        for j = 1:img_num 
            image_name = img_path_list(j).name;
            image =  double(imread(strcat(file_path,image_name))); 
            
            R=image(1,1,1);
            G=image(1,1,2);
            B=image(1,1,3);
            Y=0.299*R+0.587*G+0.114*B;
            Cb=-0.169*R-0.331*G+0.500*B+128;
            Cr=0.500*R-0.419*G-0.081*B+128;
            
            feature_a(j+115,1) = Y;
            feature_a(j+115,2) = Cb;
            feature_a(j+115,3) = Cr;
            label_a(j+115,1) = 1;
            %fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));
        end
end

%test data
test = double(imread('filepath_of_testing_image\31.jpg'));
[row,col,k]=size(test);
feature_b = zeros(row*col,3);

%to YCbCr
Tn = test;
R=test(:,:,1);
G=test(:,:,2);
B=test(:,:,3);
count = 1;
for i = 1:row
    for j = 1:col
        Y=0.299*R(i,j)+0.587*G(i,j)+0.114*B(i,j);
        Cb=-0.169*R(i,j)-0.331*G(i,j)+0.500*B(i,j)+128;
        Cr=0.500*R(i,j)-0.419*G(i,j)-0.081*B(i,j)+128;
        Tn(i,j,1) = Y;
        Tn(i,j,2) = Cb;
        Tn(i,j,3) = Cr;
        feature_b(count,1) = Y;
        feature_b(count,2) = Cb;
        feature_b(count,3) = Cr;
        count = count + 1;
    end
end

% scaling
[m,N]=size(feature_a);
[m1,N]=size(feature_b);
mf=mean(feature_a);
nrm=diag(1./std(feature_a,1));
feature_1=(feature_a-ones(m,1)*mf)*nrm;
feature_2=(feature_b-ones(m1,1)*mf)*nrm;
% SVM
model = svmtrain(label_a, feature_1);

label_b = ones(row*col,1);
[predicted_label] = svmpredict(label_b, feature_2, model);

Skin = rgb2gray(test);
count = 1;
for i = 1:row
    for j = 1:col
        if predicted_label(count,1) == 1 %skin
            Skin(i,j) = 255;
        else
            Skin(i,j) = 0;
        end
        count = count + 1;
    end
end
imwrite(uint8(Skin), 'filepath_of_detected_skin_area.jpg')

