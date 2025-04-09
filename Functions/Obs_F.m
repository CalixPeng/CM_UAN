function Model_L = Obs_F(cf, Model_L, state_P)
    for i = 1:cf.Ns-1
        if isempty(Model_L.id_P{i})
            continue;
        end
        ch = mod(i,3);
        if(ch==0)
            ch = 3;
        end
        States_P = Model_L.States_P{i};
        States_P(:,1) = min(States_P(:,1),1);
        state_ch = zeros(size(state_P));
        state_ch(ch:3:end) = state_P(ch:3:end);
        state_local = state_ch(Model_L.id_P{i});
        state_local(1) = min(state_local(1),1);
        id_sP = ismember(States_P,state_local,'rows');
        belief_obs = zeros(size(Model_L.belief{i}));
        belief_obs(id_sP) = 1;
        if sum(Model_L.belief{i}.*belief_obs)~=0
            Model_L.belief{i} = Model_L.belief{i}.*belief_obs;
        else
            Model_L.belief{i} = belief_obs;
        end
        Model_L.belief{i} = Model_L.belief{i}/sum(Model_L.belief{i});
    end
end