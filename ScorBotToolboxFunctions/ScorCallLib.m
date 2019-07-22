function varargout = ScorCallLib(libname,funcName,varargin)
% SCORCALLLIB calls function in C shared library using calllib.m for 32-bit
% systems or ScorServerCmd.m for 64-bit systems.
%   [x1,...,xN] = SCORCALLLIB(funcName,arg1,...,argN) calls a
%   function funcName using either calllib.m (for 32-bit Windows OS) or
%   ScorServerCmd.m (for 64-bit Windows OS).
%
%   J. Donnal & M. Kutzer, 16Jul2019, USNA

persistent osbits

%% Set debug flag
debugFlag = false;

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
        [status,data] = ScorServerCmd(funcName,varargin{:});
        
        % Show debug information
        if debugFlag
            fprintf('\tStatus - %d\n',status);
            if ischar(data)
                fprintf('\t  Data - %s\n',data);
            else
                fprintf('\t  Data - [')
                for i = 1:numel(data)
                    fprintf('%.4f',data(i));
                    if i < numel(data)
                        fprintf(', ');
                    end
                end
                fprintf(']\n');
            end
        end
        
        % Adjust outputs
        if nargout > 0
            switch funcName
                case 'RIsError'
                    varargout{1} = data;    % Output error code only
                case 'RGetJaw'
                    varargout{1} = data;
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
            
            if nargout > numel(varargout)
                for i = (numel(varargout)+1):nargout
                    varargout{i} = [];
                end
            end
        end         
    otherwise
         error('OSBITS variable not set to known value.');
end

%% Display Error Codes
switch funcName
    case 'RIsError'
        if debugFlag
            fprintf('--------------\n');
            st = dbstack(1);
            switch st(1).name
                case 'ScorIsReady'
                    % Display line number
                    fprintf('\tIn %s (line %d)\n',st(1).name,st(1).line);
                otherwise
                    dbstack(1);
            end
        end
        % Parse error code
        errStruct = ScorParseErrorCode(varargout{1});
        % Display error to command window
        %ScorDispError(errStruct,'Display All');
        ScorDispError(errStruct,'Display Critical');
        if errStruct.Code ~= 0
            % Update log and last error
            ScorErrorLastSet(errStruct.Code);
            ScorErrorLogWrite(errStruct.Code);
        end
    case 'RAddToVecXYZPR'
        % Clear lingering errors
        eCode = ScorErrorLastGet;
        switch eCode
            case 908
                % Point out of workspace
                ScorErrorLastSet(0);
            case 911
                % User didn't use "ScorWaitForMove"
                ScorErrorLastSet(0);
        end
end
