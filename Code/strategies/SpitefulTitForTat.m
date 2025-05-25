function Move = SpitefulTitForTat(History)
% A player starts by cooperating and then mimics the previous action of the opponent until
% opponent defects twice in a row, at which point player always defects.
if  History(1,1)==0
    Move = 1;
elseif ~isempty(strfind(History(:,2)',[2, 2])) %#ok<STREMP>
    Move = All_D(History);
else
    Move = TitForTat(History);
end
end