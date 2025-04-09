function [state_P_n, packet_P, Packet_S] = Step(cf, Dis, state_P, act, H, t)
    N_start = floor((t-1)*cf.T_slot/cf.del_t)+1;
    N_end = ceil(t*cf.T_slot/cf.del_t);
    H_real.PP = H.PP(:,:,N_start:N_end);
    H_real.SS = H.SS(:,:,N_start:N_end);
    H_real.PS = H.PS(:,:,N_start:N_end);
    packet_P = 0;
    state_P_n = state_P;
    %% packet arrival
    if state_P(1)==-2
        state_P_n(1) = -1;
    elseif state_P(1)==-1
        if(rand()<cf.alpha_2)
            state_P_n(1) = 1;
        else
            state_P_n(1) = 0;
        end
    elseif state_P(1)==0
        if(rand()<cf.alpha_1)
            state_P_n(1) = 1;
        else
            state_P_n(1) = 0;
        end
    else
        state_P_n(1) = -2;
    end
    %% packet loss
    for i = 1:cf.Np-1
        if(state_P(i)==1)
            if(i~=1)
                state_P_n(i) = 0;
            end
            pS = succProb(cf, Dis, true, i, act, state_P, H_real, false, true);
            if(rand()<pS)
                if i~=cf.Np-1
                    state_P_n(i+1) = 1;
                else
                    packet_P = 1;
                end
            end
        end
    end
    Packet_S = zeros(1,cf.Ns-1);
    for i = 1:cf.Ns-1
        if(act(i)==1)
            pS = succProb(cf, Dis, false, i, act, state_P, H_real, false, true);
            if(rand()<pS)
                Packet_S(i) = 1;
            end
        end
    end
end