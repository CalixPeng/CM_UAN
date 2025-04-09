function [th_P,th_S] = algo_CCTS(cf, Dis, H, Model_L, P, States_P, ...
    Act, Action_CCTS)
    th_P = 0;
    N_sP = size(States_P,1); N_sS = 2^(cf.Ns-2);
    States_S = [ones(N_sS,1), dec2bin(0:N_sS-1, cf.Ns-2)-'0'];
    Index_sP = zeros(1,cf.N_slot); Index_sS = zeros(1,cf.N_slot);
    Index_act = zeros(1,cf.N_slot); Index_act(1:2) = 1;
    state_P = zeros(1, cf.Np-1); state_S = States_S(1,:);
    id_sP = ismember(States_P, state_P, 'rows');
    Belief = zeros(N_sP,cf.N_slot); Belief(id_sP,1) = 1;
    Buffer = zeros(1,cf.Ns); Buffer(1) = inf;
    for t = 1:cf.N_slot
        Index_sP(t) = find(ismember(States_P,state_P,'rows'));
        Index_sS(t) = find(ismember(States_S,state_S,'rows'));
        Belief(:,t) = Obs_C(cf, Model_L, States_P, Belief(:,t), state_P);
        if(t<cf.N_slot-1)
            id_sP = randsample(1:N_sP, 1, true, Belief(:,t));
            Index_act(t+2) = Action_CCTS((Index_sS(t)-1)*N_sP+id_sP,...
                Index_act(t), Index_act(t+1), t+2);
            Belief(:,t+1) = Belief(:,t)'*P(:,:,Index_act(t));
        end
        act = Act(Index_act(t), :);
		act = act & (Buffer(1:end-1)>=cf.L_S);
        [state_P, packet_P, Packet_S] = Step(cf, Dis, state_P, act, H, t);
        Buffer(1:end-1) = Buffer(1:end-1) - Packet_S.*cf.L_S;
        Buffer(2:end) = Buffer(2:end) + Packet_S.*cf.L_S;
        state_S = (Buffer(1:end-1)>=cf.L_S);
        th_P = th_P + packet_P*cf.L_P;
    end
    th_S = Buffer(end);
end