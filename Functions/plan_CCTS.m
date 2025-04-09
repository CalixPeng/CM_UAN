function [Action_CCTS, Act_C] = plan_CCTS(cf, Dis, States_P, P, H_model)
    Act_C = formStates(cf.Ns-1);
    Act_C(Act_C<0) = 0; Act_C = unique(Act_C, 'rows');
    P_super = SuperTrans(cf, Dis, States_P, Act_C, P, H_model);
    E_gain = stateExp(cf, Dis, 1:cf.Np-1, 1:cf.Ns-1, States_P, ...
        Act_C, H_model, false);
    N_sP = size(States_P,1); N_sS = 2^(cf.Ns-2);
    E = repmat(sum(E_gain,3), N_sS, 1);
    E_P = repmat(E_gain(:,:,1), N_sS, 1);
    V_P_only = CalcVP(cf.N_slot, E_P, P_super);
    Action_CCTS = CalcV_C(cf, N_sP, Act_C, E, E_P, P_super, V_P_only);
end