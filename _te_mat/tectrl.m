function [u, datao] = tectrl(y, ysp, datai)
%TECTRL Tennessee-Eastman controller code. This function computes all the
%controller inputs based on the system outputs.

% Initialise the controller states if datai is not provided.
if nargin < 3
    datai = struct();
    datai.u = [61.9047843720191;53.9634022144125;37.5126486239401;59.7194064175035;22.2100000000000;48.9993753842970;38.1450502612975;45.3990121551797;47.4460000000000;32.6439885135059;13.8707016886903;50];
    datai.error = zeros(17,1);       % sp - meas errors for the velpi controllers
    datai.fp = 0;                    % Fp0
    datai.Eadj = 0;                  % Eadj0
    datai.r1 = 0.0025;               % r1_0
    datai.r2 = 36.64;                % r2_0
    datai.r3 = 45.09;                % r3_0
    datai.r4 = 0.0935;               % r4_0
    datai.r5 = 0.0034;               % r5_0
    datai.r6 = 0.2516;               % r6_0
    datai.r7 = 0.2295;               % r7_0
    datai.SepTempSp = 80.1;          % SP17_0
end

% Initialise outputs.
u       = zeros(12,1);
datao   = datai;

%% TEMPERATURE
%   xmeas9, directly to xmv10.
%   y(7), ysp(9), u(10), data.error(1) for the velpi
Kc_temp = -8;
Ti_temp = 7.5/60;
Ts_temp = 5e-4;
lo_temp = 0;
hi_temp = 100;
    % velpi
err_temp = ysp(9) - y(7);
delta_xmv10 = Kc_temp*(err_temp + (Ts_temp/Ti_temp)*err_temp - datai.error(1));
xmv10_current = delta_xmv10 + datai.u(10);
    % controller saturation
xmv10_current = ctrlsat(lo_temp, hi_temp, xmv10_current);
u(10) = datai.u(10);
    % Update data
datao.u(10) = xmv10_current;
datao.error(1) = err_temp;

%% PRODUCTION RATE
%   xmeas17, to Fp + Feedforward gain Kp
%   y(13), ysp(1), data.error(2) for the velpi
Kp_prod = 100/22.89;
Kc_prod = 3.2;
Ti_prod = 120/60;
Ts_prod = 5e-4;
lo_prod = -30;
hi_prod = 30;
    % velpi
err_prod = ysp(1) - y(13);
delta_fp = Kc_prod*(err_prod + (Ts_prod/Ti_prod)*err_prod - datai.error(2));
fp_current = delta_fp + datai.fp;
    % controller saturation
fp_current = ctrlsat(lo_prod, hi_prod, fp_current);
fp = datai.fp + Kp_prod*ysp(1);
    % update data
datao.fp = fp_current;
datao.error(2) = err_prod;

%% REACTOR PRESSURE
%   ysp(5)
%   xmeas7 [y(5)], to r5 (first stage)
%   xmeas10 [y(8), purge rate], to xmv6 [u(6)] (second stage)
Kc_rpress = -1e-4;
Ti_rpress = 20/60;
Ts_rpress = 5e-4;
lo_rpress = 0;
hi_rpress = 100;
err_rpress = ysp(5) - y(5);
delta_r5 = Kc_rpress*(err_rpress + (Ts_rpress/Ti_rpress)*err_rpress - datai.error(3));
r5_current = delta_r5 + datai.r5;
    % controller saturation
r5_current = ctrlsat(lo_rpress, hi_rpress, r5_current);
r5 = datai.r5;
%r5 = r5_current;
    % Update data
datao.error(3) = err_rpress;
datao.r5 = r5_current;
    % Second stage
r5 = r5*fp;
Kc_purge = 0.01;
Ti_purge = 0.001/60;
Ts_purge = 5e-4;
lo_purge = 0;
hi_purge = 100;
err_purge = r5 - y(8);
delta_xmv6 = Kc_purge*(err_purge + (Ts_purge/Ti_purge)*err_purge - datai.error(4));
xmv6_current = delta_xmv6 + datai.u(6);
    % controller saturation
xmv6_current = ctrlsat(lo_purge, hi_purge, xmv6_current);
u(6) = datai.u(6);
    % Update data
datao.u(6) = xmv6_current;
datao.error(4) = err_purge;

%% SEPARATOR LEVEL
%   ysp(3)
%   xmeas12 [y(10)], to r6 (first stage)
%   xmeas14 [y(11)], to xmv7 (second stage)
Kc_seplevel = -1e-3;
Ti_seplevel = 200/60;
Ts_seplevel = 5e-4;
lo_seplevel = 0;
hi_seplevel = 100;
err_seplevel = ysp(3) - y(10);
delta_r6 = Kc_seplevel*(err_seplevel + (Ts_seplevel/Ti_seplevel)*err_seplevel - datai.error(5));
r6_current = delta_r6 + datai.r6;
    % controller saturation
r6_current = ctrlsat(lo_seplevel, hi_seplevel, r6_current);
r6 = datai.r6;
    % Update data
datao.r6 = r6_current;
datao.error(5) = err_seplevel;
    % Second stage [SEPARATOR FLOWRATE]
r6 = r6*fp;
Kc_sepfr = 4e-4;
Ti_sepfr = 0.001/60;
Ts_sepfr = 5e-4;
lo_sepfr = 0;
hi_sepfr = 100;
err_sepfr = r6 - y(11);
delta_xmv7 = Kc_sepfr*(err_sepfr + (Ts_sepfr/Ti_sepfr)*err_sepfr - datai.error(6));
xmv7_current = delta_xmv7 + datai.u(7);
    % controller saturation
xmv7_current = ctrlsat(lo_sepfr, hi_sepfr, xmv7_current);
u(7) = datai.u(7);
    % Update data
datao.error(6) = err_sepfr;
datao.u(7) = xmv7_current;

%% REACTOR LEVEL
%   ysp(4)
%   xmeas8 [y(6)], to SepTempSP (first stage)
%   xmeas11 [y(9)], to xmv11 (second stage)
Kc_rlevel = 0.8;
Ti_rlevel = 60/60;
Ts_rlevel = 5e-4;
lo_rlevel = 0;
hi_rlevel = 120;
err_rlevel = ysp(4) - y(6);
delta_SepTempSp = Kc_rlevel*(err_rlevel + (Ts_rlevel/Ti_rlevel)*err_rlevel - datai.error(7));
SepTempSp_current = delta_SepTempSp + datai.SepTempSp;
    % controller saturation
SepTempSp_current = ctrlsat(lo_rlevel, hi_rlevel, SepTempSp_current);
SepTempSp = datai.SepTempSp;
    % Update data
datao.error(7) = err_rlevel;
datao.SepTempSp = SepTempSp_current;
    % Second stage [SEPARATOR TEMPERATURE]
Kc_septemp = -4;
Ti_septemp = 15/60;
Ts_septemp = 5e-4;
lo_septemp = 0;
hi_septemp = 100;
err_septemp = SepTempSp - y(9);
delta_xmv11 = Kc_septemp*(err_septemp + (Ts_septemp/Ti_septemp)*err_septemp - datai.error(8));
xmv11_current = delta_xmv11 + datai.u(11);
    % controller saturation
xmv11_current = ctrlsat(lo_septemp, hi_septemp, xmv11_current);
u(11) = datai.u(11);
    % Update data
datao.u(11) = xmv11_current;
datao.error(8) = err_septemp;

%% STRIPPER LEVEL
%   ysp(2)
%   xmeas15 [y(12)], to r7 (first stage)
%   xmeas17 [y(13)], to xmv8 (second stage)
Kc_striplev = -2e-4;
Ti_striplev = 200/60;
Ts_striplev = 5e-4;
lo_striplev = 0;
hi_striplev = 100;
err_striplev = ysp(2) - y(12);
delta_r7 = Kc_striplev*(err_striplev + (Ts_striplev/Ti_striplev)*err_striplev - datai.error(9));
r7_current = delta_r7 + datai.r7;
    % controller saturation
r7_current = ctrlsat(lo_striplev, hi_striplev, r7_current);
r7 = datai.r7;
    % Update data
datao.error(9) = err_striplev;
datao.r7 = r7_current;
    % Second stage [STRIPPER FLOWRATE]
r7 = r7*fp;
Kc_stripfr = 4e-4;
Ti_stripfr = 0.001/60;
Ts_stripfr = 5e-4;
lo_stripfr = 0;
hi_stripfr = 100;
err_stripfr = r7 - y(13);
delta_xmv8 = Kc_stripfr*(err_stripfr + (Ts_stripfr/Ti_stripfr)*err_stripfr - datai.error(10));
xmv8_current = delta_xmv8 + datai.u(8);
    % controller saturation
xmv8_current = ctrlsat(lo_stripfr, hi_stripfr, xmv8_current);
u(8) = datai.u(8);
    % Update data
datao.u(8) = xmv8_current;
datao.error(10) = err_stripfr;

%% YA and YAC CONTROL
%   xmeas23 [y(14)], xmeas25 [y(15)], to yA and yAc (first stage, measurement
%   processing)
yAc = y(14) + y(15);
yA  = 100*y(14)/yAc;
%   Second stage
%   ysp(7), yA to Loop14
Kc_yA = 2e-4;
Ti_yA = 1;
Ts_yA = 5e-4;
err_yA = ysp(7) - yA;
Loop14 = Kc_yA*(err_yA + (Ts_yA/Ti_yA)*err_yA - datai.error(11));
datao.error(11) = err_yA;
%   ysp(8), yAC to Loop15
Kc_yac = 3e-4;
Ti_yac = 2;
Ts_yac = 5e-4;
err_yac = ysp(8) - yAc;
Loop15 = Kc_yac*(err_yac + (Ts_yac/Ti_yac)*err_yac - datai.error(12));
datao.error(12) = err_yac;
%   Third stage -- ratio trimming
%   Loop14, Loop15 to r1, r4
r1 = Loop14 + datai.r1;
r4 = Loop15 - Loop14 + datai.r4;
datao.r4 = r4;
datao.r1 = r1;
%   Fourth stage
%   r1, xmeas1 [y(1)] to xmv3
r1 = r1*fp;
Kc_afr = 0.01;
Ti_afr = 0.001/60;
Ts_afr = 5e-4;
lo_afr = 0;
hi_afr = 100;
err_afr = r1 - y(1);
delta_xmv3 = Kc_afr*(err_afr + (Ts_afr/Ti_afr)*err_afr - datai.error(13));
xmv3_current = delta_xmv3 + datai.u(3);
    % controller saturation
xmv3_current = ctrlsat(lo_afr, hi_afr, xmv3_current);
u(3) = datai.u(3);
    % Update data
datao.u(3) = xmv3_current;
datao.error(13) = err_afr;
%   r4, xmeas4 [y(4)] to xmv4
r4 = r4*fp;
Kc_cfr = 0.003;
Ti_cfr = 0.001/60;
Ts_cfr = 5e-4;
lo_cfr = 0;
hi_cfr = 100;
err_cfr = r4 - y(4);
delta_xmv4 = Kc_cfr*(err_cfr + (Ts_cfr/Ti_cfr)*err_cfr - datai.error(14));
xmv4_current = delta_xmv4 + datai.u(4);
    % controller saturation
xmv4_current = ctrlsat(lo_cfr, hi_cfr, xmv4_current);
u(4) = datai.u(4);
    % Update data
datao.u(4) = xmv4_current;
datao.error(14) = err_cfr;

%% PERC G IN PRODUCT CONTROL
%   ysp(6), xmeas40 [y(16)] to Eadj
Kc_percg = -0.4;
Ti_percg = 100/60;
Ts_percg = 5e-4;
err_percg = ysp(6) - y(16);
delta_Eadj = Kc_percg*(err_percg + (Ts_percg/Ti_percg)*err_percg - datai.error(15));
Eadj_current = delta_Eadj + datai.Eadj;
Eadj = datai.Eadj;
    % Update data
datao.Eadj = Eadj_current;
datao.error(15) = err_percg;

%% FEEDFORWARD (for D FEED RATE & E FEED RATE)
%   ysp(6), Eadj, fp to r2, r3
r2 = polyval([1.5192e-003  5.9446e-001  2.7690e-001], ysp(6)) - 32*Eadj/fp;
r3 = polyval([-1.1377e-003 -8.0893e-001  9.1060e+001], ysp(6)) + 46*Eadj/fp;

%TODO
%r2 = data.r2 + r2;
datao.r2 = r2;
%r3 = data.r3 + r3;
datao.r3 = r3;

%% D FEED RATE
%   r2, xmeas2 [y(2)] to xmv1
r2 = fp*r2;
Kc_dfr = 1.6e-6;
Ti_dfr = 0.001/60;
Ts_dfr = 5e-4;
lo_dfr = 0;
hi_dfr = 100;
err_dfr = r2 - y(2);
delta_xmv1 = Kc_dfr*(err_dfr + (Ts_dfr/Ti_dfr)*err_dfr - datai.error(16));
xmv1_current = delta_xmv1 + datai.u(1);
    % controller saturation
xmv1_current = ctrlsat(lo_dfr, hi_dfr, xmv1_current);
u(1) = datai.u(1);
    % Update data
datao.error(16) = err_dfr;
datao.u(1) = xmv1_current;

%% E FEED RATE
%   r3, xmeas3 [y(3)] to xmv2
r3 = r3*fp;
Kc_efr = 1.8e-6;
Ti_efr = 0.001/60;
Ts_efr = 5e-4;
lo_efr = 0;
hi_efr = 100;
err_efr = r3 - y(3);
delta_xmv2 = Kc_efr*(err_efr + (Ts_efr/Ti_efr)*err_efr - datai.error(17));
xmv2_current = delta_xmv2 + datai.u(2);
    % controller saturatin
xmv2_current = ctrlsat(lo_efr, hi_efr, xmv2_current);
u(2) = datai.u(2);
    % Update data
datao.error(17) = err_efr;
datao.u(2) = xmv2_current;

%% CONSTANT CONTROL INPUTS
u(5)    = ysp(10);      % xmv5
u(9)    = ysp(11);      % xmv9
u(12)   = ysp(12);      % xmv12


function ulim = ctrlsat(lo, hi, u)
%CTRLSAT Saturates control output given limits hi and lo

if u < lo
    ulim = lo;
elseif u > hi
    ulim = hi;
else
    ulim = u;
end



