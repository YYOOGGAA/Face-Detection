function meanTexture=computeMeanTexture(texture,numSegments,sg1,cnum)
disp('calaulating mean texture...')
tic
[s1,s2,h] = size(texture);
mts=zeros(h, numSegments);
for a1=1:s1
    for a2=1:s2
        dx=sg1(a1,a2);
        mts(:,dx)=mts(:,dx)+[texture(a1,a2,1);texture(a1,a2,2);...
            texture(a1,a2,3);texture(a1,a2,4);texture(a1,a2,5);...
            texture(a1,a2,6);texture(a1,a2,7);texture(a1,a2,8)];
    end
end
meanTexture=mts./[cnum;cnum;cnum;cnum;cnum;cnum;cnum;cnum];

toc
