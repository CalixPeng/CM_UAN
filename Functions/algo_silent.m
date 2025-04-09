function th_P = algo_silent(cf, Dis, H)
    state_P = zeros(1,cf.Np-1);
    th_P = 0;
    for t = 1:cf.N_slot
        [state_P, packet_P, ~] = Step(cf, Dis, state_P, ...
            zeros(1,cf.Ns-1), H, t);
        th_P = th_P + packet_P*cf.L_P;
    end
end