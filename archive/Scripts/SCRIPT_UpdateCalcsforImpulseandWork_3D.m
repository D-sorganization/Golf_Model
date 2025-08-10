%Numerically Compute ZTCF and DELTA Linear Work


% ZTCF Script:
% Work is the dot product of force and velocity integrated over time.

% Create Scalar for Sample Time (Currently every 0.0001 seconds)
S=0.0001;

% Find Height
H=height(ZTCF);

for i=1:H
%Step 1 Import the data needed to generate the parameters that are
%integrated. For work you need a velocity and a force or torque. For
%Impulse you just need a force or sum of moments.

% Forces (Generate 1x3 array with force at time i)
FTemp=ZTCF{i,["TotalHandForceGlobal"]};
LHFTemp=ZTCF{i,["LHonClubFGlobal"]};
RHFTemp=ZTCF{i,["RHonClubFGlobal"]};
LEFTemp=ZTCF{i,["LArmonLForearmFGlobal"]};
REFTemp=ZTCF{i,["RArmonRForearmFGlobal"]};
LSFTemp=ZTCF{i,["LSonLArmFGlobal"]};
RSFTemp=ZTCF{i,["RSonRArmFGlobal"]};

%Sum of Moments (Angular Impulse Equivalent of Forces Above)
% SUMLSTemp=ZTCF{i,["SumofMomentsLSonLArm"]};
% SUMRSTemp=ZTCF{i,["SumofMomentsRSonRArm"]};
% SUMLETemp=ZTCF{i,["SumofMomentsLEonLForearm"]};
% SUMRETemp=ZTCF{i,["SumofMomentsREonRForearm"]};
SUMLHTemp=ZTCF{i,["SumofMomentsLHonClub"]};
SUMRHTemp=ZTCF{i,["SumofMomentsRHonClub"]};

%Torques (Angular Work Calculation)
TLSTemp=ZTCF{i,["LSonLArmTGlobal"]};
TRSTemp=ZTCF{i,["RSonRArmTGlobal"]};
TLETemp=ZTCF{i,["LArmonLForearmTGlobal"]};
TRETemp=ZTCF{i,["RArmonRForearmTGlobal"]};
TLHTemp=ZTCF{i,["LHonClubTGlobal"]};
TRHTemp=ZTCF{i,["RHonClubTGlobal"]};

%Write the Forces to Vectors
F(i,1:3)=FTemp;
LHF(i,1:3)=LHFTemp;
RHF(i,1:3)=RHFTemp;
LEF(i,1:3)=LEFTemp;
REF(i,1:3)=REFTemp;
LSF(i,1:3)=LSFTemp;
RSF(i,1:3)=RSFTemp;

%Write the SUM of moments on distal to vectors
% SUMLS(i,1:3)=SUMLSTemp;
% SUMRS(i,1:3)=SUMRSTemp;
% SUMLE(i,1:3)=SUMLETemp;
% SUMRE(i,1:3)=SUMRETemp;
SUMLH(i,1:3)=SUMLHTemp;
SUMRH(i,1:3)=SUMRHTemp;

%Write the global torques on distal to vectors
TLS(i,1:3)=TLSTemp;
TRS(i,1:3)=TRSTemp;
TLE(i,1:3)=TLETemp;
TRE(i,1:3)=TRETemp;
TLH(i,1:3)=TLHTemp;
TRH(i,1:3)=TRHTemp;

% Linear Velocities
VTemp=ZTCF{i,["MidpointVelocity"]};
LHVTemp=ZTCF{i,["LHVGlobal"]};
RHVTemp=ZTCF{i,["RHVGlobal"]};
LEVTemp=ZTCF{i,["LEVGlobal"]};
REVTemp=ZTCF{i,["REVGlobal"]};
LSVTemp=ZTCF{i,["LSVGlobal"]};
RSVTemp=ZTCF{i,["RSVGlobal"]};

%Angular Velocities
LSAVTemp=ZTCF{i,["LSAVGlobal"]};
RSAVTemp=ZTCF{i,["RSAVGlobal"]};
LEAVTemp=ZTCF{i,["LEAVGlobal"]};
REAVTemp=ZTCF{i,["REAVGlobal"]};
LHAVTemp=ZTCF{i,["LHAVGlobal"]};
RHAVTemp=ZTCF{i,["RHAVGlobal"]};

%Linear Dot Products
PTemp=dot(FTemp,VTemp);
LHPTemp=dot(LHFTemp,LHVTemp);
RHPTemp=dot(RHFTemp,RHVTemp);
LEPTemp=dot(LEFTemp,LEVTemp);
REPTemp=dot(REFTemp,REVTemp);
LSPTemp=dot(LSFTemp,LSVTemp);
RSPTemp=dot(RSFTemp,RSVTemp);

%Angular Dot Products
LSAPTemp=dot(TLSTemp,LSAVTemp);
RSAPTemp=dot(TRSTemp,RSAVTemp);
LEAPTemp=dot(TLETemp,LEAVTemp);
REAPTemp=dot(TRETemp,REAVTemp);
LHAPTemp=dot(TLHTemp,LHAVTemp);
RHAPTemp=dot(TRHTemp,RHAVTemp);

%Write the linear power vectors
P(i,1)=PTemp;
LHP(i,1)=LHPTemp;
RHP(i,1)=RHPTemp;
LEP(i,1)=LEPTemp;
REP(i,1)=REPTemp;
LSP(i,1)=LSPTemp;
RSP(i,1)=RSPTemp;

%Write the angular power vectors
LSAP(i,1)=LSAPTemp;
RSAP(i,1)=RSAPTemp;
LEAP(i,1)=LEAPTemp;
REAP(i,1)=REAPTemp;
LHAP(i,1)=LHAPTemp;
RHAP(i,1)=RHAPTemp;

end

% Cleanup
clear FTemp;
clear LHFTemp;
clear RHFTemp;
clear LEFTemp;
clear REFTemp;
clear LSFTemp;
clear RSFTemp;
clear VTemp;
clear LHVTemp;
clear RHVTemp;
clear LEVTemp;
clear REVTemp;
clear LSVTemp;
clear RSVTemp;
clear i;
clear H;
clear PTemp;
clear LHPTemp;
clear RHPTemp;
clear LEPTemp;
clear REPTemp;
clear LSPTemp;
clear RSPTemp;
clear SUMLSTemp;
clear SUMRSTemp;
clear SUMLETemp;
clear SUMRETemp;
clear SUMLHTemp;
clear SUMRHTemp;

clear LSAPTemp;
clear RSAPTemp;
clear LEAPTemp;
clear REAPTemp;
clear LHAPTemp;
clear RHAPTemp;
clear LSAVTemp;
clear RSAVTemp;
clear LEAVTemp;
clear REAVTemp;
clear LHAVTemp;
clear RHAVTemp;
clear TLETemp;
clear TRETemp;
clear TLSTemp;
clear TRSTemp;
clear TLHTemp;
clear TRHTemp;

% Numerically Integrate the quantities of interest for each joint
LinearWorkNumerical=S*cumtrapz(P);
LinearImpulseNumerical=S*cumtrapz(F);

LHLinearWorkNumerical=S*cumtrapz(LHP);
LHLinearImpulseNumerical=S*cumtrapz(LHF);
LHAngularImpulseNumerical=S*cumtrapz(SUMLH);
LHAngularWorkNumerical=S*cumtrapz(LHAP);

RHLinearWorkNumerical=S*cumtrapz(RHP);
RHLinearImpulseNumerical=S*cumtrapz(RHF);
RHAngularImpulseNumerical=S*cumtrapz(SUMRH);
RHAngularWorkNumerical=S*cumtrapz(RHAP);

LELinearWorkNumerical=S*cumtrapz(LEP);
LELinearImpulseNumerical=S*cumtrapz(LEF);
% LEAngularImpulseNumerical=S*cumtrapz(SUMLE);
LEAngularWorkNumerical=S*cumtrapz(LEAP);

RELinearWorkNumerical=S*cumtrapz(REP);
RELinearImpulseNumerical=S*cumtrapz(REF);
% REAngularImpulseNumerical=S*cumtrapz(SUMRE);
REAngularWorkNumerical=S*cumtrapz(REAP);

LSLinearWorkNumerical=S*cumtrapz(LSP);
LSLinearImpulseNumerical=S*cumtrapz(LSF);
% LSAngularImpulseNumerical=S*cumtrapz(SUMLS);
LSAngularWorkNumerical=S*cumtrapz(LSAP);

RSLinearWorkNumerical=S*cumtrapz(RSP);
RSLinearImpulseNumerical=S*cumtrapz(RSF);
% RSAngularImpulseNumerical=S*cumtrapz(SUMRS);
RSAngularWorkNumerical=S*cumtrapz(RSAP);

% Write Linear Work Values to Table
ZTCF.("LinearWorkonClub")=LinearWorkNumerical;
ZTCF.("LHLinearWorkonClub")=LHLinearWorkNumerical;
ZTCF.("RHLinearWorkonClub")=RHLinearWorkNumerical;
ZTCF.("LELinearWorkonForearm")=LELinearWorkNumerical;
ZTCF.("RELinearWorkonForearm")=RELinearWorkNumerical;
ZTCF.("LSLinearWorkonArm")=LSLinearWorkNumerical;
ZTCF.("RSLinearWorkonArm")=RSLinearWorkNumerical;

%Write Linear Impulse Values to Table
ZTCF.("LinearImpulseonClub")=LinearImpulseNumerical;
ZTCF.("LHLinearImpulseonClub")=LHLinearImpulseNumerical;
ZTCF.("RHLinearImpulseonClub")=RHLinearImpulseNumerical;
ZTCF.("LELinearImpulseonForearm")=LELinearImpulseNumerical;
ZTCF.("RELinearImpulseonForearm")=RELinearImpulseNumerical;
ZTCF.("LSLinearImpulseonArm")=LSLinearImpulseNumerical;
ZTCF.("RSLinearImpulseonArm")=RSLinearImpulseNumerical;

%Write Angular Impulse Values to Table
% ZTCF.("LSAngularImpulseonArm")=LSAngularImpulseNumerical;
% ZTCF.("RSAngularImpulseonArm")=RSAngularImpulseNumerical;
% ZTCF.("LEAngularImpulseonForearm")=LEAngularImpulseNumerical;
% ZTCF.("REAngularImpulseonForearm")=REAngularImpulseNumerical;
ZTCF.("LHAngularImpulseonClub")=LHAngularImpulseNumerical;
ZTCF.("RHAngularImpulseonClub")=RHAngularImpulseNumerical;

%Write Angular Work Values to Table
ZTCF.("LHAngularWorkonClub")=LHAngularWorkNumerical;
ZTCF.("RHAngularWorkonClub")=RHAngularWorkNumerical;
ZTCF.("LEAngularWorkonForearm")=LEAngularWorkNumerical;
ZTCF.("REAngularWorkonForearm")=REAngularWorkNumerical;
ZTCF.("LSAngularWorkonArm")=LSAngularWorkNumerical;
ZTCF.("RSAngularWorkonArm")=RSAngularWorkNumerical;

% Cleanup
clear LHLinearWorkNumerical;
clear LHLinearImpulseNumerical;
clear RHLinearWorkNumerical;
clear RHLinearImpulseNumerical;
clear LinearWorkNumerical;
clear LinearImpulseNumerical;
clear LELinearWorkNumerical;
clear LELinearImpulseNumerical;
clear RELinearWorkNumerical;
clear RELinearImpulseNumerical;
clear LSLinearWorkNumerical;
clear LSLinearImpulseNumerical;
clear RSLinearWorkNumerical;
clear RSLinearImpulseNumerical;
clear LHAngularWorkNumerical;
clear RHAngularWorkNumerical;
clear LEAngularWorkNumerical;
clear REAngularWorkNumerical;
clear LSAngularWorkNumerical;
clear RSAngularWorkNumerical;
clear F;
clear LHF;
clear RHF;
clear LEF;
clear REF;
clear LSF;
clear RSF;
clear SUMLE;
clear SUMLS;
clear SUMLH;
clear SUMRE;
clear SUMRS;
clear SUMRH;
clear TLS;
clear TRS;
clear TLE;
clear TRE;
clear TLH;
clear TRH;
clear LSAngularImpulseNumerical;
clear RSAngularImpulseNumerical;
clear LEAngularImpulseNumerical;
clear REAngularImpulseNumerical;
clear LHAngularImpulseNumerical;
clear RHAngularImpulseNumerical;

clear P;
clear LHP;
clear RHP;
clear LEP;
clear REP;
clear LSP;
clear RSP;
clear LSAP;
clear RSAP;
clear LEAP;
clear REAP;
clear LHAP;
clear RHAP;

clear S;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELTA Script
% Create Scalar for Sample Time (Currently every 0.0001 seconds)
S=0.0001;

% Find Height
H=height(DELTA);

for i=1:H
%Step 1 Import the data needed to generate the parameters that are
%integrated. For work you need a velocity and a force or torque. For
%Impulse you just need a force or sum of moments.

% Forces (Generate 1x3 array with force at time i)
FTemp=DELTA{i,["TotalHandForceGlobal"]};
LHFTemp=DELTA{i,["LHonClubFGlobal"]};
RHFTemp=DELTA{i,["RHonClubFGlobal"]};
LEFTemp=DELTA{i,["LArmonLForearmFGlobal"]};
REFTemp=DELTA{i,["RArmonRForearmFGlobal"]};
LSFTemp=DELTA{i,["LSonLArmFGlobal"]};
RSFTemp=DELTA{i,["RSonRArmFGlobal"]};

%Sum of Moments (Angular Impulse Equivalent of Forces Above)
% SUMLSTemp=DELTA{i,["SumofMomentsLSonLArm"]};
% SUMRSTemp=DELTA{i,["SumofMomentsRSonRArm"]};
% SUMLETemp=DELTA{i,["SumofMomentsLEonLForearm"]};
% SUMRETemp=DELTA{i,["SumofMomentsREonRForearm"]};
SUMLHTemp=DELTA{i,["SumofMomentsLHonClub"]};
SUMRHTemp=DELTA{i,["SumofMomentsRHonClub"]};

%Torques (Angular Work Calculation)
TLSTemp=DELTA{i,["LSonLArmTGlobal"]};
TRSTemp=DELTA{i,["RSonRArmTGlobal"]};
TLETemp=DELTA{i,["LArmonLForearmTGlobal"]};
TRETemp=DELTA{i,["RArmonRForearmTGlobal"]};
TLHTemp=DELTA{i,["LHonClubTGlobal"]};
TRHTemp=DELTA{i,["RHonClubTGlobal"]};

%Write the Forces to Vectors
F(i,1:3)=FTemp;
LHF(i,1:3)=LHFTemp;
RHF(i,1:3)=RHFTemp;
LEF(i,1:3)=LEFTemp;
REF(i,1:3)=REFTemp;
LSF(i,1:3)=LSFTemp;
RSF(i,1:3)=RSFTemp;

%Write the SUM of moments on distal to vectors
% SUMLS(i,1:3)=SUMLSTemp;
% SUMRS(i,1:3)=SUMRSTemp;
% SUMLE(i,1:3)=SUMLETemp;
% SUMRE(i,1:3)=SUMRETemp;
SUMLH(i,1:3)=SUMLHTemp;
SUMRH(i,1:3)=SUMRHTemp;

%Write the global torques on distal to vectors
TLS(i,1:3)=TLSTemp;
TRS(i,1:3)=TRSTemp;
TLE(i,1:3)=TLETemp;
TRE(i,1:3)=TRETemp;
TLH(i,1:3)=TLHTemp;
TRH(i,1:3)=TRHTemp;

% Velocities
VTemp=ZTCF{i,["MidpointVelocity"]};
LHVTemp=ZTCF{i,["LHVGlobal"]};
RHVTemp=ZTCF{i,["RHVGlobal"]};
LEVTemp=ZTCF{i,["LEVGlobal"]};
REVTemp=ZTCF{i,["REVGlobal"]};
LSVTemp=ZTCF{i,["LSVGlobal"]};
RSVTemp=ZTCF{i,["RSVGlobal"]};

%Angular Velocities
LSAVTemp=ZTCF{i,["LSAVGlobal"]};
RSAVTemp=ZTCF{i,["RSAVGlobal"]};
LEAVTemp=ZTCF{i,["LEAVGlobal"]};
REAVTemp=ZTCF{i,["REAVGlobal"]};
LHAVTemp=ZTCF{i,["LHAVGlobal"]};
RHAVTemp=ZTCF{i,["RHAVGlobal"]};

%Linear Dot Products
PTemp=dot(FTemp,VTemp);
LHPTemp=dot(LHFTemp,LHVTemp);
RHPTemp=dot(RHFTemp,RHVTemp);
LEPTemp=dot(LEFTemp,LEVTemp);
REPTemp=dot(REFTemp,REVTemp);
LSPTemp=dot(LSFTemp,LSVTemp);
RSPTemp=dot(RSFTemp,RSVTemp);

%Angular Dot Products
LSAPTemp=dot(TLSTemp,LSAVTemp);
RSAPTemp=dot(TRSTemp,RSAVTemp);
LEAPTemp=dot(TLETemp,LEAVTemp);
REAPTemp=dot(TRETemp,REAVTemp);
LHAPTemp=dot(TLHTemp,LHAVTemp);
RHAPTemp=dot(TRHTemp,RHAVTemp);

%Write the linear power vectors
P(i,1)=PTemp;
LHP(i,1)=LHPTemp;
RHP(i,1)=RHPTemp;
LEP(i,1)=LEPTemp;
REP(i,1)=REPTemp;
LSP(i,1)=LSPTemp;
RSP(i,1)=RSPTemp;

%Write the angular power vectors
LSAP(i,1)=LSAPTemp;
RSAP(i,1)=RSAPTemp;
LEAP(i,1)=LEAPTemp;
REAP(i,1)=REAPTemp;
LHAP(i,1)=LHAPTemp;
RHAP(i,1)=RHAPTemp;

end

% Cleanup
clear FTemp;
clear LHFTemp;
clear RHFTemp;
clear LEFTemp;
clear REFTemp;
clear LSFTemp;
clear RSFTemp;
clear VTemp;
clear LHVTemp;
clear RHVTemp;
clear LEVTemp;
clear REVTemp;
clear LSVTemp;
clear RSVTemp;
clear i;
clear H;
clear PTemp;
clear LHPTemp;
clear RHPTemp;
clear LEPTemp;
clear REPTemp;
clear LSPTemp;
clear RSPTemp;
clear SUMLSTemp;
clear SUMRSTemp;
clear SUMLETemp;
clear SUMRETemp;
clear SUMLHTemp;
clear SUMRHTemp;

clear LSAPTemp;
clear RSAPTemp;
clear LEAPTemp;
clear REAPTemp;
clear LHAPTemp;
clear RHAPTemp;
clear LSAVTemp;
clear RSAVTemp;
clear LEAVTemp;
clear REAVTemp;
clear LHAVTemp;
clear RHAVTemp;
clear TLETemp;
clear TRETemp;
clear TLSTemp;
clear TRSTemp;
clear TLHTemp;
clear TRHTemp;

% Numerically Integrate the quantities of interest for each joint
LinearWorkNumerical=S*cumtrapz(P);
LinearImpulseNumerical=S*cumtrapz(F);

LHLinearWorkNumerical=S*cumtrapz(LHP);
LHLinearImpulseNumerical=S*cumtrapz(LHF);
LHAngularImpulseNumerical=S*cumtrapz(SUMLH);
LHAngularWorkNumerical=S*cumtrapz(LHAP);

RHLinearWorkNumerical=S*cumtrapz(RHP);
RHLinearImpulseNumerical=S*cumtrapz(RHF);
RHAngularImpulseNumerical=S*cumtrapz(SUMRH);
RHAngularWorkNumerical=S*cumtrapz(RHAP);

LELinearWorkNumerical=S*cumtrapz(LEP);
LELinearImpulseNumerical=S*cumtrapz(LEF);
% LEAngularImpulseNumerical=S*cumtrapz(SUMLE);
LEAngularWorkNumerical=S*cumtrapz(LEAP);

RELinearWorkNumerical=S*cumtrapz(REP);
RELinearImpulseNumerical=S*cumtrapz(REF);
% REAngularImpulseNumerical=S*cumtrapz(SUMRE);
REAngularWorkNumerical=S*cumtrapz(REAP);

LSLinearWorkNumerical=S*cumtrapz(LSP);
LSLinearImpulseNumerical=S*cumtrapz(LSF);
% LSAngularImpulseNumerical=S*cumtrapz(SUMLS);
LSAngularWorkNumerical=S*cumtrapz(LSAP);

RSLinearWorkNumerical=S*cumtrapz(RSP);
RSLinearImpulseNumerical=S*cumtrapz(RSF);
% RSAngularImpulseNumerical=S*cumtrapz(SUMRS);
RSAngularWorkNumerical=S*cumtrapz(RSAP);

% Write Linear Work Values to Table
DELTA.("LinearWorkonClub")=LinearWorkNumerical;
DELTA.("LHLinearWorkonClub")=LHLinearWorkNumerical;
DELTA.("RHLinearWorkonClub")=RHLinearWorkNumerical;
DELTA.("LELinearWorkonForearm")=LELinearWorkNumerical;
DELTA.("RELinearWorkonForearm")=RELinearWorkNumerical;
DELTA.("LSLinearWorkonArm")=LSLinearWorkNumerical;
DELTA.("RSLinearWorkonArm")=RSLinearWorkNumerical;

%Write Linear Impulse Values to Table
DELTA.("LinearImpulseonClub")=LinearImpulseNumerical;
DELTA.("LHLinearImpulseonClub")=LHLinearImpulseNumerical;
DELTA.("RHLinearImpulseonClub")=RHLinearImpulseNumerical;
DELTA.("LELinearImpulseonForearm")=LELinearImpulseNumerical;
DELTA.("RELinearImpulseonForearm")=RELinearImpulseNumerical;
DELTA.("LSLinearImpulseonArm")=LSLinearImpulseNumerical;
DELTA.("RSLinearImpulseonArm")=RSLinearImpulseNumerical;

%Write Angular Impulse Values to Table
% DELTA.("LSAngularImpulseonArm")=LSAngularImpulseNumerical;
% DELTA.("RSAngularImpulseonArm")=RSAngularImpulseNumerical;
% DELTA.("LEAngularImpulseonForearm")=LEAngularImpulseNumerical;
% DELTA.("REAngularImpulseonForearm")=REAngularImpulseNumerical;
DELTA.("LHAngularImpulseonClub")=LHAngularImpulseNumerical;
DELTA.("RHAngularImpulseonClub")=RHAngularImpulseNumerical;

%Write Angular Work Values to Table
DELTA.("LHAngularWorkonClub")=LHAngularWorkNumerical;
DELTA.("RHAngularWorkonClub")=RHAngularWorkNumerical;
DELTA.("LEAngularWorkonForearm")=LEAngularWorkNumerical;
DELTA.("REAngularWorkonForearm")=REAngularWorkNumerical;
DELTA.("LSAngularWorkonArm")=LSAngularWorkNumerical;
DELTA.("RSAngularWorkonArm")=RSAngularWorkNumerical;

% Cleanup
clear LHLinearWorkNumerical;
clear LHLinearImpulseNumerical;
clear RHLinearWorkNumerical;
clear RHLinearImpulseNumerical;
clear LinearWorkNumerical;
clear LinearImpulseNumerical;
clear LELinearWorkNumerical;
clear LELinearImpulseNumerical;
clear RELinearWorkNumerical;
clear RELinearImpulseNumerical;
clear LSLinearWorkNumerical;
clear LSLinearImpulseNumerical;
clear RSLinearWorkNumerical;
clear RSLinearImpulseNumerical;
clear LHAngularWorkNumerical;
clear RHAngularWorkNumerical;
clear LEAngularWorkNumerical;
clear REAngularWorkNumerical;
clear LSAngularWorkNumerical;
clear RSAngularWorkNumerical;
clear F;
clear LHF;
clear RHF;
clear LEF;
clear REF;
clear LSF;
clear RSF;
clear SUMLE;
clear SUMLS;
clear SUMLH;
clear SUMRE;
clear SUMRS;
clear SUMRH;
clear TLS;
clear TRS;
clear TLE;
clear TRE;
clear TLH;
clear TRH;
clear LSAngularImpulseNumerical;
clear RSAngularImpulseNumerical;
clear LEAngularImpulseNumerical;
clear REAngularImpulseNumerical;
clear LHAngularImpulseNumerical;
clear RHAngularImpulseNumerical;
clear P;
clear LHP;
clear RHP;
clear LEP;
clear REP;
clear LSP;
clear RSP;
clear LSAP;
clear RSAP;
clear LEAP;
clear REAP;
clear LHAP;
clear RHAP;
clear S;
