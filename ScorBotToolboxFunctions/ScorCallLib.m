function varargout = ScorCallLib(libname,funcName,varargin)
% SCORCALLLIB calls function in C shared library using calllib.m for 32-bit
% systems or ScorServerCmd.m for 64-bit systems.
%   [x1,...,xN] = SCORCALLLIB(funcName,arg1,...,argN) calls a
%   function funcName using either calllib.m (for 32-bit Windows OS) or
%   ScorServerCmd.m (for 64-bit Windows OS).
%
%   J. Donnal & M. Kutzer, 16Jul2019, USNA

persistent osbits

%% Check operating system
if isempty(osbits)
    switch computer
        case 'PCWIN'
            % 32-bit OS
            osbits = 32;
        case 'PCWIN64'
            % 64-bit OS
            osbits = 64;
    end
end

%% Execute 
switch osbits
    case 32
        % 32-bit OS
        % -> [...] = calllib(libname,funcname,...);
        % NOTE: I am using a work-around for the variable output nature of
        %       the calllib.m function call that leverages "eval".
        funcSTR = '[';
        for i = 1:nargout
            funcSTR = sprintf('%svarargout{%d}',funcSTR,i);
            if i < nargout
                funcSTR = sprintf('%s,',funcSTR);
            end
        end
        funcSTR = sprintf('%s] = calllib(libname,funcName,varargin{:});',funcSTR);
        eval(funcSTR);
    case 64
        % 64-bit OS
        % -> ScorServerCMD
        % Account for case-by-case discrepancies between calllib and 
        % ScorServerCmd.
        
        % Adjust inputs 
        switch funcName
            case 'RControl'
                varargin{1} = char(varargin{1});    % uint8('A') -> 'A'
            case 'RHome'
                varargin{1} = char(varargin{1});    % uint8('A') -> 'A'
            case 'RGetXYZPR'
                varargin(:) = [];   % Do not input x,y,z,p,r
            case 'RGetBSEPR'
                varargin(:) = [];   % Do not input b,s,e,p,r
        end
        
        % Call server command
        [status,data] = ScorServerCmd('RGetXYZPR',varargin{:});
        
        % Adjust outputs
        if nargout > 0
            switch funcName
                case 'RIsError'
                    varargout{1} = data;    % Output error code only
                otherwise
                    varargout{1} = status;
            end
            
            if nargout > 1
                % TODO - Make this faster!
                for i = 1:numel(data)
                    if numel(varargout) < nargout
                        % Append data
                        varargout{end+1} = data(i);
                    else
                        break;
                    end
                end
            end
        end         
    otherwise
         error('OSBITS variable not set to known value.');
end