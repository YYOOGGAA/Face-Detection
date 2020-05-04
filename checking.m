% -------------------------------------------------------------------- %
%  This function is used to check whether it's a face or not
%
%  @author : B06901144@NTU
%  @date  : 202005
%
%  @Input :
%           image  - input image
%           eye_  - the eyemap
%           mouth_  - the mouthmap
%           number - the order of the input image
%           count - the order of the detected region in the input image
%           xo - the x vector of the major axis
%           yo - the y vector of the major axis
%
% -------------------------------------------------------------------- %
function checking(image,eye_,mouth_,number,count,xo,yo)
    %eyemouthmap
    [row,col] = size(image);
    if row*col > 592*896 %if the input image is too big
        eyed = downsample(eye_,3,2);
        mouthd = downsample(mouth_,3,2);
    else
        eyed = eye_;
        mouthd = mouth_;
    end
    [Bw_e, n1] = bwlabel(eyed);
    T = eyed+mouthd;
    %imshow(T)
    success = 0; 
    for t = 1:n1
        if success == 1
            break
        end
        [fx1, fy1] = find(Bw_e == t);
        %eye1
        x1 = mean(mean(fx1));
        y1 = mean(mean(fy1));
        for j = (t+1):n1
            if success == 1
                break
            end
            [fx2, fy2] = find(Bw_e == j);
            %eye2
            x2 = mean(mean(fx2));
            y2 = mean(mean(fy2));

            [Bw_m, n] = bwlabel(mouthd);
            for k = 1:n
                [fxm, fym] = find(Bw_m == k);
                %mouth
                xm = mean(mean(fxm));
                ym = mean(mean(fym));

                middle_x = (x1+x2)/2;
                middle_y = (y1+y2)/2;
            
                %三角形頂角
                theta1 = acosd(dot([y1-ym,x1-xm],[y2-ym,x2-xm])/(norm([y1-ym,x1-xm])*norm([y2-ym,x2-xm])));
                %眼睛中點夾角
                theta2 = acosd(dot([middle_y-ym,middle_x-xm],[y2-y1,x2-x1])/(norm([middle_y-ym,middle_x-xm])*norm([y2-y1,x2-x1])));
                %橢圓軸和中垂線夾角
                theta3 = acosd(dot([middle_y-ym,middle_x-xm],[yo,xo])/(norm([middle_y-ym,middle_x-xm])*norm([yo,xo])));

                height = norm([middle_y-ym,middle_x-xm]);
                base = norm([y2-y1,x2-x1]);
                ratio = base/height;
        
                if x1<xm && x2< xm
                    %disp('The mouth is under the eyes')
                    if theta3 < 20 && theta3 > 0
                        %disp('Two angles are close')
                        if theta2 < 98 && theta2 > 85
                            %disp('The angle is near 90')
                            if ratio < 1.1 && ratio > 0.68
                                %disp('The ratio is ok')
                                if theta1 < 57 && theta1 > 37
                                    %disp('The angleA is ok')
                                    success = 1;
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
     end
       
    if success == 1
        saveName = ['filepath_of_the_detected_face' num2str(number) '_' num2str(count) '.jpg'];
    else
        saveName = ['filepath_of_the_detected_notface' num2str(number) '_' num2str(count) '.jpg'];
    end
    imwrite(uint8(image), saveName)
end
