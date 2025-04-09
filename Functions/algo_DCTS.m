function [th_P, th_S] = algo_DCTS(cf, Dis, H, Model_L, FDM, Action_DCTS)
    th_P = 0;
    for i = 1:cf.Ns-1
        if isempty(Model_L.id_P{i})
            continue;
        end
        N_P = length(Model_L.id_P{i});
        Model_L.Refund{i} = zeros(size(Action_DCTS{i},1:2));
        id = ismember(Model_L.States_P{i},zeros(1,N_P),'rows');
        Model_L.belief{i} = zeros(1,size(Model_L.States_P{i},1));
        Model_L.belief{i}(id) = 1;
    end
    state_P = zeros(1,cf.Np-1);
    act_pre = zeros(1,cf.Ns-1);
    Buffer = zeros(1,cf.Ns); Buffer(1) = inf;
    for t = 1:cf.N_slot
        act = zeros(1, cf.Ns-1);
        for i = 1:cf.Ns-1
            if isempty(Model_L.id_P{i})
                act(i) = 1;
                continue;
            end
            id_sP_prev = randsample(1:length(Model_L.belief{i}),1,true, ...
                Model_L.belief{i});
            Model_L.belief{i} = Model_L.belief{i} * ...
                Model_L.P{i}(:,:,act_pre(i)+1);
            if(Buffer(i)<cf.L_S(i))
                if(Action_DCTS{i}(id_sP_prev,act_pre(i)+1,t)==1)
                    Model_L.Refund{i}(id_sP_prev,act_pre(i)+1) = 1 + ...
                        Model_L.Refund{i}(id_sP_prev,act_pre(i)+1);
                end
            else
                if(Action_DCTS{i}(id_sP_prev,act_pre(i)+1,t)==1)
                    act(i) = 1;
                else
                    if(Model_L.Refund{i}(id_sP_prev,act_pre(i)+1)>0 && ...
                        mod(i,3)==mod(t,3))
                        act(i) = 1;
                        Model_L.Refund{i}(id_sP_prev,act_pre(i)+1) = ...
                            Model_L.Refund{i}(id_sP_prev,act_pre(i)+1)-1;
                    end
                end
            end
        end
        if FDM
            Model_L = Obs_F(cf, Model_L, state_P);                          % belief update
            [state_P, packet_P, Packet_S] = Step_FDM(cf, Dis, state_P, act, H, t);
        else
            Model_L = Obs_D(cf, Model_L, state_P);                          % belief update
            [state_P, packet_P, Packet_S] = Step(cf, Dis, state_P, act, H, t);
        end
        act_pre = act;
        Buffer(1:end-1) = Buffer(1:end-1) - Packet_S.*cf.L_S;
        Buffer(2:end) = Buffer(2:end) + Packet_S.*cf.L_S;
        th_P = th_P + packet_P*cf.L_P;
    end
    th_S = Buffer(end);
end