% -------------------------------------------------------------------- %
%  This function is used to find the position of the mouth.
%
%  @author : B06901144@NTU
%  @date  : 202005
%
%  @Input :
%           image  - input image
%           Cr  - the Cr value of the possible face region
%           Cb  - the Cb value of the possible face region
%           af - the length of the major axis of the oval of face.
%           bf - the length of the minor axis of the oval of face.
%
%  @Output :
%           mouthmap_ - the mouthmap of image
% -------------------------------------------------------------------- %
function mouthmap_ = mouthmap(image,Cr,Cb,af,bf)
    %mouthmap
    [m,n] = size(image);

    ita = 0.95*((1/n)*sum(sum(Cr.^2))/((1/n)*sum(sum(Cr./Cb))));
    l1 = Cr.^2;
    l2 = (Cr.^2 - ita*(Cr./Cb)).^2;
    mouth = max(l1+l2-1,0);

    am = ceil(af/15);
    bm = ceil(bf/4);
    Mask = zeros(2*am+1,2*bm+1);

    for t = 1:2*am+1
        for u = 1:2*bm+1
            if (t-am-1)^2/am^2+(u-bm-1)^2/bm^2 <= 1
                Mask(t,u) = 1;
            end
        end
    end

    mouthmap_ = conv2(mouth, Mask,'same');

    [r,c] = size(mouthmap_);
    max_ = max(max(mouthmap_));
    mouthmap_ = mouthmap_/max_;
    for t = 1:r
        for u = 1:c
            if mouthmap_(t,u) <= 0.9
                mouthmap_(t,u) = 0;
            end
        end
    end
end
