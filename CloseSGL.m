function CloseSGL(hSGL)
	%CloseSGL Initializes SGL
	%   [hSGL,strRunName,sParamsSGL] = InitSGL(strRecording,strOutputFile)
	
	%% stop recording
	try
		warning('off','CalinsNetMex:connectionClosed');
		SetRecordingEnable(hSGL, 0);
		warning('on','CalinsNetMex:connectionClosed');
	catch ME
		warning([mfilename ':CloseFailed'],'Failed to end recording, please disable recording manually!');
		ME
	end
end
