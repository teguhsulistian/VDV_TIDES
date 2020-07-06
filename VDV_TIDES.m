%%---------------VALIDATION TIDES DATA FROM VELEPORT FORMAT-------------------%%
%%-----------------------------(VDV_TIDES.m)----------------------------------%%
%%Created By   : Teguh Sulistian
%%Institution  : Badan Informasi Geospasial
%%Modified     : 24 April 2020
%%
clear
clc
close all

format LONGG
disp('-------------VALIDATION TIDES DATA FROM VELEPORT FORMAT----------------')
fprintf('\n')

% input folder and output files
prompt = 'Input Location of Tides Observation = ';
location = input(prompt,'s');
output = 'File Output (.xlsx) = ';
outname = input(output,'s');
tol = input('Tolerance for loss of observation day (day) = ');
fprintf('\n')

% list all *.TXT files

folder_name = uigetdir();
filePattern = fullfile(folder_name, '*.TXT');
list = dir(filePattern);
S = {};
time = [];
depth = [];

for i=1:length(list)
    %Re-format table
    fd = fopen(list(i).name,'rt');
    formatspec = '%s %.3f %f32 %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d';
    S{i} =textscan(fd, formatspec, 'Delimiter','\t','HeaderLines',23, 'CollectOutput',true, 'EndOfLine','\r\n');
    fclose(fd);
    
    %Combine Multiple file
    time =cat(1,time,S{i}{1});

    timenum = datenum( time,'dd/mm/yyyy HH:MM:SS'); %timenum
    %Remark if you use matlab version <= R2013a , recommended to use this
    %script
                
    depth =cat(1,depth,S{i}{2});
    
    clear fd
end

%editing data (sorting descending)
timedepth = [timenum depth];
timedepthsort = sortrows(timedepth);
ts = timedepthsort(:,1);
ds = timedepthsort(:,2);

%Limits for Plotting
tmin = min(ts)-0.5;
tmax = max(ts)+0.5;
dmin = min(ds)-0.5;
dmax = max(ds)+0.5;

%Water Level Obsevation
HWL = max(depth);
MSL = nanmean(depth);
LWL = min(depth);
disp('----------Water Level Observation----------');
fprintf ('1. Maximum Data from tide data observation = %.3f meter\n',HWL);
fprintf ('2. Mean Data from tide data observation = %.3f meter\n',MSL);
fprintf ('3. Minimum from tide data observation = %.3f meter\n',LWL);
fprintf('\n')

%Plot Tide Data
figure('units','normalized','outerposition', [0 0 1.6 1.6])
plot(ts, ds, '--b')
hold on

%Legend
plot([ts(1) ts(end)],[HWL HWL], '-r','linewidth', 1.2)
plot([ts(1) ts(end)],[MSL MSL], '-g','linewidth', 1.2)
plot([ts(1) ts(end)],[LWL LWL], '-m','linewidth', 1.2)
box={'Data', ['Max  : ' num2str(HWL, '%2.2f m')],['Mean : ' num2str(MSL, '%2.2f m')],['Min  : ' num2str(LWL, '%2.2f m')]};
legend(box)
legend('location','EastOutside')
set(gca,'fontsize',15,'fontname','arial')

%Title and Axis Configuration
title({'\it Tides Data Observation'; location},'fontsize',20,'fontname','arial','fontweight','bold')
xlabel('Time Series (dd/mm/yy)','fontsize',15,'fontname','arial')
datetick('x','dd/mm/yy','keeplimits','keepticks')
ylabel('Water Level (m)','fontsize',15,'fontname','arial')
axis([tmin tmax dmin dmax]);
grid on

%Duration of Observation
lennum = length(ts);
s_obs = ts(1);
start_o = datestr(s_obs,'dd/mm/yyyy hh:MM:ss');
e_obs = ts(lennum);
end_o = datestr(e_obs,'dd/mm/yyyy hh:MM:ss');
duras = round(e_obs-s_obs);
disp('-----------Duration of Observation----------')
fprintf('\n')
fprintf('1. Start of observation    : %s\n',start_o);
fprintf('2. End of observation      : %s\n',end_o);
fprintf('3. Duration of observation : %d\n',duras);
fprintf('\n')

%Data Interval Validation
disp('----------Data Interval Validation----------')
for n=1:length(ts)-1
    spacing(n,1)=round((ts(n+1)-ts(n))*24*60);
end

v = mode(spacing);
fprintf ('1. Data Observation Interval = %.2f minutes\n',v);

wrong=find(spacing>v);
wr = length(wrong);
if wr>0
    for n=1:length(wrong)
        incorrect_interval{n,1}=datestr(ts(wrong(n)),'dd/mm/yyyy hh:MM:ss');
        incorrect_interval{n,2}=datestr(ts(wrong(n)+1),'dd/mm/yyyy hh:MM:ss');
        incorrect_interval{n,3}=spacing(wrong(n));
    end  
    sincor = size(incorrect_interval);
    count_incorrect = sincor(1);
    fprintf ('2. Data with incorrect interval = %d data\n',count_incorrect);
    incorrect_interval 
else
    fprintf('2. All data have correct interval\n');
end
    

%Lost Day Detection
disp('----------Loss Day Observation----------')

for n=1:length(ts)-1
    dayint(n,1)=round((ts(n+1)-ts(n)));
end

daywrong = find(dayint>tol);
dw = length(daywrong);

if dw > 0
    for n=1:length(daywrong)
        lost_day_data{n,1}=datestr(ts(daywrong(n)),'dd/mm/yyyy hh:MM:ss');
        lost_day_data{n,2}=datestr(ts(daywrong(n)+1),'dd/mm/yyyy hh:MM:ss');
        lost_day_data{n,3}=dayint(daywrong(n));
    end
    lost_day_data
else
    fprintf('No Loss Day Observation\n');
end

daylost = length(daywrong);
if daylost>0 
    fprintf ('----Tidal observation data in %s is REJECTED----\n',location);
else
    fprintf ('----Tidal observation data in %s is ACCEPTED----\n',location);
end
fprintf ('\n')


%Export Report
report_name= ([location,'_report.dat']);
dlmwrite(report_name,[]);
fr = fopen(report_name,'w');
fprintf(fr,'-------REPORT OF VALIDATION TIDES DATA FROM VELEPORT FORMAT----------\n');
fprintf(fr,'\n');
fprintf(fr,'Generated by VDV_TIDES.m\n');
fprintf(fr,'Script created by Teguh Sulistian\n');
ss = datestr((now));
fprintf(fr,'Report Modified  : %s\n',ss);
fprintf(fr,'\n');
fprintf(fr,'Location of Tides Observation = %s\n',location);
fprintf(fr,'File Output (.xlsx) = %s\n',outname);
fprintf(fr,'\n');
fprintf(fr,'----------Water Level Observation----------\n');
fprintf(fr,'1. Maximum from tide data observation = %4.3f meter\n',HWL);
fprintf(fr,'2. Mean from tide data observation = %4.3f meter\n',MSL);
fprintf(fr,'3. Minimum from tide data observation = %4.3f meter\n',LWL);
fprintf(fr,'\n');

fprintf(fr,'---------Duration of Observation-----------\n');
fprintf(fr,'\n');
fprintf(fr,'1. Start of observation    : %s\n',start_o);
fprintf(fr,'2. End of observation      : %s\n',end_o);
fprintf(fr,'3. Duration of observation : %d\n',duras);
fprintf(fr,'\n');

fprintf(fr,'----------Data Interval Validation----------\n');
fprintf(fr,'1. Data Observation Interval = %4.2f minutes\n',v);

wr = length(wrong);
if wr>0
    for n=1:length(wrong)
        incorrect_interval{n,1}=datestr(ts(wrong(n)),'dd/mm/yyyy hh:MM:ss');
        incorrect_interval{n,2}=datestr(ts(wrong(n)+1),'dd/mm/yyyy hh:MM:ss');
        incorrect_interval{n,3}=spacing(wrong(n));
    end  
    sincor = size(incorrect_interval);
    count_incorrect = sincor(1);
    fprintf (fr,'2. Data with incorrect interval = %d data\n',count_incorrect);
    fprintf(fr,'\n');
    fprintf(fr,'    Starting Date    |      Ending Date      | Minutes\n');
    fprintf(fr,'---------------------|-----------------------|--------\n');
    sizeinterval = size(incorrect_interval);
    for k = 1 : sizeinterval(1)
        fprintf(fr, '%s  |  %s  |   %d\n', incorrect_interval{k,1},incorrect_interval{k,2},incorrect_interval{k,3});
    end
else
    fprintf(fr,'2. All data have correct interval\n');
end
  
fprintf(fr,'\n');
fprintf(fr,'-----------Loss Day Observation------------\n');
fprintf (fr,'\n');
dw = length(daywrong);
if dw > 0
    for n=1:length(daywrong)
        lost_day_data{n,1}=datestr(ts(daywrong(n)),'dd/mm/yyyy hh:MM:ss');
        lost_day_data{n,2}=datestr(ts(daywrong(n)+1),'dd/mm/yyyy hh:MM:ss');
        lost_day_data{n,3}=dayint(daywrong(n));
    end
    fprintf(fr,'    Starting Date    |      Ending Date      | Day  \n');
    fprintf(fr,'---------------------|-----------------------|------\n');
    sizelost = size(lost_day_data);
    for i = 1 : sizelost(1)
    fprintf(fr, '%s  |  %s  |   %d\n', lost_day_data{i,1},lost_day_data{i,2},lost_day_data{i,3});
    end
    fprintf (fr,'\n');
else
    fprintf(fr,'No Loss Day Observation\n');
end

fprintf (fr,'\n');
if daylost>0 
    fprintf (fr,'----Tidal observation data in %s is REJECTED----\n',location);
else
    fprintf (fr,'----Tidal observation data in %s is ACCEPTED----\n',location);
end
fprintf (fr,'\n');

fclose(fr);

%Export Result
figuree=getframe(gcf);
imwrite(figuree.cdata, ['Plot ' location '.jpeg'],'jpeg');
xlswrite(outname,[timenum(:),depth(:)]);
xlswrite(outname,[time]);
out2 = ([location,'_input_ttides.xlsx']);
xlswrite(out2,[timenum(:),depth(:)])

disp('Finish');
%%
