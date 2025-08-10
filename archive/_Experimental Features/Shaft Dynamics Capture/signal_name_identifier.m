runIDs = Simulink.sdi.getAllRunIDs;
latestRun = Simulink.sdi.getRun(runIDs(end));
for i = 1:latestRun.signalCount
    sig = latestRun.getSignalByIndex(i);
    fprintf('%02d: %s\n', i, sig.Name);
end
