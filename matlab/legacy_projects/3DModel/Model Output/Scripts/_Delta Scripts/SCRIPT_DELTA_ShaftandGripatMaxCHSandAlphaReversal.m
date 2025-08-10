
%Grip Quiver for DELTAAlpha Reversal
GripDELTAAlpha=quiver3(ClubQuiverDELTAAlphaReversal.ButtxDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.ButtyDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.ButtzDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.GripdxDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.GripdyDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.GripdzDELTAAlphaReversal,0);
GripDELTAAlpha.ShowArrowHead='off';
GripDELTAAlpha.LineWidth=3;			            %Set grip line width
GripDELTAAlpha.Color=[0 0 0];			        %Set grip color to black
hold on;

%Shaft Quiver for Alpha Reversal
ShaftDELTAAlpha=quiver3(ClubQuiverDELTAAlphaReversal.RHxDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.RHyDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.RHzDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.ShaftdxDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.ShaftdyDELTAAlphaReversal,ClubQuiverDELTAAlphaReversal.ShaftdzDELTAAlphaReversal,0);
ShaftDELTAAlpha.ShowArrowHead='off';		        %Turn off arrow heads
ShaftDELTAAlpha.LineWidth=3;			            %Adjust line weighting
ShaftDELTAAlpha.Color=[0.0745 0.6235 1.0000];
hold on;				                    %Hold the current plot when you generate new

%Grip Quiver for Max CHS
GripMaxCHS=quiver3(ClubQuiverMaxCHS.ButtxMaxCHS,ClubQuiverMaxCHS.ButtyMaxCHS,ClubQuiverMaxCHS.ButtzMaxCHS,ClubQuiverMaxCHS.GripdxMaxCHS,ClubQuiverMaxCHS.GripdyMaxCHS,ClubQuiverMaxCHS.GripdzMaxCHS,0);
GripMaxCHS.ShowArrowHead='off';
GripMaxCHS.LineWidth=3;			            %Set grip line width
GripMaxCHS.Color=[0 0 0];			        %Set grip color to black
hold on;

%Shaft Quiver for Max CHS
ShaftMaxCHS=quiver3(ClubQuiverMaxCHS.RHxMaxCHS,ClubQuiverMaxCHS.RHyMaxCHS,ClubQuiverMaxCHS.RHzMaxCHS,ClubQuiverMaxCHS.ShaftdxMaxCHS,ClubQuiverMaxCHS.ShaftdyMaxCHS,ClubQuiverMaxCHS.ShaftdzMaxCHS,0);
ShaftMaxCHS.ShowArrowHead='off';		    %Turn off arrow heads
ShaftMaxCHS.LineWidth=3;			        %Adjust line weighting
ShaftMaxCHS.Color=[0.9294 0.6941 0.1255];

%Set View
view(-0.0885,-10.6789);
