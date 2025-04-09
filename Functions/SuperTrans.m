function P_super = SuperTrans(cf, Dis, States_P, Act, P, H_model)
    N_sP = size(States_P,1); N_sS = 2^(cf.Ns-2); N_s = N_sP * N_sS;
    States_S = [ones(N_sS,1), dec2bin(0:N_sS-1, cf.Ns-2)-'0'];
    Id_Act = bin2dec(int2str(Act)) + 1; N_act = length(Id_Act);
    P = P(:,:,Id_Act);
    P_super = zeros(N_s, N_s, N_act);
    for a = 1:N_act
        act = Act(a,:);
        for i = 1:N_sP
            for i_n = 1:N_sP
                prob_p = P(i,i_n,a);
                if(prob_p==0)
                    continue;
                end
                for j = 1:N_sS
                    if any(States_S(j,:)-act<0)
                        continue;
                    end
                    state_ns = States_S(j,:) - act;
                    state_ns(1) = 1;
                    id_TX = find(act(1:end-1)==1);
                    N_TX = length(id_TX);
                    if(N_TX==0)
                        j_n = find(ismember(States_S,state_ns,'rows'));
                        P_super((j-1)*N_sP+i,(j_n-1)*N_sP+i_n,a) = prob_p;
                    else
                        pS = zeros(1,N_TX);
                        for m = 1:N_TX
                            pS(m) = succProb(cf, Dis, false, id_TX(m),...
                                act, States_P(i,:), H_model, false, false);
                        end
                        for m = 0:2^N_TX-1
                            state_part = dec2bin(m,N_TX) - '0';
                            prob_s = 1;
                            for n = 1:N_TX
                                if(state_part(n)==1)
                                    prob_s = prob_s * pS(n);
                                    state_ns(id_TX(n)+1) = 1;
                                else
                                    prob_s = prob_s * (1-pS(n));
                                end
                            end
                            j_n = find(ismember(States_S,state_ns,'rows'));
                            P_super((j-1)*N_sP+i,(j_n-1)*N_sP+i_n,a) = ...
                                prob_p * prob_s;
                        end
                    end
                end
            end
        end
    end
end