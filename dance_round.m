function wq = dance_round(wq, boundary_mask, v,g)
    %load('clinton_elevation_variables.mat')
    % for now this will just move all the water into the cell with the
    % greatest slope
    size(boundary_mask)
    % loop through all the points
    for i = 2:100
        for j = 2:100
            % if this cell is able to hold water
            if boundary_mask(i,j) == 1
                % if water can move north
                if boundary_mask(i-1,j) == 1
                    wq(i-1,j) = wq(i-1,j) + g(i,j,1)*v(i,j);
                    % wq(i,j) = w(i,j) - g(i,j,1);
                end
                % is water can move south
                if boundary_mask(i+1,j) == 1
                    wq(i+1,j) = wq(i+1,j) + g(i,j,2)*v(i,j);
                    % wq(i,j) = w(i,j) - g(i,j,1);                    
                end
                % is water can move east
                if boundary_mask(i,j-1) == 1
                    wq(i,j+1) = wq(i,j-1) + g(i,j,3)*v(i,j);
                    % wq(i,j) = w(i,j) - g(i,j,1);                    
                end
                if boundary_mask(i,j+1) == 1
                    wq(i,j+1) = wq(i,j+1) + g(i,j,4)*v(i,j);
                    
                    % wq(i,j) = w(i,j) - g(i,j,1);                    
                end                
            else
                wq(i,j) = NaN;
            end
        end
    end
end
                