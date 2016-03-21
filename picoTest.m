    picoObj = serial('COM9', ...
    'BaudRate',19200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(picoObj); %Open the device
    picoObj.Terminator='CR'; %Set terminator to ''
    
    % Check it's working
    fprintf(picoObj, 'ver');
    fscanf(picoObj)
     
    fclose(picoObj);
    delete(picoObj);

    
    