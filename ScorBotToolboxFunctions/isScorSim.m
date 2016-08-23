function bin = isScorSim(scorSim)
% ISSCORSIM true for a valid scorSim object
%   bin = SCORSIMINIT(scorSim) returns true (1) for a valid scorSim object
%       and false (0) for invalid scorSim objects
%
%   Properties:
%       scorSim.Figure - figure handle of ScorBot visualization
%       scorSim.Axes   - axes handle of ScorBot visualization
%       scorSim.Joints - 1x5 array containing joint handles for ScorBot
%           visulization (hgtransform objects, use 
%           set(scorSim.Joints(i),'Matrix',Rz(angle)) to change a specific
%           joint angle)
%       scorSim.Frames - 1x5 array containing reference frame handles for
%           ScorBot (hgtransform objects with triad.m decendants)
%       scorSim.Finger - 1x4 array containing reference frame handles for
%           the ScorBot end-effector fingers (hgtransform objects)
%       scorSim.FingerTip - 1x2 array containing reference frame handles 
%           for the ScorBot end-effector fingertips (hgtransform objects)
%       scorSim.TeachFlag - status update object, not for general use
%       scorSim.TeachText - status update object, not for general use
%
%   See also ScorSimInit ScorSimPatch
%
%   M. Kutzer, 29Dec2015, USNA

% Updates
%   30Dec2015 - Added debugging comments

%% Check fields (assumes scorSim is a structured array)
% TODO - update if scorSim is migrated to a class
fieldnames = ...
    {'Figure',...
    'Axes',...
    'Joints',...
    'Frames',...
    'Finger',...
    'FingerTip',...
    'TeachFlag',...
    'TeachText'};
tf = isfield(scorSim,fieldnames);
if sum(tf) ~= numel(fieldnames)
    % fprintf('Bad field: "%s"\n',fieldnames{~tf});
    bin = false;
    return;
end

%% Check for valid handles
for i = 1:numel(fieldnames)
    tf = ishandle(scorSim.(fieldnames{i}));
    if sum(tf) ~= numel(scorSim.(fieldnames{i}))
        % for idx = find(~tf)
        %     fprintf('The following is not a valid handle: "%s.%s(%d)"\n',inputname(1),fieldnames{i},idx);
        % end
        bin = false;
        return
    end
end

%% Check handle types
handletypes = ...
    {'figure',...
    'axes',...
    'hgtransform',...
    'hgtransform',...
    'hgtransform',...
    'hgtransform',...
    'patch',...
    'text'};
for i = 1:numel(fieldnames)
    type = get(scorSim.(fieldnames{i}),'type');
    tf = strcmpi(type,handletypes{i});
    if sum(tf) ~= numel(scorSim.(fieldnames{i}))
        % for idx = find(~tf)
        %     fprintf('The following is not the correct handle type: "%s.%s(%d)"\n',inputname(1),fieldnames{i},idx);
        % end
        bin = false;
        return
    end
end

%% Set output to true
bin = true;