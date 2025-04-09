function [state_P_n, packet_P, Packet_S] = Step_FDM(cf, Dis, state_P, act, H, t)
    N_start = floor((t-1)*cf.T_slot/cf.del_t)+1;
    N_end = ceil(t*cf.T_slot/cf.del_t);
    for ch = 1:3
        H{ch}.PP = H{ch}.PP(:,:,N_start:N_end);
        H{ch}.SS = H{ch}.SS(:,:,N_start:N_end);
        H{ch}.PS = H{ch}.PS(:,:,N_start:N_end);
    end
    packet_P = 0;
    state_P_n = state_P;
    %% packet arrival
    if state_P(1)==0
        if(rand()<cf.alpha_1)
            state_P_n(1) = 1;
        else
            state_P_n(1) = 0;
        end
    elseif state_P(1)==1
        state_P_n(1) = 2;
    elseif state_P(1)==2
        state_P_n(1) = 3;
    else
        if(rand()<cf.alpha_2)
            state_P_n(1) = 1;
        else
            state_P_n(1) = 0;
        end
    end
    %% packet loss
    for i = cf.Np-1:-1:1
        if(state_P(i)>0)
            if(i~=1)
                state_P_n(i) = 0;
            end
            pS = succProb(cf,Dis,true,i,act,state_P,H,true,true);
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
            pS = succProb(cf,Dis,false,i,act,state_P,H,true,true);
            if(rand()<pS)
                Packet_S(i) = 1;
            end
        end
    end
end