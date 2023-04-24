%% Script-Functions: 
% - Import Moodle-List+
% - Export only names + URL's for each student in own table 'database'
% - Import section-names of Matlab-Fundamentals-Course lecturer-reference link of newest course-version
%   (can be used for any mathworks course)
% - Detects number of sections
% - Extends 'database-table' with columns for each section
% - Readout of every students Report-URL
% - Assessment 1: any link deposited?
% - Assessment 2: correct link (fundamentals) deposited?
% - Export of HTML-List-Elements(sectionwise)
% - Add all section progress to corresponding column in 'database' for each line

%% Import of moodle-liste in .csv

list = readtable('Bewertungen-GIT-II (WiSe 2223)-5. Abgabe Progress-Report Fundamentals-Kurs-154796.csv','Delimiter',',');

column_names = list.Properties.VariableNames{2};
column_url = list.Properties.VariableNames{8};
% Save name + URL for each student
% Can be modified for onRamp, fundamentals or any other mathworks-course
eval(append('names = string(list.',column_names,');'))
eval(append('url = string(list.',column_url,');'))

database_fundamentals = table(names,url);
%% Import of Matlab-Sectionnames from reference-link of lecturer

fundamentals_url = 'https://matlabacademy.mathworks.com/progress/share/report.html?id=5a965933-3f60-4fca-84e7-0f2438d983a8&';

% Get names of chapters
chapter_fundamentals = getkapitel(fundamentals_url)';

% How many chapters?
[~,num_chapter_fundamentals] = size(chapter_fundamentals);

% How many students?
[num_member,~] = size(names);

% Initialize table corresponding to nummber of students and chapters
chapter_overview_fundamentals = array2table(zeros(num_member,num_chapter_fundamentals));
chapter_overview_fundamentals.Properties.VariableNames = chapter_fundamentals;

% Combine names+URL table with chapters
database_fundamentals = [database_fundamentals chapter_overview_fundamentals];

% Search with regexp for mathworks-report-link and save the "cleared" link
% into the 'database'
expression = 'https.*&';
[database_fundamentals.url, ~] = regexp(database_fundamentals.url, expression, 'match', 'forceCellOutput');
database_fundamentals = renamevars(database_fundamentals, ["names","url"], ["Name","URL"]);

%% Export from URL and filling the chapter-columns with points
tichtml = tic;
regexp_report_url = 'https://matlabacademy.mathworks.com/progress/share/report';

for n = 1:num_member
    if(isempty(database_fundamentals.URL{n})==0)

        % Is the submitted link really a report-link?
        valid_url_report = regexp(database_fundamentals.URL{n},regexp_report_url);
        
        % Read HTML-Data for each student
        code = webread(string(database_fundamentals.URL{n}));
        
        % Extract HTML-Data and check if it's a fundamentals-course
        % report-link
        str = extractHTMLText(code);
        valid_url = regexp(str,'MATLAB Fundamentals');
        if (~isempty(valid_url) & (~isempty(valid_url_report)))
            
            % HTML-Tree Export
            tree = htmlTree(code);
            selector_name_check = 'td';
            selector_valid = 'li > span';
            
            % Does the name of the report-link and from moodle-list match?
            % or did anyone submit a report-link of another person
            validtree = findElement(tree,selector_name_check);
            namestr = extractHTMLText(validtree);
            
            valid_name = strcmpi(char(namestr(2)), database_fundamentals.Name{n});
            
            
            if valid_name
                % Search for all elements embedded into a html-list ->
                % those are the chapter-names + points
                subtree = findElement(tree,selector_valid);
                
                % Extract those elements
                htmlstr = extractHTMLText(subtree);
             
                for i=3:num_chapter_fundamentals+2
                    database_fundamentals{n,i} = sscanf(htmlstr(i-2),'%f');
                end
                
            else
                for i=3:num_chapter_fundamentals+2
                    database_fundamentals{n,i} = NaN;
                end
            end
        else
            % Fill in NaN if provided URL is wrong or from another person
            for i=3:num_chapter_fundamentals+2
                database_fundamentals{n,i} = NaN;
            end
        end
    else
        % Fill in NaN if no URL was provided
        for i=3:num_chapter_fundamentals+2
            database_fundamentals{n,i} = NaN;
        end
    end
    
end
tochtml = toc(tichtml)

writetable(database_fundamentals,'database_fundamentals.xlsx');
