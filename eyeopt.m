% -------------------------------------------------------------------- %
%  This function is used to optimize the eyemap found previously.
%
%  @author : B06901144@NTU
%  @date  : 202005
%
%  @Input :
%           map  - the eyemap found previously.
%           bf - the length of the minor axis of the oval of face.
%
%  @Output :
%           eyemap_ - the eyemap after optimization.
% -------------------------------------------------------------------- %
function eyemap_ = eyeopt(map,bf)
    [r,c] = size(map);
    max_ = max(max(map));
    eyemap_ = map/max_;
    for t = 1:r
        for u = 1:c
            if eyemap_(t,u) <= 0.45
                eyemap_(t,u) = 0;
            end
        end
    end
    r = ceil(bf/15);
    Mask_e = zeros(2*r+1,2*r+1);

    for t = 1:2*r+1
        for u = 1:2*r+1
            if (t-r-1)^2/r^2+(u-r-1)^2/r^2 <= 1
                Mask_e(t,u) = 1;
            end
        end
     end

     [r,c] = size(eyemap_);
     eyemap_ = conv2(eyemap_, Mask_e,'same');
    
     max_ = max(max(eyemap_));
     eyemap_ = eyemap_/max_;

     for t = 1:r
        for u = 1:c
            if eyemap_(t,u) <= 0.7
                eyemap_(t,u) = 0;
            end
        end
     end

     for t = 2:(r-1)
        for u = 2:(c-1)
            if eyemap_(t,u) > eyemap_(t+1,u) 
                eyemap_(t+1,u) = 0;
            end
            if  eyemap_(t,u) > eyemap_(t-1,u)
                eyemap_(t-1,u) = 0;
            end
            if eyemap_(t,u) > eyemap_(t,u+1) 
                eyemap_(t,u+1) = 0;
            end
            if eyemap_(t,u) > eyemap_(t,u-1)
                eyemap_(t,u-1) = 0;
            end
            if eyemap_(t,u) > eyemap_(t-1,u-1)
                eyemap_(t-1,u-1) = 0;
            end
            if eyemap_(t,u) > eyemap_(t-1,u+1)
                eyemap_(t-1,u+1) = 0;
            end
            if eyemap_(t,u) > eyemap_(t+1,u-1)
                eyemap_(t-1,u-1) = 0;
            end
            if eyemap_(t,u) > eyemap_(t+1,u+1)
                eyemap_(t-1,u+1) = 0;
            end
        end
    end
end