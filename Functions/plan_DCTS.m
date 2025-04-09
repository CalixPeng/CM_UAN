function Action_DCTS = plan_DCTS(cf, Dis, H_model, Model_L, I_map, FDM)
    Action_DCTS = cell(1,cf.Ns-1);
    for i = 1:cf.Ns-1
        if isempty(Model_L.id_P{i})
            continue;
        end
        if(sum(I_map(i,:))==0)
            PU_constr = 0;
        else
            PU_constr = cf.PU_constr^(1/sum(sum(I_map,2)>0));
        end
        E_gain = stateExp(cf, Dis, Model_L.id_P{i}, i, ...
            Model_L.States_P{i}, [0,1]', H_model, FDM);
        E_P = E_gain(:,:,1); E = sum(E_gain,3);
        V_P_only = CalcVP(cf.N_slot, E_P, Model_L.P{i});
        Action_DCTS{i} = CalcV_D(cf.N_slot, i, Model_L.P{i}, E, E_P, ...
            V_P_only, PU_constr, FDM);
    end
end