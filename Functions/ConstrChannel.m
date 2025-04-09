function cf = ConstrChannel(cf)
    cf.fc = [cf.fc-1.4e3, cf.fc, cf.fc+1.4e3];
    cf.B = 1.2e3;
    cf.R = 0.3*cf.R;
    cf.L_P = 0.3*cf.L_P;
    cf.L_S = 0.3*cf.L_S;
    cf.T_slot = (max(cf.dp)/cf.c + cf.L_P/cf.R)*1.2;
    cf.Nf = zeros(1,3);
    for ch = 1:3
        cf.Nf(ch) = N_PSD(cf.fc(ch));
    end
end