function [ offline_names, online_names ] = extractOffOnLineFileNames( subject, parent_folder )
%extraction of the filenames for the corrisponding subject

    signal_folder_online = [parent_folder, '\Signals\online'];
    signal_folder_offline = [parent_folder, '\Signals\offline'];

    subject_codes = containers.Map({'Mike','Flavio','Ilaria','Anon'}, {'aj3','aj4','aj5','anonymous'});
    
    if(~subject_codes.isKey(subject))
        error('No such subject existing');
    end
    
    code = subject_codes(subject);

    fileslist = dir(signal_folder_offline);
    offline_names = findFilesWithCode(code, fileslist);
    fileslist = dir(signal_folder_online);
    online_names = findFilesWithCode(code, fileslist);

end

function [ stringsExtracted ] = findFilesWithCode(code, fileslist)

    stringsExtracted = {};
    n_cell = 1;

    for i=1:size(fileslist,1)
        if ( ~isempty( strfind(fileslist(i).name,code) ) )
            stringsExtracted{n_cell} = fileslist(i).name;
            n_cell = n_cell + 1;
        end
    end

end