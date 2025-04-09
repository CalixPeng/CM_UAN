function V_P_only = CalcVP(N_slot, E_P, P)
    N_s = size(P,1);
    V_P_only = zeros(N_s,N_slot);
    for i = 1:N_s
        V_P_only(i,N_slot) = E_P(i,1);
    end
    for t = N_slot-1:-1:1
        for i = 1:N_s
            V_P_only(i,t) = E_P(i,1)+P(i,:,1)*V_P_only(:,t+1);
        end
    end
end