% -------------------------------------------------------------------- %
%  This function is used to sparate the real skin region and the
%  misunderstanding region(for example a pink background)
%
%  @author : B06901144@NTU
%  @date  : 202005
%
%  @Input :
%           n0  - number of the detected region  of previous bwlabling
%           Bw  - the matrix after previous bwlabling
%           Color - the original testing data in rgb scale
%           Y     - the Y value of Color
%
%  @Output :
%           newBw - new image after partition
%           run - if "var>120" is satisfied run = 1, otherwise is 0
%           n1 - new amount of the detected region
% -------------------------------------------------------------------- %
function [newBw,run,n1] = partition(n0,Bw, Color,Y)
    [row, col,k] = size(Color);
    n1 = n0;
    run = 0;
    for i = 1:n0
        [fx, fy] = find(Bw == i);
        if size(fx) ~= 0
            area_ = sum(sum(Bw == i));
            [r,c] = size(fx);
            x0 = mean(fx);
            y0 = mean(fy);
            if area_ > 1/5*(row*col)
                ru = min(fx);
                rd = max(fx);
                cu = min(fy);
                cd = max(fy);
                test = imcrop(Color,[cu ru cd-cu rd-ru]);
                Y1 = test(:,:,1)*0.299+test(:,:,2)*0.587+test(:,:,3)*0.114;
                var = (std(std(Y1,1),1))^2;
                if var > 120
                    run = 1;
                    n1 = n1+1;
                    mid = Y(ceil(x0),ceil(y0));
                    [f,q] = find(fy == cu);
                    fm = mid_(fx,f);
                    left = Y(fm,cu);
                    [f,q] = find(fy == cd);
                    fm = mid_(fx,f);
                    right = Y(fm,cd);
                    [f,q] = find(fx == ru);
                    fm = mid_(fy,f);
                    up = Y(ru,fm);
                    [f,q] = find(fx == rd);
                    fm = mid_(fy,f);
                    down = Y(rd,fm);
                    candi = [mid left right up down];
                    dif = 0;
                    for k = 1:4
                        for p = (k+1):4
                            if abs(candi(1,k)-candi(1,p)) > dif
                                dif = abs(candi(1,k)-candi(1,p));
                                landmark1 = candi(1,k);
                                landmark2 = candi(1,p);
                            end
                        end
                    end
                        
                    for k = 1:r
                        spot = Y(fx(k,1),fy(k,1));
                        if abs(landmark1-spot) > abs(landmark2-spot)
                            Bw(fx(k,1),fy(k,1)) = n1;
                        end
                    end
                    
                    for k = 1:r
                        if fx(k,1)~= 1 && fx(k,1) ~= row && fy(k,1)~= 1 && fy(k,1) ~= col
                            dot = Bw(fx(k,1),fy(k,1));
                            if Bw(fx(k,1)-1,fy(k,1)) ~= dot && Bw(fx(k,1)+1,fy(k,1)) ~= dot
                                if Bw(fx(k,1)+1,fy(k,1)) == Bw(fx(k,1)-1,fy(k,1))
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1)-1,fy(k,1));
                                elseif Bw(fx(k,1)+1,fy(k,1)) == 0
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1)-1,fy(k,1));
                                elseif Bw(fx(k,1)-1,fy(k,1)) == 0
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1)+1,fy(k,1)); 
                                end
                            elseif Bw(fx(k,1),fy(k,1)-1) ~= dot && Bw(fx(k,1),fy(k,1)+1) ~= dot
                                if Bw(fx(k,1),fy(k,1)+1) == Bw(fx(k,1),fy(k,1)-1)
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1),fy(k,1)-1);
                                elseif Bw(fx(k,1),fy(k,1)+1) == 0
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1),fy(k,1)-1);
                                elseif Bw(fx(k,1),fy(k,1)-1) == 0
                                    Bw(fx(k,1),fy(k,1)) = Bw(fx(k,1)+1,fy(k,1)+1); 
                                end
                            end        
                        end
                    end
                end
            end
        end
    end
    newBw = Bw;
end

function mean_ = mid_(mat1,mat2)
    [r,c] = size(mat2);
    new = zeros(r,1);
    for i = 1:r
        new(i,1) = mat1(mat2(i,1),1);
    end
    mean_ = ceil(mean(new));   
end