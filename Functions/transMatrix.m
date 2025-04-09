function P = transMatrix(cf, alpha_1, alpha_2, id_P, id_S, States_P, ...
    PER, States_P_global)
    P = zeros(size(States_P,1),size(States_P,1),2^(length(id_S)));
    for k = 1:size(P,3)
        act = zeros(1, cf.Ns-1);
        act(id_S) = dec2bin(k-1,length(id_S))-'0';
        id_act = bin2dec(int2str(act)) + 1;
        for i = 1:size(P,1)
            state_P = zeros(1,cf.Np-1);
            state_P(id_P) = States_P(i,:);
            if nargin==7
                id_sP = ismember(States_P,state_P,'rows');
            else
                state_P(state_P<0) = 0;
                if state_P(2)==1
                    state_P(1) = -2;
                elseif state_P(3)==1
                    state_P(1) = -1;
                end
                id_sP = ismember(States_P_global,state_P,'rows');
            end
            pS = PER(id_sP,:,id_act);
            pS = pS(id_P);
            for j = 1:size(P,2)
                if(States_P(i,1)==-2)
                    if(States_P(j,1)==-1)
                        prob = 1;
                    else
                        P(i,j,k) = 0;
                        continue;
                    end
                elseif(States_P(i,1)==-1)
                    if(States_P(j,1)==0)
                        prob = 1 - alpha_2;
                    elseif(States_P(j,1)==1)
                        prob = alpha_2;
                    else
                        P(i,j,k) = 0;
                        continue;
                    end
                elseif(States_P(i,1)==0)
                    if(States_P(j,1)==0)
                        prob = 1 - alpha_1;
                    elseif(States_P(j,1)==1)
                        prob = alpha_1;
                    else
                        P(i,j,k) = 0;
                        continue;
                    end
                else
                    if(States_P(j,1)==-2)
                        prob = 1;
                    else
                        P(i,j,k) = 0;
                        continue;
                    end
                end
                for n = 1:length(id_P)-1
                    if(States_P(i,n)~=1)
                        if(States_P(j,n+1)==1)
                            prob = 0;
                            break;
                        end
                    else
                        if(States_P(j,n+1)==1)
                            prob = prob * pS(n);
                        else
                            prob = prob * (1-pS(n));
                        end
                    end
                end
                P(i,j,k) = prob;
            end
        end
    end
end