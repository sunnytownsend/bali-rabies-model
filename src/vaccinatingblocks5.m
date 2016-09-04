function VCgrid = vaccinatingblocks4(vacc_camp_month,vacc_campaign,scenario,VCgrid,...
    vacc_cov_achieved,vacc_duration,caselist,today,reactive_period,...
    delay_reaction,no_rand_sqs_unvacc,landgrid,num_missing_blocks,compliance)

%% determine order in which blocks vaccinated according to vacc scenario
% for random-based scenarios the order of vacc changes each year
if vacc_camp_month == 1 & vacc_campaign == 1, %see below for scenario 2 (sync)
    if scenario == 3, %random 
        block_numbers = 2:25;
        blocks= reshape(randsample(block_numbers,24),vacc_duration,24/vacc_duration);
        for i=1:vacc_duration, vacc_order{i,:} = blocks(i,:); end
        save vacc_order vacc_order
        
    elseif scenario == 9, % missing Klungkung
        block_numbers = [2:4 NaN 6:25];%replace block 5 (Klungkung) with NaN
        blocks= reshape(randsample(block_numbers,24),vacc_duration,24/vacc_duration);
        for i=1:vacc_duration, vacc_order{i,:} = blocks(i,:); end
        save vacc_order vacc_order

    elseif scenario == 12, % missing randomly picked block
        block_numbers = 2:25;
        if vacc_campaign == 1, rb = randsample(24,num_missing_blocks);
        save rb rb; 
        else load rb;
        end
        blocks= reshape(randsample(block_numbers,24),vacc_duration,24/vacc_duration);
        for i=1:length(rb), blocks(find(blocks==rb(i)))=NaN; end
        for i=1:vacc_duration, vacc_order{i,:} = blocks(i,:); end
        save vacc_order vacc_order

        % for non-random based scenarios the order of vaccination stays the
        % same each year
    elseif scenario >=4 & scenario <= 8 & vacc_campaign == 1,
        if scenario == 4, %ring out
            vacc_order = {[18,19,13,14];[17,12,7,8];[9,10,15,20];...
                [25,24,23,22]; [21,16,11,6]; [2,3,4,5]};
        elseif scenario == 5, % south to north/from source northwards
            vacc_order = {[2,3,4,5];[10,9,8,7];[6,11,12,13];[14,15,20,19];...
                [18,17,16,21]; [22,23,24,25]};
        elseif scenario == 6, % starting furthest from source
            vacc_order = {[21 16 11 6];[22 17 12 7];[2 23 18 13];...
                [8 3 24 19];[14 9 4 25];[20 15 10 5]};
        elseif scenario == 7, % partial
            vacc_order = {[18 13 8];[19 14 9]};
        elseif scenario == 8, % start in jembrana - Janice/ by regency
            vacc_order = {[12 16 11 6];[15 20 25 24];[23 22 21 17];...
                [7 8 9 10];[2 3 4 5];[13 14 18 19]};
        end
        save vacc_order vacc_order
    end
end

%% update VC grid with newly vaccinated blocks

% VCgrid=zeros(100,161);
% vacc_cov_achieved=0.7;
% vacc_camp_month = 1;
if scenario == 2 && vacc_camp_month == 1 ,
    if no_rand_sqs_unvacc > 0 & vacc_campaign == 1,
        indices_vacc = find(landgrid>0);
        r = randsample(1:size(indices_vacc,1),no_rand_sqs_unvacc);
        indices_vacc(r)=[];
        VCgrid(indices_vacc) = vacc_cov_achieved;
        save indices_vacc_s2 indices_vacc
    elseif no_rand_sqs_unvacc > 0 & vacc_campaign > 1,
        load indices_vacc_s2.mat
        VCgrid(indices_vacc) = vacc_cov_achieved;
    else VCgrid(:,:) = vacc_cov_achieved;
    end

elseif scenario == 10,
    % find new cases in last month
    nr = find(caselist(:,6)>(today-delay_reaction-reactive_period) ...
        & caselist(:,6)<(today-delay_reaction));
    newcases = caselist(nr,:);
    % identify the blocks in which new cases occured
    if isempty(nr)==0,
        load blocks_rows_cols.mat
        for i = 1:size(newcases),
            rowN = newcases(i,2);%row of new case
            colN = newcases(i,3);%col of new case
            blockNew(i,1) = find(block_rows_cols(:,2)<=rowN & block_rows_cols(:,3)>=rowN ...
                & block_rows_cols(:,4)<=colN &  block_rows_cols(:,5)>=colN);
        end
        % list and order the infected blocks according to how many cases
        if size(unique(blockNew),1)>1,
            infblocks(:,1)=unique(blockNew);
            infblocks(:,2) = histc(blockNew,unique(blockNew));
            infblocks = flipud(sortrows(infblocks,2));
        else infblocks(1,1) = blockNew(1);
            infblocks(1,2) = size(blockNew,1);
        end
        % if there are 4 or more infected blocks then pick the 4 with most
        % cases
        if size(infblocks,1) >= 4,
            blocks_vacc = infblocks(1:4,1);
        else % else pick the <4 that are infected
            blocks_vacc = infblocks(:,1);
        end

        %vaccinate
        for i=1:size(blocks_vacc,1),
            VCgrid(block_rows_cols(blocks_vacc(i),2):block_rows_cols(blocks_vacc(i),3),...
                block_rows_cols(blocks_vacc(i),4):block_rows_cols(blocks_vacc(i),5))=vacc_cov_achieved;
        end
    end
    
    
    %% reactive scenario 2-Jonathan's idea-dont repeat vaccinate same block within same campaign
elseif scenario == 11,    
    % find new cases in last month
    nr = find(caselist(:,6)>(today-delay_reaction-reactive_period) ...
        & caselist(:,6)<=(today-delay_reaction));
    nr2=find(caselist(:,6)>(today-30));
    newcases = caselist(nr,:);
    % identify the blocks in which new cases occured
    if isempty(nr)==0,
        load blocks_rows_cols.mat
        for i = 1:size(newcases),
            rowN = newcases(i,2);%row of new case
            colN = newcases(i,3);%col of new case
            blockNew(i,1) = find(block_rows_cols(:,2)<=rowN & block_rows_cols(:,3)>=rowN ...
                & block_rows_cols(:,4)<=colN &  block_rows_cols(:,5)>=colN);
        end
        % list and order the infected blocks according to how many cases
        if size(unique(blockNew),1)>1,
            infblocks(:,1)=unique(blockNew);
            infblocks(:,2) = histc(blockNew,unique(blockNew));
            infblocks = flipud(sortrows(infblocks,2));
        else infblocks(1,1) = blockNew(1);
            infblocks(1,2) = size(blockNew,1);
        end
                
        %load blocks vaccinated already in this campaign
        if vacc_camp_month > 1, load blocks_vax.mat;
            %only vaccinate unvaccinated blocks
            [tf loc]=ismember(infblocks(:,1),blocks_vax);
            infblocks(find(tf>0),:)=[];
        else blocks_vax=[];
        end
                
        % if there are 4 or more infected blocks then pick the 4 with most
        % cases
        if size(infblocks,1) >= 4,
            blocks_vacc = infblocks(1:4,1);
        else % else pick the <4 that are infected
            blocks_vacc = infblocks(:,1);
        end
        
        
        %vaccinate
        for i=1:size(blocks_vacc,1),
            VCgrid(block_rows_cols(blocks_vacc(i),2):block_rows_cols(blocks_vacc(i),3),...
                block_rows_cols(blocks_vacc(i),4):block_rows_cols(blocks_vacc(i),5))=vacc_cov_achieved;
        end
        
        %record which blocks vaccinated so dont repeat
        blocks_vax=[blocks_vax; blocks_vacc];
        save blocks_vax blocks_vax

    end

    
    
    % for other strategies load the blocks to be vaccinated this month
    % and reset their coverage as vacc_cov_achieved
elseif scenario > 2
    load blocks_rows_cols.mat
    load vacc_order.mat
    blocks_vacc = vacc_order{vacc_camp_month,1}(1,find(~isnan(vacc_order{vacc_camp_month,1})));
    if no_rand_sqs_unvacc > 0 & vacc_campaign == 1,
        indices_vacc = patchyvaccination(blocks_vacc,no_rand_sqs_unvacc,...
            vacc_order,vacc_camp_month,landgrid);
        VCgrid(indices_vacc) = vacc_cov_achieved;
    elseif no_rand_sqs_unvacc > 0 & vacc_campaign > 1,
            load indices_vacc_bymonth.mat
            VCgrid(indices_vacc2{vacc_camp_month}) = vacc_cov_achieved;
    else
        for i=1:size(blocks_vacc,2),
            if compliance==1 %& vacc_duration==6 %& rem(vacc_campaign,2) == 0,
                currentVC=VCgrid(block_rows_cols(blocks_vacc(i),2),block_rows_cols(blocks_vacc(i),4));
                vacc_cov_achieved_highcompliance=currentVC+(1-vacc_cov_achieved)*vacc_cov_achieved;
                VCgrid(block_rows_cols(blocks_vacc(i),2):block_rows_cols(blocks_vacc(i),3),...
                    block_rows_cols(blocks_vacc(i),4):block_rows_cols(blocks_vacc(i),5))=vacc_cov_achieved_highcompliance;
            else
                VCgrid(block_rows_cols(blocks_vacc(i),2):block_rows_cols(blocks_vacc(i),3),...
                    block_rows_cols(blocks_vacc(i),4):block_rows_cols(blocks_vacc(i),5))=vacc_cov_achieved;
            end
        end
    end
end


%%
%elseif scenario == 10,
% Gianyar_denpasar = [4 9];
% Badung = [3 8];
% Buleleng = 21:24;
% Jembrana = [6 11 16];
% Bangli = [13 14 18 19];
% Karangasem = [10 15 20 25];
% Klungkung = 5;
% Tabanan = [2 7 12 17];
% vacc_order = {Klungkung;Badung;Jembrana;[Karangasem Buleleng(3:4)];...
%     [Buleleng(3:4) Tabanan]; [Gianyar_denpasar Bangli]};