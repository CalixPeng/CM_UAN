function pS = succProb(cf, Dis, PU, Tx_id, act, state_P, H, FDM, realtime)
    if FDM
        ch = mod(Tx_id,3);
        if(ch==0)
            ch = 3;
        end
        H = H{ch};
        act_ch = zeros(size(act));
        act_ch(ch:3:end) = act(ch:3:end);
        state_ch = zeros(size(state_P));
        state_ch(ch:3:end) = state_P(ch:3:end);
        Nf = cf.Nf(ch);
    else
        act_ch = act;
        state_ch = state_P;
        Nf = cf.Nf;
    end
    if(realtime)
        N_cs = 1;
    else
        N_cs = size(H.PP,3);
    end
    if(PU)                                                                  % Tx is a PU
        I = zeros(N_cs,cf.L_P);
        for i = 1:cf.Ns-1                                                   % interference due to SUs
            d_I = Dis.PS(Tx_id+1,i);
            if(act_ch(i)>0 && d_I<cf.T_slot*cf.c)
                d_dif = d_I - cf.dp(Tx_id);
                bit_f = max(1, floor(cf.R*d_dif/cf.c));
                bit_l = min(cf.L_P, ceil(cf.L_S(i)+cf.R*d_dif/cf.c));
                if(bit_f >= bit_l)
                    continue;
                else
                    if(realtime)
                        H_s = randsample(squeeze(H.PS(Tx_id+1,i,:)),...
                            bit_l-bit_f+1,true)';
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + cf.Ps*H_s.^2;
                    else
                        H_s = squeeze(H.PS(Tx_id+1,i,:));
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + ...
                            cf.Ps*repmat(H_s.^2,1,(bit_l-bit_f+1));
                    end
                end
            end
        end
        for i = 1:cf.Np-1                                                   % interference due to other PUs
            if(i==Tx_id)
                continue;
            end
            d_I = Dis.PP(Tx_id+1,i);
            if(state_ch(i)>0 && d_I<cf.T_slot*cf.c)
                d_dif = d_I - cf.dp(Tx_id);
                bit_f = max(1, floor(cf.R*d_dif/cf.c));
                bit_l = min(cf.L_P, ceil(cf.L_P + cf.R*d_dif/cf.c));
                if(bit_f >= bit_l)
                    continue;
                else
                    if(realtime)
                        H_s = randsample(squeeze(H.PP(i,Tx_id+1,:)),...
                            bit_l-bit_f+1,true)';
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + cf.Pp*H_s.^2;
                    else
                        H_s = squeeze(H.PP(i,Tx_id+1,:));
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + ...
                            cf.Pp*repmat(H_s.^2,1,(bit_l-bit_f+1));
                    end
                end
            end
        end
        if(realtime)
            H_s = randsample(squeeze(H.PP(Tx_id,Tx_id+1,:)),cf.L_P,true)';
            SINR = (cf.Pp*H_s.^2)./(Nf+I);
        else
            H_s = squeeze(H.PP(Tx_id,Tx_id+1,:));
            SINR = (cf.Pp*repmat(H_s.^2,1,cf.L_P))./(Nf+I);
            Type = zeros(1,cf.L_P);
        end
    else                                                                    % Tx is a SU
        if(Tx_id~=cf.Ns-1 && act_ch(Tx_id+1)>0)
            pS = 0;
            return;
        end
        I = zeros(N_cs,cf.L_S(Tx_id));
        for i = 1:cf.Np-1                                                   % interference due to PUs
            d_I = Dis.PS(i,Tx_id+1);
            if(state_ch(i)>0 && d_I<cf.T_slot*cf.c)
                d_dif = d_I - cf.ds(Tx_id);
                bit_f = max(1, floor(cf.R*d_dif/cf.c));
                bit_l = min(cf.L_S(Tx_id), ceil(cf.L_P + cf.R*d_dif/cf.c));
                if(bit_f >= bit_l)
                    continue;
                else
                    if(realtime)
                        H_s = randsample(squeeze(H.PS(i,Tx_id+1,:)), ...
                            bit_l-bit_f+1,true)';
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + cf.Pp*H_s.^2;
                    else
                        H_s = squeeze(H.PS(i,Tx_id+1,:));
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + ...
                            cf.Pp*repmat(H_s.^2,1,(bit_l-bit_f+1));
                    end
                end
            end
        end
        for i = 1:cf.Ns-1                                                   % interference due to other SUs
            if(i==Tx_id)
                continue;
            end
            d_I = Dis.SS(Tx_id+1, i);
            if(act_ch(i)>0 && d_I<cf.T_slot*cf.c)
                d_dif = d_I - cf.ds(Tx_id);
                bit_f = max(1, floor(cf.R*d_dif/cf.c));
                bit_l = min(cf.L_S(Tx_id), ceil(cf.L_S(i)+cf.R*d_dif/cf.c));
                if(bit_f >= bit_l)
                    continue;
                else
                    if(realtime)
                        H_s = randsample(squeeze(H.SS(i,Tx_id+1,:)), ...
                            bit_l-bit_f+1,true)';
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + cf.Ps*H_s.^2;
                    else
                        H_s = squeeze(H.SS(i,Tx_id+1,:));
                        I(:,bit_f:bit_l) = I(:,bit_f:bit_l) + ...
                            cf.Ps*repmat(H_s.^2,1,(bit_l-bit_f+1));
                    end
                end
            end
        end
        if(realtime)
            H_s = randsample(squeeze(H.SS(Tx_id,Tx_id+1,:)), ...
                cf.L_S(Tx_id),true)';
            SINR = (cf.Ps*H_s.^2)./(Nf+I);
        else
            H_s = squeeze(H.SS(Tx_id,Tx_id+1,:));
            SINR = (cf.Ps*repmat(H_s.^2,1,cf.L_S(Tx_id)))./(Nf+I);
            Type = zeros(1,cf.L_S(Tx_id));
        end
    end
    if(realtime)
        BER = qfunc(sqrt(2*SINR));
    else
        Type(1) = 1;
        for l = 2:size(Type,2)
            if SINR(1,l-1)==SINR(1,l)
                Type(l) = Type(l-1);
            else
                Type(l) = Type(l-1) + 1;
            end
        end
        BER = zeros(size(Type));
        for type = 1:max(Type)
            Id = find(Type==type);
            Samples = SINR(:,Id(1));
            mu = mean(log(Samples)); sigma = std(log(Samples));
            fun = @(x) qfunc(sqrt(2*x)).*exp(-(log(x)-mu).^2/(2*sigma^2)) ...
                ./(x*sigma*sqrt(2*pi));
            BER(Id) = integral(fun,0,Inf);
        end
    end
    pS = prod(1-BER);
end