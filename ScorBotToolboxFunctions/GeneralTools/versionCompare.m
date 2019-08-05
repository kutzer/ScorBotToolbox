function [newerVER,clean_v1,clean_v2] = versionCompare(v1,v2)
% VERSIONCOMPARE compares version strings and determines which is newer. 
%   newerVER = VERSIONCOMPARE(v1,v2) determines if v1 or v2 is a newer
%   version. newerVer \in {0,1,2}:
%       newerVer = 0 - Both versions are the same
%       newerVer = 1 - v1 is the newer version
%       newerVer = 2 - v2 is the newer version
%
%   [newerVER,clean_v1,clean_v2] = VERSIONCOMPARE(v1,v2) returns "clean"
%   version strings used for the actual comparison.
%
%   M. Kutzer, 24Jul2019, USNA

% Updates
%   05Aug2019 - Updated to provide full "clean version" string.

% \d* - any number of consecutive digits
% \D* - any non-numeric characters
% \W* - identifies a term that is not a word or number combination

% Parse values from version
% -> NOTE: This only recognizes version defined using numbers, for example:
%       5.1.5
%       6, 2, 6, 7
%       32. 5

% Parse strings
v1_cell = regexp(v1, '\d*', 'match');
v2_cell = regexp(v2, '\d*', 'match');

if isempty(v1_cell)
    fprintf('Could not parse first version value: "%s"\n',v1);
    v1_cell = {'0'};
end

if isempty(v2_cell)
    fprintf('Could not parse second version value: "%s"\n',v1);
    v2_cell = {'0'};
end

% Initialize array representing version number
n = max([numel(v1_cell),numel(v2_cell)]);
v1_array = zeros(1,n);
v2_array = zeros(1,n);

% Populate version arrays
for i = 1:numel(v1_cell)
    v1_array(i) = str2double(v1_cell{i});
end

for i = 1:numel(v2_cell)
    v2_array(i) = str2double(v2_cell{i});
end

% Compare version arrays
clean_v1 = '';
clean_v2 = '';
newerVER = 0;
for i = 1:n
    if newerVER == 0
        if v1_array(i) > v2_array(i)
            newerVER = 1;
            %return;
        elseif v2_array(i) > v1_array(i)
            newerVER = 2;
            %return
        end
    end
    
    if i > 1
        clean_v1 = sprintf('%s.%d',clean_v1,v1_array(i));
        clean_v2 = sprintf('%s.%d',clean_v2,v2_array(i));
    else
        clean_v1 = sprintf('%d',v1_array(i));
        clean_v2 = sprintf('%d',v2_array(i));
    end
end

end