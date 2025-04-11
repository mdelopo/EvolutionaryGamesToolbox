function Move = Alternator(History)
%Alternates between cooperating and defecting
%Starts by cooperating in the first round
    
% First move: cooperate
    if History(1,1) == 0
        Move = 1;
        return;
    end 
% Count how many actual moves have been made
    rounds_played = nnz(History(:,1) ~= 0); %ignores empty or initialized rounds 

    if mod(rounds_played, 2) == 0
        Move = 2;  
    else
        Move = 1; 
    end
end