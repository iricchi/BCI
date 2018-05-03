function [] = saveAllFigures()
    %Save all the figures with the assigned name
    
    FolderName = 'C:\Users\Michael\Desktop\Matlab\BCI\BCI\Figures';   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    
    for iFig = 1:length(FigList)
      
        FigHandle = FigList(iFig);
      FigName   = get(FigHandle, 'Name');
      
      saveas(FigHandle,[FolderName,'\',FigName,'.png']);
    end
    
end