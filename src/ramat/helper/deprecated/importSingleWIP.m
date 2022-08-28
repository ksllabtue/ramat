function out = importSingleWIP(varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if (nargin == 2 && ~isempty(varargin{2}))
    guiOut = varargin{2};
end
if (nargin == 0)
    return
end

fullFileName = varargin{1};

%% Check whether WITIO reader is activated
if ~witio_isenabled()
    %enableWITIO();
end

% Make sure all helper files of the WITIO module are in the MATLAB path.
enableWITIOhelper();

%% Import .wip file
[O_wid, O_wip, ~] = wip.read(fullFileName, '-all');

% Output to out=[]
f = 1;

% Default: import everything, including text data objects
for i = 1:size(O_wid,1)
    out(i, 1) = importSingleWIData(O_wid(i, 1));
end

end

