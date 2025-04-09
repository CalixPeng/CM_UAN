function Model_L = localModel(cf, Dis, States_P, PER, FDM)
    for i = 1:cf.Ns-1
        id_P = find(Dis.PS(:,i)<cf.T_slot*cf.c);
        if(id_P(end)==cf.Np)
            id_P(end) = [];
        end
        if FDM
            id_P(mod(id_P,3)~=mod(i,3)) = [];
            if isempty(id_P)
                States_P_local = [];
                P = [];
            else
                States_P_local = formStates_FDM(length(id_P));
                P = transMatrix_FDM(cf, cf.alpha_1, cf.alpha_2, ...
                    id_P, i, States_P_local, PER, States_P);
            end
        else
            States_P_local = formStates(length(id_P));
            P = transMatrix(cf, cf.alpha_1, cf.alpha_2, id_P, i, ...
                States_P_local, PER, States_P);
        end
        Model_L.id_P{i} = id_P;
        Model_L.States_P{i} = States_P_local;
        Model_L.P{i} = P;
    end
end