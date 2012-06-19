function x = project3D2D(P,X,imageSize)

if size(X,1) < 4
  X = [X; ones(1,size(X,2))];
end

x = P*X;
x = [x(1,:)./x(3,:); x(2,:)./x(3,:)];
x(1,:) = imageSize(2)-x(1,:);
x(2,:) = x(2,:)+1;
