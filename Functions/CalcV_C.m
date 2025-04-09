function Actions = CalcV_C(cf, N_sP, Act, E, E_P, P_super, V_P_only)
    N_s = size(E,1); N_act = size(Act,1);
    Feasible = FeasibleAct(cf, N_sP, N_s/N_sP, Act);
    V = zeros(N_s,N_act,N_act,cf.N_slot);
    V_P = zeros(N_s,N_act,N_act,cf.N_slot);
    Actions = ones(N_s,N_act,N_act,cf.N_slot);
    for t = cf.N_slot:-1:1
        for s = 1:N_s                                                       % state of t-2
            for a1 = 1:N_act                                                % action of t-2
                if(Feasible(s,a1)==0)
                    continue;
                end
                for a2 = 1:N_act                                            % action of t-1
                    b1 = P_super(s,:,a1);
                    b1_feasible = b1.*Feasible(:,a2)';
                    b2 = b1*P_super(:,:,a2);
                    value_max = 0;
                    index_max = 1;
                    for a3 = 1:N_act
                        b2_feasible = b2.*Feasible(:,a3)';
                        if(t==cf.N_slot)
                            value_P = b2_feasible*E_P(:,a3);
                        else
                            value_P = b2_feasible*E_P(:,a3) + ...
                                b1_feasible*V_P(:,a2,a3,t+1);
                        end
                        if(b2*V_P_only(:,t)>0 && value_P/...
                            (b2*V_P_only(:,t))<cf.PU_constr && a3~=1)
                            continue;
                        end
                        if(t==cf.N_slot)
                            value = b2_feasible*E(:,a3);
                        else
                            value = b2_feasible*E(:,a3) + ...
                                b1_feasible*V(:,a2,a3,t+1);
                        end
                        if(value > value_max)
                            value_max = value;
                            index_max = a3;
                        end
                    end
                    V(s,a1,a2,t) = value_max;
                    Actions(s,a1,a2,t) = index_max;
                    b2_feasible = b2.*Feasible(:,index_max)';
                    if(t==cf.N_slot)
                        V_P(s,a1,a2,t) = b2_feasible*E_P(:,index_max);
                    else
                        V_P(s,a1,a2,t) = b2_feasible*E_P(:,index_max) + ...
                            b1_feasible*V_P(:,a2,index_max,t+1);
                    end
                end
            end
        end
    end
end

function Feasible = FeasibleAct(cf, N_sP, N_sS, Act)
    States_S = [ones(N_sS,1), dec2bin(0:N_sS-1, cf.Ns-2)-'0'];
    Feasible = zeros(size(States_S,1), size(Act,1));
    for i = 1:size(States_S,1)
        for j = 1:size(Act,1)
            valid = true;
            for k = 1:size(States_S,2)
                if(Act(j,k)==1 && States_S(i,k)==0)
                    valid = false;
                    break;
                elseif(Act(j,k)==1 && k<size(States_S,2) && ...
                    States_S(i,k+1)==1)
                    valid = false;
                    break;
                end
            end
            Feasible(i,j) = valid;
        end
    end
    Feasible = repelem(Feasible,N_sP,1);
end