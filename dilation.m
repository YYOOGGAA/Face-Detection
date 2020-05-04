function imd=dilation(image,k)
for i=1:k
    im1=image|image([1,1:end-1],:);
    im2=im1|image([2:end,end],:);
    im3=im2|image(:,[1,1:end-1]);
    im4=im3|image(:,[2:end,end],:);
    image=im4;
end
imd=image;
end