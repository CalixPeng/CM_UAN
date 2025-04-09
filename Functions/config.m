cf.Np = 5;                                                                  % number of PUs
cf.Ns = 5;                                                                  % number of SUs

cf.depth = 200;                                                             % depth of sea bed
cf.depth_user = cf.depth/2;                                                 % depth of users

cf.Dp = 10e3;                                                               % end-to-end PU distance
cf.Ds = 10e3;                                                               % end-to-end SU distance
cf.dp = cf.Dp/(cf.Np-1)*ones(1,cf.Np-1);                                    % per hop distance (PU)
cf.ds = cf.Ds/(cf.Ns-1)*ones(1,cf.Ns-1);                                    % per hop distance (SU)
cf.alpha_1 = 0.05;                                                          % new packet arrival rate 
cf.alpha_2 = 0.2;                                                           % continue transmission prob
cf.PU_constr = 0.8;                                                         % acceptable throughput loss of PUs

cf.c = 1500;                                                                % speed of sound
cf.fc = 32e3;                                                               % center freq
cf.B = 4e3;                                                                 % bandwidth
cf.R = 10e3;                                                                % transmission rate
cf.L_P = 8*1.5e3;                                                           % PU packet size (bits)
cf.L_S = 8*1.5e3*ones(1,cf.Ns-1);                                           % SU packet size (bits)
cf.Pp = 10^(130/10);                                                        % each acoustic TX power (PU)
cf.Ps = 10^(130/10);                                                        % each acoustic TX power (SU)

cf.T_slot = (max(cf.dp)/cf.c + cf.L_P/cf.R)*1.2;                            % slot time
cf.N_slot = 1000;
cf.del_t = 0.1;                                                             % channel sample period
cf.N_cs = ceil(cf.N_slot*cf.T_slot/cf.del_t);                               % number of channel sample

cf.Nf = N_PSD(cf.fc);                                                       % noise PSD