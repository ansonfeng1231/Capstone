function yot()
% this function will initialize all the maps and variables needed for thie
% clinton elevation dataset
    
    dx = -5:0.5:5;
    dy = dx;

    
    [xq, yq] = meshgrid(dx, dy);
    z = -exp(-(xq.^2 + yq.^2));
    zq = griddata(dx, dy, z, xq, yq);


    % create boundry mask
    % if zq(i,j) has an elevation boundary_mask(i,j) = 1
    % if zq(i,j) does not have an elevation BUT it is adjacent to a cell
    % with a defined elevation then boundary_mask(i,j) = 0
    % else zq(i,j) is nan then boundary_mask(i,j) is nan
    [m,n] = size(xq);
    bm = NaN.*ones(m, n);
    % loop through all points of boundary mask
    for i = 1:m
        for j = 1:n
            if (xq(i,j)^2 + yq(i,j)^2) < 4
                bm(i,j) = 1;
            end
        end
    end
    
    % clean up the edges
    bm(1,:) = NaN;
    bm(:,1) = NaN;
    bm(m,:) = NaN;
    bm(:,n) = NaN;
    
    % loop through all points in the boundary mask
    for i = 1:m
        for j = 1:n
            if isnan(bm(i,j))
                % check to see if a cell that can hold water is adjacent to
                % any other cells that can contain water
                try
                    if (bm(i,j+1) == 1)
                        bm(i,j) = 0;  
                    end
                catch
                    
                end

                try
                    if (bm(i,j-1) == 1)
                        bm(i,j) = 0;
                    end
                catch

                end

                try
                    if (bm(i+1,j) == 1)
                        bm(i,j) = 0;
                    end
                catch

                end

                try
                    if (bm(i-1,j) == 1)
                        bm(i,j) = 0;
                    end
                catch

                end
            end
        end
    end
    disp(bm)
    figure 
    surf(xq,yq,bm)
    shading interp
    colormap gray
    % if a cell cant hold water set its height to NaN
    z(isnan(bm)) = NaN;
    z(bm == 0) = NaN;


    % initialize water grid post rain
    vq = NaN*ones(size(z));
    

    % is the boundry mask says that cell can hold water there, put 1 water
    % there
    vq(bm==1) = 1;
    disp(vq)
    % vq(bm==0) = 0;

    % vq(40,40)
    % figure
    % surf(z,vq)
    % figure
    % surf(vq)

    % initialize water grid post water movement
    wq = 0*ones(m,n);
    wq(1,:) = NaN;
    wq(:,1) = NaN;
    wq(m,:) = NaN;
    wq(:,n) = NaN; %#ok<NASGU>
   
    
    % initialize  plastic grid
    pq = NaN*ones(size(z));
    % if the boundary mask says the cell can hold water give the cell 0
    % plastic
    pq(bm==1) = 0;
    % 62 - 140 for both axis
    for i = 1:m+1
        for j = 1:n+1
            if (mod(i,5) == 0 &&  mod(j,5) == 0)
                if (~isnan(bm(i,j)))
                    pq(i,j) = 1;
                end
            end
        end
    end
    [x_index, y_index] = meshgrid(1:m, 1:n);
    % figure
    % scatter3(x_index,y_index, pq)

    
    figure
    surf(vq);
    % g = g./3.287;



    % water_lst = NaN*ones(10,m,n);
    water_lst(:,:,1) = vq;
    coord = [1,1];
    coord_lst = NaN*ones(200,2);
    coord_lst(1,:) = coord;
    g = gradient(bm,z);
    for a = 2:2
        % print the total
        sum(sum(vq(~isnan(vq))));
        vq = dance_round(bm, vq, g);
        disp(bm)
        disp(vq)
        water_lst(:,:,a) = vq;
        % pq = plastic_movement(bm, pq, g);
        coord = move_plastic(coord, 0.05, vq, z);
        coord_lst(a,:) = coord;
    end
    
    interpolated_z = interp2(xq,yq,zq, coord_lst(:,1), coord_lst(:,2), 'linear');
    % % disp(interpolated_z)
    figure
    colormap abyss
    surf(xq,yq,z)
    shading interp
    % hold on
    % scatter3(coord_lst(:,1), coord_lst(:,2), interpolated_z, 75, 'filled','MarkerFaceColor',[1 1 1])
    % hold off
    % figure
    % surf(pq)
    % figure
    % scatter3(x_index, y_index, pq)
    
    % water plotting purposes
    % for i = 1:20
    %     if mod(i,2) == 0
    %         figure
    %     %     % c = colormap('default');
    %         scaled_vq = (water_lst(:,:,i) - min(water_lst(:))) / (max(water_lst(:)) - min(water_lst(:)));
    %     %     % color_temp = round(scaled_vq * (size(c, 1) - 1)) + 1;
    %     %     % color_temp = max(1, min(color_temp, size(c, 1)));
    %     %     % colors = c(color_temp, :);
    %         scatter3(coord_lst(i,1), coord_lst(i,2), interpolated_z(i), 100 ,'filled','MarkerFaceColor',[1 1 1])
    %         hold on
    %         surf(xq,yq, z,scaled_vq, 'FaceAlpha',0.5)
    %         shading interp
    % 
    %     %     % colorbar('Ticks', 0:0.2:1);
    %         colormap(flip(parula))
    %         clim([0 1]);
    %         hold off
    %     end
    % end
    % plastic plotting purposes
    % plastic_plot = NaN*ones(size(z));
    % idx = ~isnan(pq);
    % plastic_plot(idx) = z(idx);
    % % 
    % % 
    % c = colormap('default');
    % scaled_pq = (pq(idx) - min(pq(idx))) / (max(pq(idx)) - min(pq(idx)));
    % color_idx = round(scaled_pq * (size(c, 1) - 1)) + 1;
    % % 
    % % % Ensure color indices are within range
    % color_idx = max(1, min(color_idx, size(c, 1)));
    % % 
    % % % Assign colors based on color indices
    % colors = c(color_idx, :);
    % figure
    % surf(z,vq)
    % hold on
    % shading interp
    % scatter3(x_index(idx), y_index(idx), plastic_plot(idx), 36, colors, 'filled');
    % colormap('default')



    
end

