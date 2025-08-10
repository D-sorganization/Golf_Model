%Calculate the Maximum Speeds and the Times They Occur

%Generate CHS Array
h=height(BASEQ);
for i=1:h
CHSTemp=BASEQ{i,["CHS (mph)"]};
CHS(i,1)=CHSTemp;
end

%Find Max CHS Value
MaxCHS=max(CHS);
SummaryTable.("MaxCHS")=MaxCHS;

%Generate Hand Speed Array
for i=1:h
HSTemp=BASEQ{i,["Hand Speed (mph)"]};
HS(i,1)=HSTemp;
end

%Find Max Hand Speed Value
MaxHandSpeed=max(HS);
SummaryTable.("MaxHandSpeed")=MaxHandSpeed;

%Cleanup
clear i;
clear h
clear CHSTemp;
clear HSTemp;

%Find the row in the table where each maximum occurs
CHSMaxRow=find(CHS==MaxCHS,1);
HSMaxRow=find(HS==MaxHandSpeed,1);

%Find the time in the table where the maximum occurs
CHSMaxTime=BASEQ.Time(CHSMaxRow,1);
SummaryTable.("CHSMaxTime")=CHSMaxTime;

HandSpeedMaxTime=BASEQ.Time(HSMaxRow,1);
SummaryTable.("HandSpeedMaxTime")=HandSpeedMaxTime;

%Find AoA at time of maximum CHS
AoAatMaxCHS=BASEQ.AoA(CHSMaxRow,1);
SummaryTable.("AoAatMaxCHS")=AoAatMaxCHS;

%Calculate the time that the equivalent midpoint couple goes negative in
%late downswing
TimeofAlphaReversal=interp1(BASE.EquivalentMidpointCoupleLocal(50:end,3),BASE.Time(50:end,1),0.0,'linear');
SummaryTable.("TimeofAlphaReversal")=TimeofAlphaReversal;

%Calculate the time that the ZTCF equivalent midpoint couple goes negative in
%late downswing. Currently I cut off the first 50 data points so I don't
%capture any startup effects.

TimeofZTCFAlphaReversal=interp1(ZTCF.EquivalentMidpointCoupleLocal(50:end,3),ZTCF.Time(50:end,1),0.0,'linear');
SummaryTable.("TimeofZTCFAlphaReversal")=TimeofZTCFAlphaReversal;

%Calculate the time that the ZTCF equivalent midpoint couple goes negative in
%late downswing. Currently I cut off the first 50 data points so I don't
%capture any startup effects.

TimeofDELTAAlphaReversal=interp1(DELTA.EquivalentMidpointCoupleLocal(50:end,3),DELTA.Time(50:end,1),0.0,'linear');
SummaryTable.("TimeofDELTAAlphaReversal")=TimeofDELTAAlphaReversal;

%Generate a table of the times when the function of interest (f) crosses
%zero.
f=BASE.AoA;
t=BASE.Time;

idx = find( f(2:end).*f(1:end-1)<0 );
t_zero = zeros(size(idx));
for i=1:numel(idx)
    j = idx(i);
    t_zero(i) = interp1( f(j:j+1), t(j:j+1), 0.0, 'linear' );
end

%Time of Zero AoA that Occurs Last
TimeofZeroAoA=max(t_zero);
SummaryTable.("TimeofZeroAoA")=TimeofZeroAoA;

%CHS at time of zero AoA
CHSZeroAoA=interp1(BASEQ.Time,BASEQ.("CHS (mph)"),TimeofZeroAoA,'linear');
SummaryTable.("CHSZeroAoA")=CHSZeroAoA;

%Find Data Needed for Grip Quivers at Time of Max CHS
ClubQuiverMaxCHS.("ButtxMaxCHS")=interp1(BASE.Time,BASE.("Buttx"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("ButtyMaxCHS")=interp1(BASE.Time,BASE.("Butty"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("ButtzMaxCHS")=interp1(BASE.Time,BASE.("Buttz"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("GripdxMaxCHS")=interp1(BASE.Time,BASE.("Gripdx"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("GripdyMaxCHS")=interp1(BASE.Time,BASE.("Gripdy"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("GripdzMaxCHS")=interp1(BASE.Time,BASE.("Gripdz"),CHSMaxTime,'linear');

%Find Data Needed for Shaft Quivers at Time of Max CHS
ClubQuiverMaxCHS.("RHxMaxCHS")=interp1(BASE.Time,BASE.("RHx"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("RHyMaxCHS")=interp1(BASE.Time,BASE.("RHy"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("RHzMaxCHS")=interp1(BASE.Time,BASE.("RHz"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("ShaftdxMaxCHS")=interp1(BASE.Time,BASE.("Shaftdx"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("ShaftdyMaxCHS")=interp1(BASE.Time,BASE.("Shaftdy"),CHSMaxTime,'linear');
ClubQuiverMaxCHS.("ShaftdzMaxCHS")=interp1(BASE.Time,BASE.("Shaftdz"),CHSMaxTime,'linear');

%Find Data Needed for Grip Quivers at Time of Alpha Reversal
ClubQuiverAlphaReversal.("ButtxAlphaReversal")=interp1(BASE.Time,BASE.("Buttx"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("ButtyAlphaReversal")=interp1(BASE.Time,BASE.("Butty"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("ButtzAlphaReversal")=interp1(BASE.Time,BASE.("Buttz"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("GripdxAlphaReversal")=interp1(BASE.Time,BASE.("Gripdx"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("GripdyAlphaReversal")=interp1(BASE.Time,BASE.("Gripdy"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("GripdzAlphaReversal")=interp1(BASE.Time,BASE.("Gripdz"),TimeofAlphaReversal,'linear');

%Find Data Needed for Shaft Quivers at Time of Alpha Reversal
ClubQuiverAlphaReversal.("RHxAlphaReversal")=interp1(BASE.Time,BASE.("RHx"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("RHyAlphaReversal")=interp1(BASE.Time,BASE.("RHy"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("RHzAlphaReversal")=interp1(BASE.Time,BASE.("RHz"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("ShaftdxAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdx"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("ShaftdyAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdy"),TimeofAlphaReversal,'linear');
ClubQuiverAlphaReversal.("ShaftdzAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdz"),TimeofAlphaReversal,'linear');

%Find Data Needed for Grip Quivers at Time of ZTCF Alpha Reversal
ClubQuiverZTCFAlphaReversal.("ButtxZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Buttx"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("ButtyZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Butty"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("ButtzZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Buttz"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("GripdxZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Gripdx"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("GripdyZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Gripdy"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("GripdzZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Gripdz"),TimeofZTCFAlphaReversal,'linear');

%Find Data Needed for Shaft Quivers at Time of ZTCF Alpha Reversal
ClubQuiverZTCFAlphaReversal.("RHxZTCFAlphaReversal")=interp1(BASE.Time,BASE.("RHx"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("RHyZTCFAlphaReversal")=interp1(BASE.Time,BASE.("RHy"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("RHzZTCFAlphaReversal")=interp1(BASE.Time,BASE.("RHz"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("ShaftdxZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdx"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("ShaftdyZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdy"),TimeofZTCFAlphaReversal,'linear');
ClubQuiverZTCFAlphaReversal.("ShaftdzZTCFAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdz"),TimeofZTCFAlphaReversal,'linear');

%Find Data Needed for Grip Quivers at Time of DELTA Alpha Reversal
ClubQuiverDELTAAlphaReversal.("ButtxDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Buttx"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("ButtyDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Butty"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("ButtzDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Buttz"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("GripdxDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Gripdx"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("GripdyDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Gripdy"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("GripdzDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Gripdz"),TimeofDELTAAlphaReversal,'linear');

%Find Data Needed for Shaft Quivers at Time of DELTA Alpha Reversal
ClubQuiverDELTAAlphaReversal.("RHxDELTAAlphaReversal")=interp1(BASE.Time,BASE.("RHx"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("RHyDELTAAlphaReversal")=interp1(BASE.Time,BASE.("RHy"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("RHzDELTAAlphaReversal")=interp1(BASE.Time,BASE.("RHz"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("ShaftdxDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdx"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("ShaftdyDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdy"),TimeofDELTAAlphaReversal,'linear');
ClubQuiverDELTAAlphaReversal.("ShaftdzDELTAAlphaReversal")=interp1(BASE.Time,BASE.("Shaftdz"),TimeofDELTAAlphaReversal,'linear');


clear CHS;
clear HS;
clear i;
clear j;
clear idx;
clear CHSMaxRow;
clear CHSMaxTime;
clear HSMaxRow;
clear HSMaxTime;
clear CHSTemp;
clear CHSZeroAoA;
clear f;
clear HandSpeedMaxTime;
clear MaxCHS;
clear MaxHandSpeed;
clear t;
clear t_zero;
clear TimeofAlphaReversal;
clear TimeofZeroAoA;
clear AoAatMaxCHS;
clear ClubAV;
clear ClubAVMaxRow;
clear ClubAVMaxTime;
clear HipAV;
clear HipAVMaxRow;
clear HipAVMaxTime;
clear LForearmAV;
clear LForearmAVMaxRow;
clear LForearmAVMaxTime;
clear LScapAV;
clear LScapAVMaxRow;
clear LScapAVMaxTime;
clear LUpperArmAV;
clear LUpperArmAVMaxRow;
clear LUpperArmAVMaxTime
clear MaxClubAV;
clear MaxHipAV;
clear MaxLForearmAV;
clear MaxLScapAV;
clear MaxLUpperArmAV;
clear MaxTorsoAV;
clear TorsoAV;
clear TorsoAVMaxRow;
clear TorsoAVMaxTime;
clear TimeofZTCFAlphaReversal;
clear TimeofDELTAAlphaReversal;
