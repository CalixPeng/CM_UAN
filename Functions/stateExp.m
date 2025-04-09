function E_gain = stateExp(cf, Dis, id_P, id_S, States_P, Act, H_model, FDM)
    E_gain = zeros(size(States_P,1),size(Act,1),2);                         % 1st page for PU, 2nd for SU
    for i = 1:size(States_P,1)
        state_P = zeros(1,cf.Np-1);
        if(id_P(end)==cf.Np)
            state_P(id_P(1:end-1)) = States_P(i,:);
        else
            state_P(id_P) = States_P(i,:);
        end
        for d = 1:size(Act,1)
            act = zeros(1,cf.Ns-1);
            act(id_S) = Act(d,:);
            if(States_P(i,end)==0)
                Ep = 0;
            else
                Ep = succProb(cf, Dis, true, id_P(end), act, state_P, ...
                    H_model, FDM, false)*cf.L_P;
            end
            if(Act(d,end)==0)
                Es = 0;
            else
                Es = succProb(cf, Dis, false, id_S(end), act, state_P, ...
                    H_model, FDM, false)*cf.L_S(id_S(end));
            end
            E_gain(i,d,1) = Ep;
            E_gain(i,d,2) = Es;
        end
    end
end