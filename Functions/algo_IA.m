function [th_P, th_S] = algo_IA(cf, Dis, H, Model_L, I_map)
	cf.alpha_1 = 2*cf.alpha_1; cf.alpha_2 = 2*cf.alpha_2;
	th_P = 0;
	state_P = zeros(1,cf.Np-1);
    Buffer = zeros(1,cf.Ns); Buffer(1) = Inf;
	for t = 1:cf.N_slot
		if mod(t,2)==1														% slot for control message
			continue;
		end
        act = zeros(1, cf.Ns-1);
		for i = 1:cf.Ns-1
			state_P_I = state_P & I_map(i,:);    
			state_P_I = state_P_I(Model_L.id_P{i});
			if ~any(state_P_I>0) && Buffer(i)>=cf.L_S(i)
				if rand()<(1/4)
					act(i) = 1;
				end
			end
		end
        [state_P, packet_P, Packet_S] = Step(cf, Dis, state_P, act, H, t);
        Buffer(1:end-1) = Buffer(1:end-1) - Packet_S.*cf.L_S;
        Buffer(2:end) = Buffer(2:end) + Packet_S.*cf.L_S;
        th_P = th_P + packet_P*cf.L_P;
	end
    th_S = Buffer(end);
end