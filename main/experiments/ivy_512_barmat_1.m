function [] = ivy_512_barmat_1()

exp_time = tic;

% matconvnet
addpath(genpath('../../matconvnet-1.0-beta16/'));
addpath(genpath('../../main/'));
vl_setupnn();
vl_compilenn();

% parpool begin
no_workers = 24;
pool = parpool('comet4', no_workers, 'IdleTimeout', Inf);
parfor i = 1:no_workers
    vl_setupnn();
end

% run
file_str = 'ivy/512/';
config = gen_ADELM_config(file_str);

for i = 1:10
    %load complete ELM experiment
    load([config.ELM_folder,file_str,'ELM_exp',...
            num2str(i),'.mat']);
        
    %adjust config
    ELM.config.bar_alpha = ELM.config.alpha * 2;
    ELM.config.max_bar_checks = 15;
    ELM.config.bar_AD_reps = 5;
    ELM.config.bar_temp = 20;
    
    %get barrier mat
    bar_mat = get_barrier_mat_quick(ELM);
    
    %save results
    if ~exist([ELM.config.tree_folder,file_str],'dir') mkdir([ELM.config.tree_folder,file_str]); end
    save([ELM.config.tree_folder,file_str,'/bar_mat',num2str(i),'.mat'],'bar_mat');
end

% parpool end
delete(pool);

exp_time = toc(exp_time);
fprintf('Total Experiment Time: %4d hours %4.2f minutes \n',...
                     floor(exp_time/3600), mod(exp_time/60,60));
        

end
