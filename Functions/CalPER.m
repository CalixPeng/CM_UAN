function [PER, I_map] = CalPER(cf, Dis, States_P, H_model, FDM)
    N_sP = size(States_P,1); N_act = 2^(cf.Ns-1);
    PER = zeros(N_sP, cf.Np-1, N_act);
	for a = 1:N_act
        act = dec2bin(a-1,cf.Ns-1)-'0';
        for i = 1:N_sP
            state_P = States_P(i,:);
            for j = 1:cf.Np-1
                PER(i,j,a) = succProb(cf, Dis, true, j, act, state_P, ...
                    H_model, FDM, false);
            end
        end
	end
	I_map = zeros(cf.Ns-1, cf.Np-1);
    for i = 1:cf.Ns-1
        for j = 1:cf.Np-1
            act = zeros(1,cf.Ns-1); act(i) = 1;
            state_P = zeros(1,cf.Np-1); state_P(j) = 1;
            pS = succProb(cf,Dis,true,j,act,state_P,H_model,FDM,false);
            if(pS<0.95)
                I_map(i,j) = 1;
            end
        end
    end
end