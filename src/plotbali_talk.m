function plotbali_talk(backgdgrid,incursion_col,incursion_row,today,caselist,...
    VCgrid)

%% map
% backgdgrid=densitygrid
figure('windowstyle','docked')
% Bali dog density contoured map (used elevation)
contourf(flipud(backgdgrid));
colormap(flipud(bone))
shading flat %shading flat or interp(smooth) or faceted(lines)
ylim([1 size(backgdgrid,1)])
xlim([1 size(backgdgrid,2)])
set(gca,'XTick',[],'YTick',[])
hold on

%% cases
% plot location of index case
plot(incursion_col, 101-incursion_row,'r.','markersize',20)

% plot cases older than 1 month as blue
% or = find(caselist(:,6)<=(today-30));
% oldcases = caselist(or,:);
% plot(oldcases(:,3), 101-oldcases(:,2), 'b.', 'markersize',9)

% plot new cases in last month as red
nr = find(caselist(:,6)>(today-30));
newcases = caselist(nr,:);
plot(newcases(:,3), 101-newcases(:,2), 'y.', 'markersize',10)
%title(strcat('month=', num2str(month)))


%% plot vaccination coverage (VC) as a transparent layer over the map. The
% more opaque, the higher the VC
image(flipud(VCgrid),'alphadata',flipud(VCgrid));


%% saving
% if save_outputs == 1,
%     runname = strcat(scenariocode,'_seed',num2str(seed),'_run',num2str(month));
%     print('-djpeg','-r300',runname)
%     save(runname)
% end

