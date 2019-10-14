function objDAQIn = openDaqInput(intUseDevice,strDataOutFile)
	%% set handle
	global ptrPhotoDiodeFile;
	
	%% process input
	if ~exist('intUseDevice','var') || isempty(intUseDevice)
		intUseDevice = 1;
	end
	if ~exist('strDataOutFile','var') || isempty(strDataOutFile)
		strDataOutFile = ['D:\PhotoDiodeData\PDD' getDate '_' strrep(getTime,':','-') '.csv'];
	end
	%% setup connection
	%query connected devices
	objDevice = daq.getDevices;
	strCard = objDevice.Model;
	strID = objDevice.ID;
	
	%create connection
	objDAQIn = daq.createSession(objDevice(intUseDevice).Vendor.ID);
	
	%set variables
	objDAQIn.IsContinuous = true;
	objDAQIn.Rate=1000; %1ms precision
	
	%% add screen photodiode input
	addAnalogInputChannel(objDAQIn,strID,'ai0','Voltage');
	hListener = addlistener(objDAQIn,'DataAvailable',@fPhotoDiodeCallback);
	
	%% open file
	try,fclose(ptrPhotoDiodeFile);catch,end
	ptrPhotoDiodeFile = fopen(strDataOutFile,'wt+');
	strWrite = '"TriggerTime";"TimeStamp";"Data"\n';
	fprintf(ptrPhotoDiodeFile,strWrite);
	
	%% start
	try
		startBackground(objDAQIn);
	catch ME
		%remove file
		fclose(ptrPhotoDiodeFile);
		delete(strDataOutFile);
		
		%rethrow
		rethrow(ME);
	end
end

