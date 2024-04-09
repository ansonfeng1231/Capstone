function g  = gradiant(boundary_mask, z)
    [m,n] = size(z);
    g = NaN*ones(m,n,4);



    % alpha = 11.7376;
    % alpha = 3.287370735199700;
    alpha=3.51;
    dx = 0.5;

    % i think instead of predefining an alpha I am just going to make an
    % anonymous function and solve for alpha

    for i = 2:(m-1)
        for j = 2:(n-1)
            % if current cell can hold water
            if boundary_mask(i,j) == 1
                % north slop
                g(i,j,1) = alpha*((z(i - 1,j) - z(i,j))/dx);
                % south slope 
                g(i,j,2) = alpha*((z(i + 1,j) - z(i,j))/dx);
                % east slope
                g(i,j,3) = alpha*((z(i,j - 1) - z(i,j))/dx);  
                % west slope
                g(i,j,4) = alpha*((z(i,j + 1) - z(i,j))/dx); 
            end
        end
    end
end