function [] = saveAllFigures()
    %Save all the figures with the assigned name
    
    FolderName = tempdir;   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = get(FigHandle, 'Name');
      savefig(FigHandle, fullfile(FolderName, FigName, '.fig'));
    end
    
end