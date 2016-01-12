function [eventName, eventType, eventLatency, cellNumber  ] = NPhy_ScanLine(inputLine, format )
%NPhy_ScanLine Scan the given line of Net Station events 
%   Return event name, its value (also called 'type') and latency 
%
% Date of Creation: 23 Mar 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initialize variables.
delimiter = '\t';
eventName = '';
eventType = '';
eventLatency = 0;
cellNumber = 0;

%% Format string for each line of text:

% For sound or visual markers - soma, coma and vima
%soma		Stimulus Event	ECI TCP/IP 55513	_00:00:08.273	_00:00:00.001	cel#	2	obs#	1	pos#	2	soma	220		
formatSpec = '%s %*s %*s                        %s                  %*s         %*s     %d  %*s     %*s %*s     %*s %s      %d';

% For markers to be skipped only the cell number is relevant
%bgin		Stimulus Event	ECI TCP/IP 55513	_00:00:36.072	_00:00:00.001	cel#	2	obs#	1	pos#	1	argu	0	
skipFormatSpec = '%s %*s %*s                        %s                  %*s     %*s     %d  %*[^\n]';

% For response
%resp		Stimulus Event	ECI TCP/IP 55513	_00:08:32.486	_00:00:00.001	cel#	11	obs#	1	pos#	1	rsp+	1	
formatSpecResponse = '%s %*s %*s                        %s          %*s         %*s     %d  %*s     %*s %*s     %*d  %*s    %d';

% For TRSP which contains the value of the response
%TRSP		Stimulus Event	ECI TCP/IP 55513	_00:08:32.919	_00:00:00.001	cel#	11	obs#	1	rsp#	2	eval	1	rtim	361	trl#	223	 	 	
formatSpecTRSP = '%s %*s     %*s                        %s          %*s         %*s     %d  %*s     %*s %*s     %d  %*[^\n]';

switch format
    case 'skip'
          array = textscan(inputLine, skipFormatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', 1);
          eventName = array{1}{1};   % event type is skipped as its not needed for some events like bgin
          time =  textscan(array{2}{1}, '%*4c%2d%*c%f2.3');
          eventLatency =  double(time{1}*60) + time{2};
          cellNumber = array{3};
          
    case {'soma', 'vima', 'coma'}
          array = textscan(inputLine, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', 1);
          eventName = array{1}{1};
          eventType = array{5};          
          time =  textscan(array{2}{1}, '%*4c%2d%*c%f2.3');
          eventLatency =  double(time{1}*60) + time{2};
          cellNumber = array{3};       
          
    case  'resp'
          array = textscan(inputLine, formatSpecResponse, 'Delimiter', delimiter, 'MultipleDelimsAsOne', 1);
          eventName = array{1}{1};  % event type is skipped as it should be picked up from TRSP
          time =  textscan(array{2}{1}, '%*4c%2d%*c%f2.3');
          eventLatency =  double(time{1}*60) + time{2};        
          cellNumber = array{3};  
          
    case  'TRSP'        
          array = textscan(inputLine, formatSpecTRSP, 'Delimiter', delimiter, 'MultipleDelimsAsOne', 1);
          eventName = array{1}{1};  
          eventType = array{4};  % event latency is not needed as its picked up from 'resp'
          cellNumber = array{3};       
end

end

