% Mini Project 1: Student Performance Analysis
clear; clc; close all;
% Synthetic data: columns = Mathematics, Programming, Statistics.
marks = [58 62 60;65 68 64;70 72 68;75 78 74;80 82 80;...
    85 88 84;60 58 62;72 75 72;90 92 88;78 80 76;...
    68 66 70;88 86 90];
attendance = [65;72;78;82;88;94;68;80;98;85;75;96];
student = (1:size(marks,1))';
exam = mean(marks,2);
subject = {'Mathematics';'Programming';'Statistics'};
summary = table(subject,mean(marks)',median(marks)',mode(marks)',...
    (max(marks)-min(marks))',var(marks)',std(marks)',...
    'VariableNames',{'Subject','Mean','Median','Mode','Range','Variance','StdDev'});
disp(summary);
R = corrcoef(attendance,exam); r = R(1,2);
p = polyfit(attendance,exam,1); predicted = polyval(p,attendance);
newAttendance = 90; newMarks = polyval(p,newAttendance);
R2 = 1-sum((exam-predicted).^2)/sum((exam-mean(exam)).^2);
% Compare independent groups based on attendance threshold (Welch test).
high = exam(attendance>=80); low = exam(attendance<80);

% Welch's two-sample t-test without toolbox

n1 = length(high);
n2 = length(low);

m1 = mean(high);
m2 = mean(low);

v1 = var(high);
v2 = var(low);

% Standard error
SE = sqrt(v1/n1 + v2/n2);

% Calculate t-statistic
stats.tstat = (m1 - m2)/SE;

% Degrees of freedom
stats.df = (v1/n1 + v2/n2)^2 / ...
    ((v1/n1)^2/(n1-1) + (v2/n2)^2/(n2-1));

% Two-tailed p-value
pvalue = betainc(stats.df / ...
    (stats.df + stats.tstat^2), stats.df/2, 0.5);

% Significance level
alpha = 0.05;
h = double(pvalue < alpha);

% Calculate 95% confidence interval
b = betaincinv(alpha, stats.df/2, 0.5);
tcrit = sqrt(stats.df*(1/b - 1));

ci = (m1-m2) + [-1 1]*tcrit*SE;
fprintf('Correlation = %.4f\nRegression: marks = %.4f * attendance %+.4f\n',r,p(1),p(2));
fprintf('R-squared = %.4f\nPredicted marks at 90%% attendance = %.2f\n',R2,newMarks);
fprintf('Group means: high = %.2f, low = %.2f\n',mean(high),mean(low));
fprintf('Welch t = %.4f, df = %.4f, p = %.6f, reject H0 = %d\n',stats.tstat,stats.df,pvalue,h);
fprintf('95%% CI for mean difference: [%.2f, %.2f]\n',ci);
results = table(student,attendance,exam,predicted,'VariableNames',...
    {'Student','Attendance','AverageMarks','PredictedMarks'});
writetable(summary,'student_statistics.csv'); writetable(results,'student_predictions.csv');
figure('Name','Student Performance Dashboard','Color','w');
tiledlayout(2,2);
nexttile; bar(mean(marks)); xticks(1:3); xticklabels(subject); ylabel('Mean marks'); title('Subject averages');
nexttile; scatter(attendance,exam,50,'filled'); hold on;
x = linspace(min(attendance),max(attendance),100); plot(x,polyval(p,x),'LineWidth',2);
xlabel('Attendance (%)'); ylabel('Average marks'); title(sprintf('Regression (r = %.3f)',r)); grid on;
nexttile; plot(student,exam,'o-',student,predicted,'s--'); xlabel('Student ID'); ylabel('Marks'); legend('Actual','Predicted','Location','best'); title('Actual vs predicted'); grid on;
nexttile; bar([mean(low),mean(high)]); xticks(1:2); xticklabels({'Below 80%','80% and above'}); ylabel('Mean marks'); title(sprintf('Group comparison (p = %.4f)',pvalue));
exportgraphics(gcf,'student_dashboard.png','Resolution',150);
