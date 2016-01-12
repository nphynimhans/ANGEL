function [errorReturn] =  NPhy_UpdateFigureProperties()
%NPhy_UpdateFigureProperties Plot Channel Measures for STUDY 
%   
% Date of Creation: 25 May 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

hLine = findobj('type','line');
set(hLine,'LineWidth',2);
hFigure = findobj(gcf);
hAxes = findall(hFigure,'Type','Axes');
set(hAxes, 'FontSize',12);
hText = findall(hFigure,'Type','text');
set(hText, 'FontSize',12);

end

