%% for most strategies

function indices_vacc = patchyvaccination(blocks_vacc,no_sqs_unvacc,...
    vacc_order,vacc_month,landgrid)

%     no_sqs_unvacc = 20;
% vacc_cov_achieved = 0.7;

%     for vacc_month = 1:6;
% blocks_vacc = vacc_order{vacc_month,1}(1,find(~isnan(vacc_order{vacc_month,1})));
indices_vacc = [];
load blocks_rows_cols.mat

% for each vaccination block
for i=1:size(blocks_vacc,2),

    %identify indices for squares of vaccination block which overlap land
    zero_grid = zeros(size(landgrid,1),size(landgrid,2));
    zero_grid(block_rows_cols(blocks_vacc(i),2):block_rows_cols(blocks_vacc(i),3),...
        block_rows_cols(blocks_vacc(i),4):block_rows_cols(blocks_vacc(i),5)) = 1;
    block_grid = zero_grid.*landgrid;
    indices = find(block_grid>0);

    % randomly select squares which wont be vaccinated
    if no_sqs_unvacc/24 < size(indices,1)
        r = randsample(1:size(indices,1),no_sqs_unvacc/24);
        indices(r)=[];
    else indices = [];
    end
    % generate long list of indices in grid which are to be vaccinated
    indices_vacc = [indices_vacc; indices];
end

if vacc_month > 1, load indices_vacc_bymonth.mat; end
indices_vacc2{vacc_month} = indices_vacc;
save indices_vacc_bymonth indices_vacc2


