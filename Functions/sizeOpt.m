function cf = sizeOpt(cf, Dis, Model_L, H_model)
    for i = 1:cf.Ns-1
        P = Model_L.P{i}(:,:,1);
        [V,D] = eig(P');
        for j = 1:size(P,1)
            if(abs(D(j,j)-1)<1e-3)
                ssd = V(:,j);
                ssd = ssd/sum(ssd);
                break;
            end
        end
        L_choice = zeros(1,2*length(Model_L.id_P{i}));
        L_choice(1) = floor((max(cf.dp)-cf.ds(i))*cf.R/1500 + cf.L_P);
        num = 1;
        for j = 1:length(Model_L.id_P{i})
            id_p = Model_L.id_P{i}(j);
            if(Dis.PS(id_p,i+1)>cf.ds(i)) % PU TX to SU RX
                l = floor((Dis.PS(id_p,i+1)-cf.ds(i))/cf.c*cf.R);
                L_choice(num+1) = l;
                num = num + 1;
            end
            if(Dis.PS(id_p+1,i)<cf.dp(id_p)) % SU TX to PU RX
                l = floor((cf.dp(id_p)-Dis.PS(id_p+1,i))/cf.c*cf.R);
                L_choice(num+1) = l;
                num = num + 1;
            end
        end
        L_choice(num+1:end) = [];
        L_choice(L_choice>L_choice(1)) = [];
        L_choice = unique(L_choice);
        cf_temp = cf;
        V = zeros(size(L_choice));
        for l = 1:length(L_choice)
            cf_temp.L_S(i) = L_choice(l);
            [E_P, E] = stateGain(cf_temp, Dis, i, Model_L.id_P{i}, ...
                Model_L.States_P{i}, H_model);
            f = -diag(ssd)*P*(E(:,2)-E(:,1));
            A = (-diag(ssd)*P*(E_P(:,2)-E_P(:,1)))';
            b = (1-cf.PU_constr)*ssd'*(P*E_P(:,1));
            lb = zeros(size(Model_L.States_P{i},1),1);
            ub = ones(size(Model_L.States_P{i},1),1);
            options = optimoptions('linprog','Display','none');
            [~, fval] = linprog(f, A, b, [], [], lb, ub, options);
            V(l) = -fval;
        end
        cf.L_S(i) = L_choice(find(V==max(V),1));
    end
end

function [E_P, E] = stateGain(cf, Dis, id, id_P, States_P, H_model)
    Act = [0, 1]';
    E_gain = zeros(size(States_P,1),size(Act,1),2);                         % 1st page for PU, 2nd for SU
    for i = 1:size(States_P,1)
        state_P = zeros(1,cf.Np-1);
        if(id_P(end)==cf.Np)
            state_P(id_P(1:end-1)) = States_P(i,:);
        else
            state_P(id_P) = States_P(i,:);
        end
        for a = 1:size(Act,1)
            act = zeros(1,cf.Ns-1);
            act(id) = Act(a);
            Ep = 0;
            for j = 1:length(state_P)
                if(state_P(j)==1)
                    Ep = Ep + succProb(cf, Dis, true, j, act, state_P, ...
                        H_model, false, false)*cf.L_P;
                end
            end
            if(Act(a)==0)
                Es = 0;
            else
                Es = succProb(cf, Dis, false, id, act, state_P, ...
                    H_model, false, false)*cf.L_S(id);
            end
            E_gain(i,a,1) = Ep;
            E_gain(i,a,2) = Es;
        end
    end
    E_P = E_gain(:,:,1); E = sum(E_gain,3);
end