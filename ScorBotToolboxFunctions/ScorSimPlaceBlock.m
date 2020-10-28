function varargout = ScorSimPlaceBlock(varargin)
% SCORSIMPLACEBLOCK creates adds a block to the ScorBot simulation
% environment. 
%   SCORSIMPLACEBLOCK(scorSim) creates a random block on the
%   lab bench in the ScorBot simulation environment 
%   See also ScorSimLabBench
%
%   SCORSIMPLACEBLOCK(...,Name,Value) specifies the block properties using
%   one or more Name,Value pair arguments.
%
%       Property Name - Value(s)
%             'shape' - [ ['rectangle'] | 'circle' | 'square' ]
%             'color' - color specified as ['r'], 'g', 'b', 'c', 'm', 'y',
%                       'k','w' or an RGB Triplet (e.g. [0.5,0.5,0])
%            'matrix' - 4x4 homogenious transform. This should be
%                       constrained to Tx(___)*Ty(___)*Rz(___) to keep the 
%                       block on the lab bench.
%             'scale' - positive value defining the longest dimension along
%                       the body-fixed x-axis of the block in millimeters.
%           'daspect' - sets the data aspect ratio of the block to the 
%                       specified value. Specify the aspect ratio as three 
%                       relative values representing the ratio of the x-, 
%                       y-, and z-axis scaling (e.g., [1 1 3] means one 
%                       unit in x is equal in length to one unit in y and 
%                       three units in z ).
%
%   h_b2l = SCORSIMPLACEBLOCK(___) returns the hgtransform object of the
%   block defined relative to the lab bench coordinate frame.
%
%   See also ScorSimLabBench
%
%   M. Kutzer, 28Oct2020, USNA

% Updates:
%   

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
end
% Check scorSim
if nargin >= 1
    scorSim = varargin{1};
    if ~isScorSim(scorSim)
        if isempty(inputname(1))
            txt = 'The specified input';
        else
            txt = sprintf('"%s"',inputname(1));
        end
        error('ScorSet:BadSimObj',...
            ['%s is not a valid ScorSim object.',...
            '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
            '\n\t-> and "%s(scorSim);" to execute this function.'],txt,mfilename);
    end
end

% Set defaults
shape = 'rectangle';
color = [1,0,0];
H_b2l = Tx(200*rand(1))*Ty(500*(rand(1)-0.5))*Rz(2*pi*rand(1));
scale = 65;
%daspect = [1,0.75,0.30];
daspect = [];
if nargin > 1
    if round( (nargin - 1)/2 ) ~= (nargin - 1)/2
        error('Block properties must be specified using one or more Name,Value pair arguments. For example "ScorSimPlaceBlock(___,''shape'',''rectangle'').');
    end
    
    % Properties - 'shape','color','matrix','scale','daspect'
    for i = 2:2:nargin
        switch lower(varargin{i})
            case 'shape'
                shape = varargin{i+1};
            case 'color'
                color = varargin{i+1};
            case 'matrix'
                H_b2l = varargin{i+1};
            case 'scale'
                scale = varargin{i+1};
            case 'daspect'
                daspect = varargin{i+1};
            otherwise
                txt = sprintf('"%s"',inputname(i));
                error('ScorSimPlaceBlock:BadProp',...
                    '"%s" is not a valid property name.',txt);
        end
    end
end

%% Check input(s)
% shape
switch lower(shape)
    case 'rectangle'
        if isempty(daspect)
            daspect = [1,0.75,0.30];
        end
        fname = 'ScorSimBlockSquare';
    case 'circle'
        if isempty(daspect)
            daspect = [1,1,0.30];
        end
        fname = 'ScorSimBlockCircle';
    case 'square'
        if isempty(daspect)
            daspect = [1,1,0.30];
        end
        fname = 'ScorSimBlockSquare';
    otherwise
        error('Specified value for "shape" is not recognized.');
end

%% Load figure
open( sprintf('%s.fig',fname) );
fig = findobj('Parent',0,'Name',fname,'Type','figure');
axs = findobj('Parent',fig(1),'Tag',fname,'Type','axes');
obj = findobj('Parent',axs(1),'Tag',fname,'Type','patch');

%% Scale object
sc = scale*daspect./2;
v = obj.Vertices.';                     % Get object vertices
v(4,:) = 1;                             % Make coordinates homogeneous
v = Sx(sc(1))*Sy(sc(2))*Sz(sc(3))*v;    % Scale coordinates
v(4,:) = [];
obj.Vertices = v.';

%% Set color
set(obj,'FaceColor',color,'EdgeColor','none');

%% Migrate patch object
h_b2l = hgtransform('Parent',scorSim.LabBench,'Matrix',H_b2l);
set(obj,'Parent',h_b2l);
delete(fig);

%% Return output(s)
if nargout > 1
    varargout{1} = h_b2l;
end
