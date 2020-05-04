function yn=erosion_y(y,k)
    [r,c] = size(y);
    y1 = y;
    for i=1:k
        for m = 2:(r-1)
            for n = 2:(c-1)
                y1(m,n) = min([y(m,n) y(m+1,n) y(m-1,n) y(m,n+1) y(m,n-1)]);   
            end
        end
    end
    yn=y1;
end