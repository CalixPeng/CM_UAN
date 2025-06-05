% Simulation for varying beta
clear; clc; addpath('./Channel'); addpath('./Functions'); config;
handle_bar = waitbar(0); rng(1);
Dis = iniLoc(cf);
States_P = formStates(cf.Np-1);
[H, H_model] = ChannelSim(cf, Dis);
[PER, I_map] = CalPER(cf, Dis, States_P, H_model, false);
Constr = [0.5:0.05:0.95, 0.99]; t_repeat = 100;
Results_P = zeros(1,length(Constr));
Results_T = zeros(2,length(Constr));
Results_C = zeros(2,length(Constr));
Results_D = zeros(2,length(Constr));
Results_IA = zeros(2,length(Constr));
for k = 1:length(Constr)
    waitbar(0, handle_bar, ['Sim 2, beta = ',num2str(Constr(k))]);
    cf.PU_constr = Constr(k);
    P = transMatrix(cf, cf.alpha_1, cf.alpha_2, 1:cf.Np-1, ...
        1:cf.Ns-1, States_P, PER);
    Model_L = localModel(cf, Dis, States_P, PER, false);
    [Action_CCTS, Act_C] = plan_CCTS(cf, Dis, States_P, P, H_model);
    Action_DCTS = plan_DCTS(cf, Dis, H_model, Model_L, I_map, false);
    for n = 1:t_repeat
        th_P = algo_silent(cf, Dis, H);
        Results_P(k) = Results_P(k) + th_P;
        [th_P, th_S] = algo_TDM(cf, Dis, H, Model_L);
        Results_T(1,k) = Results_T(1,k) + th_P;
        Results_T(2,k) = Results_T(2,k) + th_S;
        [th_P, th_S] = algo_CCTS(cf, Dis, H, Model_L, P, States_P, ...
            Act_C, Action_CCTS);
        Results_C(1,k) = Results_C(1,k) + th_P;
        Results_C(2,k) = Results_C(2,k) + th_S;
        [th_P, th_S] = algo_DCTS(cf, Dis, H, Model_L, false, Action_DCTS);
        Results_D(1,k) = Results_D(1,k) + th_P;
        Results_D(2,k) = Results_D(2,k) + th_S;
		[th_P, th_S] = algo_IA(cf, Dis, H, Model_L, I_map);
        Results_IA(1,k) = Results_IA(1,k) + th_P;
        Results_IA(2,k) = Results_IA(2,k) + th_S;
        waitbar(n/t_repeat,handle_bar);
    end
end
Results_P = Results_P/(t_repeat*cf.N_slot*cf.T_slot);
Results_T = Results_T/(t_repeat*cf.N_slot*cf.T_slot);
Results_C = Results_C/(t_repeat*cf.N_slot*cf.T_slot);
Results_D = Results_D/(t_repeat*cf.N_slot*cf.T_slot);
Results_IA = Results_IA/(t_repeat*cf.N_slot*cf.T_slot);
%% Save data
save('./Results/beta_P.mat', 'Results_P');
save('./Results/beta_T.mat', 'Results_T');
save('./Results/beta_C.mat', 'Results_C');
save('./Results/beta_D.mat', 'Results_D');
save('./Results/beta_IA.mat', 'Results_IA');
%% Plot
figure(1); hold on;
plot(Constr,Results_P,'*-','Color',[0.85,0.33,0.1],'Linewidth',1.2);
plot(Constr,sum(Results_T,1),'+-','Color',[0.93,0.69,0.13],'Linewidth',1.2);
plot(Constr,sum(Results_C,1),'d-','Color',[0.49,0.18,0.56],'Linewidth',1.2);
plot(Constr,sum(Results_D,1),'o-','Color',[0,0.45,0.74],'Linewidth',1.2);
plot(Constr,Constr.*Results_P,'*--','Color',[0.85,0.33,0.1],'Linewidth',1.2);
plot(Constr,Results_T(1,:),'+--','Color',[0.93,0.69,0.13],'Linewidth',1.2);
plot(Constr,Results_C(1,:),'d--','Color',[0.49,0.18,0.56],'Linewidth',1.2);
plot(Constr,Results_D(1,:),'o--','Color',[0,0.45,0.74],'Linewidth',1.2);
legend('Total (no SU)','Total (C-TDM)','Total (CCTS)','Total (DCTS)',...
    'PU constraint','PU (C-TDM)','PU (CCTS)','PU (DCTS)');
xlabel('PU throughput degradation coefficient \beta');
ylabel('Throughput [bits/sec]'); grid on;
close(handle_bar);