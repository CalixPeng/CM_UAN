function [H, H_model] = ChannelSim(cf, Dis, ch)
    if nargin==3
        f = cf.fc(ch);
    else
        f = cf.fc;
    end
    N_sample = 1000;
    Loc_sample = randsample(cf.N_cs, N_sample);
    sig2s = 1.125; sig2b = sig2s/2;
    B_delp = 5e-4; Sp = 30;
    mu_p= .2/Sp; nu_p= 1e-6;
    %% channels between PUs
    H.PP = zeros(cf.Np,cf.Np,cf.N_cs);
    for i = 1:cf.Np
        for j = i+1:cf.Np
            [H_0,tau,theta,ns,nb,hp] = mpgeometry(cf, f, Dis.PP(i,j));
            sig_delp = sqrt(1/cf.c^2*((2*sin(theta)).^2).*(ns*sig2s+nb*sig2b));
            rho_p = exp(-((2*pi*f).^2)*(sig_delp.^2/2));
            Bp = ((2*pi*f*sig_delp).^2).*B_delp;
            gamma_bar_p = mu_p + mu_p*Sp*rho_p;
            sig_p = sqrt(0.5*(mu_p.^2.*Sp.*(1-rho_p.^2)+Sp.*nu_p.^2));
            alpha_p = exp(-pi*Bp*cf.del_t);
            L = length(tau);
            del_gamma = zeros(L,cf.N_cs);
            gamma = zeros(L,cf.N_cs);
            gamma(:,1) = gamma_bar_p';
            for l = 1:L
                for t = 2:cf.N_cs
                    wp = sqrt(sig_p(l)^2*(1-alpha_p(l)^2))*(randn()+1j*randn());
                    del_gamma(l,t) = alpha_p(l)*del_gamma(l,t-1) + wp;
                    gamma(l,t) = gamma_bar_p(l) + del_gamma(l,t);
                end
            end
            H.PP(i,j,:) = abs(H_0*hp.*exp(-1j*2*pi*f*tau(l))*gamma);
            H.PP(j,i,:) = H.PP(i,j,:);
        end
    end
    H_model.PP = H.PP(:,:,Loc_sample);
    %% channels between SUs
    H.SS = zeros(cf.Ns,cf.Ns,cf.N_cs);
    for i = 1:cf.Ns
        for j = i+1:cf.Ns
            [H_0,tau,theta,ns,nb,hp] = mpgeometry(cf, f, Dis.SS(i,j));
            sig_delp = sqrt(1/cf.c^2*((2*sin(theta)).^2).*(ns*sig2s+nb*sig2b));
            rho_p = exp(-((2*pi*f).^2)*(sig_delp.^2/2));
            Bp = ((2*pi*f*sig_delp).^2).*B_delp;
            gamma_bar_p = mu_p + mu_p*Sp*rho_p;
            sig_p = sqrt(0.5*(mu_p.^2.*Sp.*(1-rho_p.^2)+Sp.*nu_p.^2));
            alpha_p = exp(-pi*Bp*cf.del_t);
            L = length(tau);
            del_gamma = zeros(L,cf.N_cs);
            gamma = zeros(L,cf.N_cs);
            gamma(:,1) = gamma_bar_p';
            for l = 1:L
                for t = 2:cf.N_cs
                    wp = sqrt(sig_p(l)^2*(1-alpha_p(l)^2))*(randn()+1j*randn());
                    del_gamma(l,t) = alpha_p(l)*del_gamma(l,t-1) + wp;
                    gamma(l,t) = gamma_bar_p(l) + del_gamma(l,t);
                end
            end
            H.SS(i,j,:) = abs(H_0*hp.*exp(-1j*2*pi*f*tau(l))*gamma);
            H.SS(j,i,:) = H.SS(i,j,:);
        end
    end
    H_model.SS = H.SS(:,:,Loc_sample);
    %% channels between PUs and SUs
    H.PS = zeros(cf.Np,cf.Ns,cf.N_cs);
    for i = 1:cf.Np
        for j = 1:cf.Ns
            [H_0,tau,theta,ns,nb,hp] = mpgeometry(cf, f, Dis.PS(i,j));
            sig_delp = sqrt(1/cf.c^2*((2*sin(theta)).^2).*(ns*sig2s+nb*sig2b));
            rho_p = exp(-((2*pi*f).^2)*(sig_delp.^2/2));
            Bp = ((2*pi*f*sig_delp).^2).*B_delp;
            gamma_bar_p = mu_p + mu_p*Sp*rho_p;
            sig_p = sqrt(0.5*(mu_p.^2.*Sp.*(1-rho_p.^2)+Sp.*nu_p.^2));
            alpha_p = exp(-pi*Bp*cf.del_t);
            L = length(tau);
            del_gamma = zeros(L,cf.N_cs);
            gamma = zeros(L,cf.N_cs);
            gamma(:,1) = gamma_bar_p';
            for l = 1:L
                for t = 2:cf.N_cs
                    wp = sqrt(sig_p(l)^2*(1-alpha_p(l)^2))*(randn()+1j*randn());
                    del_gamma(l,t) = alpha_p(l)*del_gamma(l,t-1) + wp;
                    gamma(l,t) = gamma_bar_p(l) + del_gamma(l,t);
                end
            end
            H.PS(i,j,:) = abs(H_0*hp.*exp(-1j*2*pi*f*tau(l))*gamma);
        end
    end
    H_model.PS = H.PS(:,:,Loc_sample);
end