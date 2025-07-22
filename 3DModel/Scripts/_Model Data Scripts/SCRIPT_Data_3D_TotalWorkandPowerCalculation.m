%Add Total Work and Power to Tables

%Generate Total Work and Power Vectors

%Data
Data.TotalLSWork=Data.LSAngularWorkonArm+Data.LSLinearWorkonArm;
Data.TotalRSWork=Data.RSAngularWorkonArm+Data.RSLinearWorkonArm;
Data.TotalLEWork=Data.LEAngularWorkonForearm+Data.LELinearWorkonForearm;
Data.TotalREWork=Data.REAngularWorkonForearm+Data.RELinearWorkonForearm;
Data.TotalLHWork=Data.LHAngularWorkonClub+Data.LHLinearWorkonClub;
Data.TotalRHWork=Data.RHAngularWorkonClub+Data.RHLinearWorkonClub;
Data.TotalLSPower=Data.LSonArmAngularPower+Data.LSonArmLinearPower;
Data.TotalRSPower=Data.RSonArmAngularPower+Data.RSonArmLinearPower;
Data.TotalLEPower=Data.LEonForearmAngularPower+Data.LEonForearmLinearPower;
Data.TotalREPower=Data.REonForearmAngularPower+Data.REonForearmLinearPower;
Data.TotalLHPower=Data.LHonClubAngularPower+Data.LHonClubLinearPower;
Data.TotalRHPower=Data.RHonClubAngularPower+Data.RHonClubLinearPower;

