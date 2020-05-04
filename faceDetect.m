%---------------------------------------------------------------------%
% 
% @author: B06901144@NTU
% @date  : 202005
%
% This M file is the main part of the project.
% Can be run after skin.m
%
%---------------------------------------------------------------------%
for num = 1:'number_of_inputs'
    disp(num);
    fileName = ['filepath_of_testing_image' num2str(num) '.jpg'];
    Color = double(imread(fileName));
    fileNameSkin = ['filepath_of_the_detected_skin_area' num2str(num) '.jpg'];
    A = double(imread(fileNameSkin));
    
    Y = Color(:,:,1)*0.299+Color(:,:,2)*0.587+Color(:,:,3)*0.114;
    
    [row,col,k]=size(A);
    k1 = ceil(min(row,col)/100);
    k2 = ceil(min(row,col)/50);

    %opening
    A1 = erosion(A,k1);                             
    Ao = dilation(A1,k1);

    %closing
    A2 = dilation(Ao,k2);
    Ac = erosion(A2,k2);

    %If the remaining skin area is too small, delete it.
    [Bw,n0] = bwlabel(Ac);
    for i = 1:n0
        Area = sum(sum(Bw == i));
        if Area < (col*row)/70
            [r,c] = find(Bw == i);
            rc = [r c];
            [r1,c1] = size(rc);
            for j = 1:r1
                Bw(rc(j,1),rc(j,2)) = 0;
            end
        end
    end
    
    %partition (for some difficult case)
    [Bw,run,n1] = partition(n0, Bw, Color,Y);
    if run == 1
        [Bw,run,n2] = partition(n1,Bw,Color,Y);
    else
        n2 = n0;
    end
    
    axes = zeros(n2,2);
    count = 0;
    for i = 1:n2
        [fx, fy] = find(Bw == i);
        if size(fx) ~= 0
            %Use PCA to find axes of the oval of the like-face input. 
            x0 = mean(fx);
            y0 = mean(fy);
            z1 = [fx-x0 fy-y0];
            z = transpose(z1)*z1;
            [C, D] = eig(z);
            if D(1,1) > D(2,2)
                axes(i,1) = C(1,1);
                axes(i,2) = C(2,1);
            else
                axes(i,1) = C(1,2);
                axes(i,2) = C(2,2);
            end
            %Calculating some data of the oval.
            x1 = (fx-x0)*C(1,2) + (fy-y0)*C(2,2);
            x2 = (fx-x0)*C(1,1) + (fy-y0)*C(2,1);
            m11 = mean(abs(x1));
            m12 = mean(abs(x2));
            m21 = mean(abs(x1.^2));
            m22 = mean(abs(x2.^2));
            a1 = 3*pi/4*m11;
            a2 = 2*sqrt(m21);
            b1 = 3*pi/4*m12;
            b2 = 2*sqrt(m22);
            a = (a1+a2)/2;
            b = (b1+b2)/2;
            ratio = b/a;
            areao = pi/4*a*b;
            if  ratio > 1/3 && ratio <3
                [r,c] = size(fx);
                k = 0;
                for j = 1:r
                    if (x1(j,1)^2)/a^2+(x2(j,1)^2)/b^2 <= 1
                        k=k+1;
                    end
                end
                
                if k/areao > 0.7
                    count = count+1;    
                    af = a;
                    bf = b;
                    xo = axes(i,1);
                    yo = axes(i,2);
                    O2 = zeros(row,col);
                    for t = 1:r
                        if (x1(t,1)^2)/a^2+(x2(t,1)^2)/b^2 <= 0.85
                            O2(fx(t,1),fy(t,1)) = 1;
                        end
                    end
                    
                    [r,c] = find(O2 == 1);
                    ru = min(r);
                    rd = max(r);
                    cu = min(c);
                    cd = max(c);
                    Ot = imcrop(O2,[cu ru cd-cu rd-ru]);
                    Ot = dilation(Ot,5);
                    Ot = erosion(Ot,5);
                    
                    %eyemap
                    %detecting possible position of eyes'
                    test = imcrop(Color,[cu ru cd-cu rd-ru]).*Ot;
                    colorF = imcrop(Color,[cu ru cd-cu rd-ru]);
                    k = test(:,:,1)*0.299+test(:,:,2)*0.587+test(:,:,3)*0.114; % rgb2gray(test);
                    face = Ot;

                    %YCbCr
                    Tn = test;
                    R=test(:,:,1);
                    G=test(:,:,2);
                    B=test(:,:,3);

                    Y=zeros(size(R));Cb=zeros(size(R));Cr=zeros(size(R));
                    Y=0.299*R+0.587*G+0.114*B;
                    Cb=-0.169*R-0.331*G+0.500*B+127.5;
                    Cr=0.500*R-0.419*G-0.081*B+127.5;   
                    Tn(:,:,1)=Y;
                    Tn(:,:,2)=Cb;
                    Tn(:,:,3)=Cr;

                    %eyemapl
                    Yn = erosion_y(Y,col);
                    L = (255-Yn)/255;

                    %eyemapc
                    Cm = (1/3)*(Cb.^2+(255-Cr).^2+Cb./Cr);

                    %eyemapt
                    T = extractTexture(k);
                    Ta = abs(T);
                    Max = Ta(:,:,1);
                    for t = 2:8
                        Max = max(Max,Ta(:,:,t));
                    end
                    Max = Max.*face;
                    eyemap_ = (L*0.4 + Cm*0.4 + max(max(Max))*0.2).*Ot;
                    eyemap_ = eyeopt(eyemap_,bf);
                    
                    %Find the mouth
                    mouthmap_ = mouthmap(test,Cr,Cb,af,bf);
                    %Check whether it's a face or not
                    checking(colorF,eyemap_,mouthmap_,num,count,xo,yo);
                end
            end
        end
    end    
end
           



