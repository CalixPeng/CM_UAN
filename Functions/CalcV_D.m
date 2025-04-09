function Actions = CalcV_D(N_slot, id_S, P, E, E_P, V_P_only, PU_constr, FDM)
    Act = [0, 1]';
    N_s = size(P,1);
    V = zeros(N_s,size(Act,1),N_slot);
    V_P = zeros(N_s,size(Act,1),N_slot);
    Actions = zeros(N_s,size(Act,1),N_slot);
    for t = N_slot:-1:1
        for i = 1:N_s                                                       % previous state
            for k = 1:size(Act,1)                                           % previous action
                if(mod(id_S,3)~=mod(t-1,3) && Act(k)==1 && ~FDM)
                    continue;
                end
                b = P(i,:,k);
                value_max = 0;
                index_max = 1;
                for d = 1:size(Act,1)
                    if(mod(id_S,3)~=mod(t,3) && Act(d)==1 && ~FDM)
                        continue;
                    end
                    if(t==N_slot)
                        value_P = b*E_P(:,d);
                    else
                        value_P = b*E_P(:,d) + b*V_P(:,d,t+1);
                    end
                    if(b*V_P_only(:,t)>0 && value_P/(b*V_P_only(:,t))<...
                        PU_constr && d~=1)
                        continue;
                    end
                    if(t==N_slot)
                        value = b*E(:,d);
                    else
                        value = b*E(:,d) + b*V(:,d,t+1);
                    end
                    if(value > value_max)
                        value_max = value;
                        index_max = d;
                    end
                end
                V(i,k,t) = value_max;
                Actions(i,k,t) = Act(index_max);
                if(t==N_slot)
                    V_P(i,k,t) = b*E_P(:,index_max);
                else
                    V_P(i,k,t) = b*E_P(:,index_max)+b*V_P(:,index_max,t+1);
                end
            end
        end
    end
end