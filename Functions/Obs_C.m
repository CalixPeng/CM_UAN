function belief_new = Obs_C(cf, Model_L, States_P, belief, state_P)
    Coverage = zeros(1,cf.Np);
    for i = 1:cf.Ns-1
        Coverage(Model_L.id_P{i}) = true;
    end
    Coverage = Coverage(1:cf.Np-1);
    States_P(:,1) = max(States_P(:,1),0);
    state_P_obs = zeros(1,cf.Np-1);
    state_P_obs(Coverage==true) = state_P(Coverage==true);
    state_P_obs(1) = max(state_P_obs(1),0);
    id_sP = ismember(States_P,state_P_obs,'rows');
    belief_obs = zeros(size(belief));
    belief_obs(id_sP) = 1;
    if sum(belief.*belief_obs)~=0
        belief_new = belief.*belief_obs;
    else
        belief_new = belief_obs;
    end
    belief_new = belief_new/sum(belief_new);
end