function Model_L = Obs_D(cf, Model_L, state_P)
    for i = 1:cf.Ns-1
        States_P = Model_L.States_P{i};
        States_P(:,1) = max(States_P(:,1),0);
        state_local = state_P(Model_L.id_P{i});
        state_local(1) = max(state_local(1),0);
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