function Dis = iniLoc(cf)
    theta = pi/4;
    Loc_p = zeros(cf.Np,2); Loc_s = zeros(cf.Ns,2);
    dp_cum = [0, cumsum(cf.dp)]; ds_cum = [0, cumsum(cf.ds)];
    Loc_p(:,1) = dp_cum - mean(dp_cum);
    Loc_s(:,1) = cos(theta) * (ds_cum-mean(ds_cum));
    Loc_s(:,1) = Loc_s(:,1) + cf.dp(ceil(cf.Np/2))/2*ones(cf.Ns,1);
    Loc_s(:,2) = sin(theta) * (ds_cum-mean(ds_cum));
    Dis.PP = zeros(cf.Np, cf.Np);
    for i = 1:cf.Np
        for j = 1:cf.Np
            Dis.PP(i,j) = norm(Loc_p(i,:)-Loc_p(j,:));
        end
    end
    Dis.SS = zeros(cf.Ns, cf.Ns);
    for i = 1:cf.Ns
        for j = 1:cf.Ns
            Dis.SS(i,j) = norm(Loc_s(i,:)-Loc_s(j,:));
        end
    end
    Dis.PS = zeros(cf.Np, cf.Ns);
    for i = 1:cf.Np
        for j = 1:cf.Ns
            Dis.PS(i,j) = norm(Loc_p(i,:)-Loc_s(j,:));
        end
    end
end