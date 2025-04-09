% Thorp: absorption loss in dB/kyd; f is in kHz.
function alpha = absorption(f)
    alpha = 0.11*f.^2./(1+f.^2) + 44*f.^2./(4100+f.^2) + ...
        2.75*10^(-4)*f.^2 + 0.003;
end