function str = VlcUnTeX(str,varargin)
%function str = VlcUnTeX(str,varargin)
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Replace troublesome tex formatting codes by literal

if iscell(str)
  % vectorize
  for ii = 1:length(str)
    str{ii}	= pUnTeX(str{ii},varargin{:});
  end
  return

elseif ~ischar(str)
  return

end

str	= strrep(str,'\','\\');
str	= strrep(str,'_','\_');
