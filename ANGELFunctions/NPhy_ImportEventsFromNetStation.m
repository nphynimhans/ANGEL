function [returnFile, errorReturn] = NPhy_ImportEventsFromNetStation(EEG, ANGEL, inputFile)
%NPhy_ImportEventsFromNetStation Convert Events from Net Station to ASCII
% Purpose: Import relevant events from Net Station 4.5.7 ASCII export files
%          for the ANGEL game
%
%          coma = corollary marker,
%          soma = sound marker,
%          vima = image marker
%
% Date of Creation: 22 Mar 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize variables.
delimiter = '\t';
returnFile = inputFile;
errorReturn = 0;

if strcmp(ANGEL.rawEventDir, '')
   ANGEL.rawEventDir =  uigetdir('.',...
    'Select the directory containing event files from Net Station');
end

outputDir = ANGEL.eventDir;

cd(ANGEL.rawEventDir);
fileNameStruct = dir([inputFile(1:ANGEL.prefixLength), '.evt']);
rawEventFileName = fileNameStruct.name;

try
    eventFile = [outputDir, '\', rawEventFileName(1:(end-4)), '_events.txt'];

    %% Open the text file.
    inputFileID = fopen(rawEventFileName,'r');
    outputFileID = fopen(eventFile,'w');
    startActualProcessingNow = 0;    

    % Get last line for getting delta latency between raw EEG events and the
    % Net Station exported events
    while 1

        textLine = fgetl(inputFileID);  
        % Quit if end of file
        if ~ischar(textLine)
            break
        end
        lastLine = textLine;
    end
    
    [eventName, ~, eventLatency, cellNumber] = NPhy_ScanLine(lastLine, 'skip');
    
    lastEvent = length(EEG.event);
    lastLatency = EEG.event(lastEvent).latency;
    lastType = EEG.event(lastEvent).type;
    
    deltaLatency = 0;
    if strcmp(eventName, lastType)
        deltaLatency = eventLatency - lastLatency/1000;
    else
        errorReturn = 1;
        fprintf(ANGEL.logFileID,'\nAborting Event Conversion - Last Events DO NOT MATCH for : %s \n',inputFile);        
        return;
    end
    
    % Rewind to file beginning to start processing line by line
    frewind(inputFileID);    
    
    % Skip headers    
    for i=1:23
        fgetl(inputFileID);
    end 

    % Skip practice sessions before processing the actual trials
    while 1

        textLine = fgetl(inputFileID);  
        % Quit if end of file
        if ~ischar(textLine)
            break
        end
        [eventName, ~, eventLatency, cellNumber] = NPhy_ScanLine(textLine, 'skip');
       
        % If it is a practice trial where a 'coma' may sometimes
        % accidentally appear, skip the trial
        if cellNumber <= 3 || strcmp(eventName, 'coma')
            continue;
        else
            startActualProcessingNow = 1;
            break;
        end
    end

    while 1

        % Use the previously obtained line when starting the processing.
        % From then on, get a new line to continue processing
        if startActualProcessingNow
            startActualProcessingNow = 0;
        else
            textLine = fgetl(inputFileID);  
            % Quit if end of file
            if ~ischar(textLine)
                break;
            end
        end

        eventVal = textLine(1:4);
        switch eventVal    

            case  {'soma', 'vima', 'coma'}
                  [eventName, eventType, eventLatency, cellNumber] =...
                      NPhy_ScanLine(textLine, eventVal);          
                  
                  % Handle bug in sending event marker for
                  % CDOffRightFaceAbsentRare
                  if regexpi(inputFile, 'ANGEL3')
                      if cellNumber == 11 && eventType == 183
                          eventType = 191;
                      end
                  end                         
                  
                  fprintf(outputFileID, ['%d', delimiter, '%f\n'],...
                      eventType, eventLatency -  deltaLatency); 
                  fprintf(['%d', delimiter, '%f\n'],...
                      eventType, eventLatency -  deltaLatency); % Print to screen


            case  'resp'
                  [eventName, eventType, eventLatency, ~] =...
                      NPhy_ScanLine(textLine, eventVal);                  

                  % Get the actual response - it is stored in the 'TRSP'
                  textLine = fgetl(inputFileID);  
                  % Quit if end of file
                  if ~ischar(textLine)
                      break;
                  end     
                  eventValPostResp = textLine(1:4);
                  
                  [eventNamePostResp, eventTypePostResp, ~, ~] =...
                      NPhy_ScanLine(textLine, eventValPostResp);

                  if strcmp(eventNamePostResp, 'TRSP') %  Usually TRSP follows resp
                    fprintf(outputFileID, ['%d', delimiter, '%f\n'], eventTypePostResp,eventLatency -  deltaLatency);
                    fprintf(['%d', delimiter, '%f\n'], eventTypePostResp,eventLatency -  deltaLatency);  % Print to screen
                    
                  elseif strcmp(eventNamePostResp, 'coma')  % During CDOn, coma comes in between resp and TRSP
                      [eventNameCD, eventTypeCD, eventLatencyCD, ~] =...
                                NPhy_ScanLine(textLine, eventNamePostResp); 
                            
                      % Get the actual response - it is stored in the 'TRSP'
                      textLine = fgetl(inputFileID);  
                      % Quit if end of file
                      if ~ischar(textLine)
                          break;
                      end              
                      eventValPostComa = textLine(1:4);

                      [eventNamePostComa, eventTypePostComa, ~, ~] =...
                          NPhy_ScanLine(textLine, eventValPostComa);                           
                      
                      if strcmp(eventNamePostComa, 'TRSP') %  TRSP should appear now
                        fprintf(outputFileID, ['%d', delimiter, '%f\n'], eventTypePostComa,eventLatency -  deltaLatency);
                        fprintf(['%d', delimiter, '%f\n'], eventTypePostComa,eventLatency -  deltaLatency);  % Print to screen
                      else   
                          warning('Unexpected line - TRSP missing after response');                            
                      end     
                      
                      % Now print the coma event
                      fprintf(outputFileID, ['%d', delimiter, '%f\n'], eventTypeCD,eventLatency -  deltaLatency); 
                      fprintf(['%d', delimiter, '%f\n'], eventTypeCD,eventLatency - deltaLatency); % Print to screen                      

                  end

        end

    end % End of while loop for reading the till end of file

    %% Close the text file.
    fclose(inputFileID);
    fclose(outputFileID);
    returnFile = eventFile;
    
catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted Event Conversion from Net Station to ASCII for : %s \n',inputFile);
end

