function daughters = daughters_incubation_movement(ndaughters,caselist,parentID,parentstoday,i,...
    shapeA,scaleB,densitygrid,kdist,pdist,nrows,ncols,db)

for j = 1:ndaughters,
    lastcase = size(caselist,1);
    daughters(j,1) = lastcase+j;
    daughters(j,4) = parentID;
    daughters(j,5) = parentstoday(i,6); %date dog was infected

    %% days between infection and becoming infectious
    serialinterval_daughter = ceil(gamrnd(shapeA,scaleB,1));
    daughters(j,6) = daughters(j,5)+serialinterval_daughter;

    %%%% movement
    %% getting on the bus to randomly chosen place on island
    if unifrnd(0,100) <= db,
        [rws,cls] = find(densitygrid>=0);
        rw_sample = randsample(size(rws,1),1);
        newrow = rws(rw_sample);
        newcol = cls(rw_sample);
        daughters(j,2) = newrow; %row of grid cell
        daughters(j,3) = newcol; %col of grid cell

        %% location of LOCAL transmission from parent to daughter
    else ...
            done = 0;
        while done == 0,
            %% south/north movement
            sn = nbinrnd(kdist,pdist,1);
            if binornd(1,0.5) == 0, sn = -sn; end
            newrow = parentstoday(i,2)+sn; %row of grid cell
            %% east/west movement
            ew = nbinrnd(kdist,pdist,1);
            if binornd(1,0.5) == 0, ew = -ew; end
            newcol = parentstoday(i,3)+ew; %col of grid cell

            if newrow <= nrows && newcol <= ncols ...
                    && newrow >= 1 && newcol >= 1 ...
                    && densitygrid(newrow,newcol) >=0,
                done = 1;
                daughters(j,2) = newrow; %row of grid cell
                daughters(j,3) = newcol; %col of grid cell
            end
        end
    end

    %% update new transmission events (not rabid yet) in grid
    row = daughters(j,2);
    col = daughters(j,3);
end

daughters(:,7:8)=0; %set to 0 so can concatenate the 2 tables parents and daughters
