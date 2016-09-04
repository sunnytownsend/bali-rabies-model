function parents = index_case(incursion_row,incursion_col)

parents(1,1) = 1; %dogID
parents(1,2) = incursion_row; %row of grid cell
parents(1,3) = incursion_col; %col of grid cell
parents(1,4) = 0; %parentID
parents(1,5) = 0; %date dog was infected
parents(1,6) = 1; %transmission date