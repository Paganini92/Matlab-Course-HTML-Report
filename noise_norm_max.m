function noise_norm_max (filename,noise_filename)
    % Function to clear data from noise and normalize within a area of
    % pixel-lines; pixel-lines will be requested during script!!!
    % Input: 'smd_all_05_refracted' without .mat
    %       'noise_smd_records' without .mat
    
    % identified faulty pixel
    faulty_pixel = [247:272 409:435 567:590 408:430 769:865 872:898 1069:1101 1154:1164 1261:1283 1356:1434];
    
    % create file and noise-names and load data
    
    data = eval(append("load ('",filename,".mat", "')" ));
    noise = eval(append("load ('",noise_filename,".mat", "')" ));
    
    % What are the names of all variables in the loaded file and how many
    % variables do exist?
    names_of_variables = fieldnames(data);
    [num_of_variable,~] = size(names_of_variables);
    names(1:num_of_variable) = " ";
    names_of_noise = fieldnames(noise);
    
    % for each variable:
    for n = 1:num_of_variable
                
        % clear data from noise
        if (mean(size(names_of_noise)) ~= 1)
            data_no_noise = fliplr(data.(names_of_variables{n}) - noise.(names_of_noise{n}));
        else
            data_no_noise = fliplr(data.(names_of_variables{n}) - noise.(names_of_noise{1}));
        end
        data_no_noise(faulty_pixel,:) = [];
        
        % show all images and choose the full illuminated areas
        imagesc(data_no_noise);
        display('Choose starting point of full illumination')
        line_start = input('\n');
        display('Choose endpoint of full illumination')
        line_stop = input('\n');
        
        % detect size
        % [rows,~] = size(data.(names_of_variables{n}));
        [rows,~] = size(data_no_noise);
        
        % average all lines that have been given as input
        %(line_start,line_stop); lines with best illumination
        eval(append(names_of_variables{n},"_no_noise_normalized"," = normalize(mean(data_no_noise(line_start:line_stop,:)),'norm','Inf');"))
        % save new variable_names
        names(n) = append(names_of_variables{n},"_no_noise_normalized"," ");
    end
    % append all new created variable_names for save-command
    names_appended = names(1);
    for x=2:n
        names_appended = append(names_appended,names(x));
    end
    % clear all variables except filename and new created variables
    eval(append("clearvars -except ",names_appended,"filename"))
    
    % save new variables without filename
    variables_before_save = who;
    % save all variables who's name don't contain "filename"
    save(append(filename,"_no_noise_normalized"),variables_before_save{~contains(variables_before_save,'filename')})

end