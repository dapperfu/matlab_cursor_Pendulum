function body = makeCollectible(id, position)
%MAKECOLLECTIBLE Optional artifact. Collecting it is not required to win.
    body = struct('id', double(id), 'position', reshape(double(position), 1, 2), 'radius', 0.22);
end
