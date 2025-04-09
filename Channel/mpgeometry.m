% geometric multipath structure
% Input:
% h: depth of water [m]
% ht: depth of tx [m]
% hr: depth of rx [m]
% d: distance (horizontal) [m]
% f: frequency [Hz]: use lower band-edge freq. to get max. number of paths;
% k: spreading factor
% c: speed of sound in water [m/s], used to calculate reflcoef 
% c2: speed of sound in bottom [m/s], used to calculate reflcoef (1300 for soft, 1800 for hard bottom)
% cut: stop after a multipath arrival has strength below that of direct arrival divided by cut
% Output:
% l: path lengths
% tau: path delays, relative to direct (add l(1)/c to get absolute values)
% Gamma: cumulative reflection coefficient 
% theta: angles of path arrivals
% ns/nb: number of surface/bottom reflections
% hp: path gains
% Calls: absorption.m, reflcoeff.m
% Note: frequency is used only to determine the number of multipaths as that for which path gains remain above a threshold;
% one could have used a fixed number of paths instead

function [H_0, tau, theta, ns, nb, hp] = mpgeometry(cf, f, d)
    k = 1.5; c = 1500; c2 = 1300; 
    h = cf.depth; ht = cf.depth_user; hr = cf.depth_user; cut = 10;
    a = 10^(absorption(f/1000)/10);
    a = a^(1/1000);

    nr = 0; % direct path, no reflections
    theta(1) = atan((ht-hr)/d);
    l(1) = sqrt((ht-hr)^2+d^2);
    A(1) = (l(1)^k).*(a.^l(1));
    G(1) = 1/sqrt(A(1));
    H_0 = G(1);
    Gamma(1) = 1;
    hp(1) = 1;
    ns(1) = 0; nb(1) = 0;
    path = 0; % begin with surface reflection;
    while min(abs(G))>=G(1)/cut
        nr = nr + 1;
        p = 2*nr;
        first = path(1); last = path(end); 
        nb(p) = sum(path); ns(p) = nr-nb(p);
        heff = (1-first)*ht + first*(h-ht) + (nr-1)*h + ...
            (1-last)*hr + last*(h-hr);
        l(p) = sqrt(heff^2+d^2);
        theta(p) = atan(heff/d);
        % corrected by Parastoo to address the grazing angle
        if first==1 
            theta(p) = -theta(p);
        end
        tau(p) = (l(p)-l(1))/c;
        A(p) = (l(p)^k)*(a^l(p));
        % refl. coeff. calulated as f. of grazing angle
        Gamma(p) = reflcoeff(abs(theta(p)),c,c2)^nb(p)*(-1)^ns(p);
        G(p) = Gamma(p)/sqrt(A(p));
        hp(p) = Gamma(p)/sqrt(((l(p)/l(1))^k)*(a^(l(p)-l(1))));

        p = 2*nr+1; path = not(path);
        first = path(1); last = path(end); 
        nb(p) = sum(path); ns(p) = nr-nb(p);
        heff = (1-first)*ht + first*(h-ht) + (nr-1)*h + ...
            (1-last)*hr + last*(h-hr);
        l(p) = sqrt(heff^2+d^2);
        theta(p) = atan(heff/d); 
        if first==1
            theta(p) = -theta(p); 
        end
        tau(p) = (l(p)-l(1))/c;
        A(p) = (l(p)^k)*(a^l(p));
        Gamma(p) = reflcoeff(abs(theta(p)),c,c2)^nb(p)*(-1)^ns(p);
        G(p) = Gamma(p)/sqrt(A(p)); 
        hp(p) = Gamma(p)/sqrt(((l(p)/l(1))^k)*(a^(l(p)-l(1))));
        path = [path, not(path(end))];
    end
end