function States_P = formStates_FDM(N_tP)
    States_P = zeros(4*2^(N_tP-1), N_tP);
    count = 0;
    for s1 = 0:3
        for i = 0:2^(N_tP-1)-1
            States_P(count+1,1) = s1;
            States_P(count+1,2:end) = dec2bin(i, N_tP-1) - '0';
            count = count + 1;
        end
    end
end