function [th_P, th_S] = algo_TDM(cf, Dis, H, Model_L)
    th_P = 0;
    for i = 1:cf.Ns-1
        N_P = length(Model_L.id_P{i});
        id = ismember(Model_L.States_P{i},zeros(1,N_P),'rows');
        Model_L.belief{i} = zeros(1,size(Model_L.States_P{i},1));
        Model_L.belief{i}(id) = 1;
    end
    state_P = zeros(1,cf.Np-1);
    act_pre = zeros(1, cf.Ns-1);
    Buffer = zeros(1,cf.Ns); Buffer(1) = Inf;
    for t = 1:cf.N_slot
        act = zeros(1, cf.Ns-1);
        for i = 1:cf.Ns-1
            Model_L.belief{i} = Model_L.belief{i} * ...
                Model_L.P{i}(:,:,act_pre(i)+1);
            if(rand()<(cf.PU_constr)^(1/(cf.Ns-1)) || Buffer(i)<cf.L_S(i))
                continue;
            end
            prob = 0;
            for j = 1:length(Model_L.belief{i})
                if(sum(Model_L.States_P{i}(j,:)>0)>0)
                    prob = prob + Model_L.belief{i}(j);
                end
            end
            if(prob < 0.5)
                act(i) = 1;
            end
        end
        Model_L = Obs_D(cf, Model_L, state_P);
        [state_P, packet_P, Packet_S] = Step(cf, Dis, state_P, act, H, t);
        act_pre = act;
        Buffer(1:end-1) = Buffer(1:end-1) - Packet_S.*cf.L_S;
        Buffer(2:end) = Buffer(2:end) + Packet_S.*cf.L_S;
        th_P = th_P + packet_P*cf.L_P;
    end
    th_S = Buffer(end);
end