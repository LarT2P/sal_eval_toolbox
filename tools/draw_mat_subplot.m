%% ABOUT THIS CODE
% Author: Lart Pang
% Github: https://github.com/lartpang
% Thanks: https://github.com/ArcherFMY/sal_eval_toolbox

clear, clc;

%% about using it：
% result_path  设置为存放evaluate.m生成的mat文件的文件夹，要注意，是包含所有数据集
%              的文件夹，默认是Results文件夹
% dataset_list 设置为result_path下想要读取数据的文件夹名字，最好使用数据集名字作
%              为这些文件夹的名字
% path_list    设置为对应于dataset_list所有文件夹中的mat文件名字的并集，注意，不用加
%              后缀名
% disp_list    设置为对应于path_list的所有文件要显示在绘图结果中的名字，由于matlab默
%              认会将名字字符串显示为latex格式，所以这里特意单独列出来转义后的列表，
%              注意要和path_list一一对应
result_path = './Results/';
save_folder_name = 'Total';
use_record = false;
use_random_color = true;
use_red_num = 1;
dataset_list = ["DUT-OMRON"; "DUTS"; "ECSSD"; "HKU-IS"; "PASCAL-S"];
path_list = ["VGG16FCN_OctDeV1TransV1_2Loss"; "AFNet";
             "MLMSNet"; "PAGE-Net";
             "HRS"; "CPD-V";
             "C2S"; "RAS";
             "PAGRN18"; "PiCANet";
             "DSS17"; "UCF17";
             "MSRNet"; "NLDF17";
             "AMU17"; "DCL16"];
disp_list = ["TIFNet"; "AFNet";
             "MLMSNet"; "PAGE";
             "HRS"; "CPD";
             "C2SNet"; "RAS";
             "PAGR"; "PiCANet";
             "DSS"; "UCF";
             "MSRNet"; "NLDF";
             "Amulet"; "DCL"];

%% main program
linestyle_list = {'-', '--', ':', '-.'};
marker_list = {'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<'};
color_list = {'k', 'y', 'b', 'm', 'c', 'g'};

% Especially，you can munually change the 'h'
% h = 5;
figure();
for h = 1:length(dataset_list)

    dataset_name = [result_path, char(dataset_list(h))];
    fprintf('\nproj: %s\n', dataset_name);
    if ~exist(dataset_name, 'dir')
        fprintf("the dir doesn't exist...\n");
        continue;
    end

    if use_record
        frecord = fopen('record.txt', 'wt');
        fprintf(frecord, '\n===============dataset: %s ===============\n', char(dataset_list(h)));
        fclose(frecord);
    end

    disp_real = [];
    for i = 1:length(path_list)

        file_name = [result_path, char(dataset_list(h)), '/', char(path_list(i)), '.mat'];
        fprintf('\nproj: %s\n', file_name);
        if ~exist(file_name, 'file')
            fprintf("the file doesn't exist...\n");
            continue;
        end

        disp_real = [disp_real, disp_list(i)];
        data = load(file_name);

        p = data.Pre;
        r = data.Recall;
        subplot(1, length(dataset_list), h);
        if i < use_red_num + 1
            % 指定自己的方法为红色
            plot(r, p, ...
                'LineStyle', '-', ...
                'Color', 'r', ...
                'LineWidth', 1.5)  % (X, Y)
        else  % 绘制其他算法
            if use_random_color
                % R, G, B
                curr_color = [0.2 * mod(i, 5)
                              0.1 * mod(i, 10)
                              0.05 * mod(i, 20)];
            else
                index_color = mod(i, 2) + 1;
                curr_color = char(color_list(index_color));
            end
            index_linestyle = mod(i + 1, 2) + 1;
            curr_linestyle = char(linestyle_list(index_linestyle));
            plot(r, p, ...
                'LineStyle', curr_linestyle, ...
                'Color', curr_color, ...
                'LineWidth', 1)  % (X, Y)
        end
        hold on;

        % 记录结果，可以选择不记录
        if use_record
            frecord = fopen('record.txt', 'wt');
            fprintf(frecord, 'proj: %s ==>>', char(path_list(i)));
            record_data  = [data.MaxFmeasure, data.mean_Fmeasure(3), data.S_measure, data.MAE];
            fprintf(frecord, 'MaxF %f, MeanF %f, SM %f, MAE %f\n', record_data);
            fclose(frecord);
        end
    end
    % 测试完成一个数据集

    hold off;

    ylabel('Precision', 'fontname', 'Times New Roman');
    xlabel('Recall', 'fontname', 'Times New Roman');
    axis([0, 1, 0, 1]);

    legend(disp_real, 'Location','southwest');
    title(dataset_list(h));
end

save_folder = [result_path, 'Img/', save_folder_name];
save_path = [save_folder, '/', 'PR.png'];
if ~exist(save_folder, 'dir')
    fprintf("the dir: %s doesn't exist, so let's creat it", save_folder);
    mkdir(save_folder);
end

% gca表示对axes的设置；  gcf表示对figure的设置
set(gca, 'fontname', 'Times New Roman');
set(gca, 'LooseInset', get(gca, 'TightInset'))
saveas(gcf, save_path);
