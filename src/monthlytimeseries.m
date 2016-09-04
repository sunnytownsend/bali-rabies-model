%% time series based on caselist

function [monthlynewcases,monthlynewcases_obs] = monthlytimeseries(...
    caselist, today, plot_timeseries, VCisland)

caselist_sorted = sortrows(caselist,6); %based on date become rabid
monthlynewcases = 0;
month = 0;
for day = 1:today,
    if rem(day,30) == 0,
        month=month+1;
        rws = find(caselist_sorted(:,6)<=day & caselist_sorted(:,6)>(day-30));
        monthlynewcases(month,1) = size(rws,1);
        monthlynewcases_obs(month,1) = sum(caselist_sorted(rws,8));
    end
end

%% observed monthly new cases and vaccination coverage
figure('windowstyle','docked')
if plot_timeseries==1,
    subplot 212
    box on
    % plot(linspace(0,month/12,month),monthlynewcases,'linewidth',2)
    [AX,H1,H2]=plotyy(linspace(0,month/12,month),monthlynewcases,...
        linspace(0,today/360,size(VCisland,1)),VCisland*100);
    
    load Bali_dogcases_realts.mat
    hold on
    H3=plot(AX(1),linspace(0,37/12,37),Bali_dogcases_realts,'r-');
    
    set(AX,'fontsize',12)
    set(get(AX(1),'Ylabel'),'String','Observed monthly cases','fontsize',16)
    set(get(AX(2),'Ylabel'),'String','Vaccination coverage (%)','fontsize',16)
    set([H1 H2 H3],'linewidth',2)
    %ylim(AX(1),[0 100])
    ylim(AX(2),[0 80])
end

