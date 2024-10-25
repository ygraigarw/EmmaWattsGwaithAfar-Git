function str = pUnTeX(str,varargin)

% replace unintentional tex formatting codes by literal
%
% example: TOTAL_MEAN_DIRECTION --> 
%
% _ --> \_

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
