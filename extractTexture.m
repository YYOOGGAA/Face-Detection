% -------------------------------------------------------------------- %
%  Adapted from fv_texture.m by R01942068@NTU 2012.11.06
%  @author : R01942054@NTU
%  @date  : 201405
%
%  @Input :
%           image  - RGB color space input image
%           metric - only support 'gabor' or 'Law' 
%
%  @Output :
%           feature - texture filter response 
% -------------------------------------------------------------------- %

% extract feature vector from Gabor texture
function gImg = extractTexture(image)

    H = size(image, 1);
    W = size(image, 2);

    nScale  = 2;
    nOrient = 4; 
    [EO, BP] = gaborconvolve(image, nScale, nOrient, 3, 1.7, ...
			    0.65, 1.3, 0, 0);

    gImg = zeros(H, W, nScale * nOrient);
    %feature = zeros(nScale * nOrient * 2, 1);
    %figure;
    tic
    for s = 1:nScale
        for o = 1:nOrient
            k = (s-1)*nOrient+o;
            tImg = abs(EO{s,o});
            gImg(:, :, k) = tImg ./ max(max(tImg)); 
            %subplot(nScale, nOrient, k); imagesc(gImg(:,:,k));
            %feature(2*k-1) = mean(mean(tImg));
            %feature(2*k)   = imgVariance(tImg, feature(2*k-1));
        end
    end
    toc
end     %end of GaborFeature

