function [chisqResidualMatrix,PKalman,threshold] = teChisqDetector(ssid_est,NoiseVariance)
%TECHISQDETECTOR Compute various parameters for chi-squares detector for
%the TEP. Namely, given an estimation of the system in (ssid_est),
%it returns the residual's covariance matrix (chisqResidualMatrix), the
%Kalman filter matrix (PKalman) and a suitable threshold for chi-squares
%detector (threshold).

[~,~,PKalman]       = kalman(ss(ssid_est.A,[ssid_est.B,eye(size(ssid_est.A))],ssid_est.C,0,ssid_est.Ts),   diag(0.01),  NoiseVariance, 0);
chisqResidualMatrix = ssid_est.C*PKalman*ssid_est.C' + NoiseVariance;
threshold           = 2*gammaincinv(0.9,9,'lower');

end