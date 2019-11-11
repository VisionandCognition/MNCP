function [hSGL,strRunName,sParamsSGL] = InitSGL(strRecording,strOutputFile)
	%InitSGL Initializes SGL
	%   [hSGL,strRunName,sParamsSGL] = InitSGL(strRecording,strOutputFile)
	
	% Create connection (edit the IP address)
	hSGL = SpikeGL('127.0.0.1');
	
	%retrieve channels to save
	warning('off','CalinsNetMex:connectionClosed');
	vecSaveChans = GetSaveChans(hSGL, 0);
	warning('on','CalinsNetMex:connectionClosed');
	
	if ~IsSaving(hSGL)
		%set run name
		intBlock = 0;
		boolAccepted = false;
		while ~boolAccepted
			intBlock = intBlock + 1;
			strRunName = strcat(strOutputFile,sprintf('R%02d',intBlock));
			try
				SetRunName(hSGL, strRunName);
				boolAccepted = true;
			catch
				boolAccepted = false;
			end
			if intBlock > 99
				error([mfilename ':NameNotAccepted'],'Run names are not accepted... Something is wrong');
			end
		end
	else
		intBlock = 1;
		strRunName = strcat(strOutputFile,sprintf('R%02d',intBlock));
	end
	
	%set meta data, can be anything, as long as it's a numeric scalar or string
	sMeta = struct();
	strTime = getTime;
	strRunName = cat(strRunName,'_',strTime);
	strMataField = sprintf('recording_%s',strTime);
	sMeta.(strMataField) = strRecording;
	SetMetaData(hSGL, sMeta);
	
	%get parameters for this run
	sParamsSGL = GetParams(hSGL);
	
	%set stream IDs
	vecStreamIM = [0];
	intStreamNI = -1;
	
	%get probe ID
	[cellSN,vecType] = GetImProbeSN(hSGL, vecStreamIM(1));
	sParamsSGL.cellSN = cellSN;
	
	%start recording if not already recording
	if ~IsSaving(hSGL)
		SetRecordingEnable(hSGL, 1);
	end
	hTicStart = tic;
	
	%check if output is being saved
	while ~IsSaving(hSGL) && toc(hTicStart) < 1
		pause(0.01);
	end
	if ~IsSaving(hSGL)
		error([mfilename ':NotSaving'],'Data is not being saved!')
	end
