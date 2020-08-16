hasScore(Action,Item,Deduction) :-
	Item =.. [Type|_Args],
	scoreForAction(Action,Type,Deduction).

scoreForAction(incompleteByEOD,alert,-10).
scoreForAction(incompleteByEOD,warning,-25).
scoreForAction(incompleteByEOD,critical,-50).
scoreForAction(incompleteByEOD,planStep,-25).
%% scoreForAction(incompleteByEOD,callProlog,0).
%% scoreForAction(incompleteByEOD,execute,0).

scoreForAction(removed,alert,-40).
scoreForAction(removed,warning,-100).
scoreForAction(removed,critical,-200).
scoreForAction(removed,planStep,-100).
%% scoreForAction(removed,callProlog,0).
%% scoreForAction(removed,execute,0).

scoreForAction(completed,alert,40).
scoreForAction(completed,warning,100).
scoreForAction(completed,critical,200).
scoreForAction(completed,planStep,100).
%% scoreForAction(removed,callProlog,0).
%% scoreForAction(removed,execute,0).
