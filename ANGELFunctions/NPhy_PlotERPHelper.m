function [errorReturn] = NPhy_PlotERPHelper(ANGEL, ERP, erpPlotVars, erpNo)
%NPhy_PlotERPImage Plot ERPImages for the given paradigm
%   
% Date of Creation: 13 Apr 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;
try

    %  'Position', [ 62.5 5.6875 108.5 32.5625] for full size
    ERP = pop_ploterps( ERP,  erpPlotVars{erpNo,2},  erpPlotVars{erpNo,3},...
        'Axsize', [ 0.05 0.08], 'BinNum', 'off', 'Blc', '-200    0', 'Box', erpPlotVars{erpNo,4},...
        'ChLabel', 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10,...
        'LegPos', 'bottom', 'Linespec', {'r-' , 'r-.' , 'b-' , 'b-.' , 'g-' , 'g-.' }, 'LineWidth',  2,...
        'Maximize','on', 'Position', [ 102.833 11.9375 108.5 32.5625], 'Style', 'Classic',...
        'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', erpPlotVars{erpNo,5},...
        'YDir', 'normal', 'yscale', erpPlotVars{erpNo,6} );

    ERP = erplabfig2pdf(ERP, 'ERP_figure', 'auto', ANGEL.erpResults, 'tiff', 600);   
    close(gcf);


%             %% Plot the Topography
%             ERP = pop_scalplot( ERP, [ 1 2],  300:50:450 , 'Blc', [ -200 0],...
%                 'Colorbar', 'on', 'Colormap', 'jet', 'Electrodes', 'on', 'FontName',...
%                 'Courier New', 'FontSize',  10, 'Legend', 'la', 'Maplimit', [ -3.0 4.0   ],...
%                 'Maptype', '2D', 'Mapview', '+X', 'Maximize', 'on', 'Position',...
%                 [ 19 -6 1350 676], 'Value', 'insta' );
%             
%             ERP = erplabfig2pdf(ERP, 'ERP_figure', 'auto', outputdir, 'jpg', 600);   
%             close(gcf);        

catch error
    errorReturn = 1;  
end
    
end
