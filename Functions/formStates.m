function States_P = formStates(N_tP)
    States_P = zeros(4*2^(N_tP-1), N_tP);
    count = 0;
    for s1 = -2:1
        for i = 0:2^(N_tP-1)-1
            States_P(count+1,1) = s1;
            States_P(count+1,2:end) = dec2bin(i, N_tP-1) - '0';
            valid = true;
            if(States_P(count+1,1)==-2)
                if(N_tP>=3 && States_P(count+1,3)==1)
                    valid = false;
                end
                if(N_tP>=4 && States_P(count+1,4)==1)
                    valid = false;
                end
            elseif(States_P(count+1,1)==-1)
                if(N_tP>=2 && States_P(count+1,2)==1)
                    valid = false;
                end
                if(N_tP>=4 && States_P(count+1,4)==1)
                    valid = false;
                end
                if(N_tP>=5 && States_P(count+1,5)==1)
                    valid = false;
                end
            elseif(States_P(count+1,1)==0)
                if(N_tP>=2 && States_P(count+1,2)==1)
                    valid = false;
                end
                if(N_tP>=3 && States_P(count+1,3)==1)
                    valid = false;
                end
            end
            if(N_tP==2 && sum(States_P(count+1,:)==1)>1)
                valid = false;
            end
            for j = 1:N_tP-2
                if(sum(States_P(count+1,j:j+2))>1)
                    valid = false;
                    break;
                end
            end
            if(valid)
                count = count + 1;
            end
        end
    end
    States_P(count+1:end,:) = [];
end