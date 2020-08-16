updateScore :-
	%% (dock points for every day or hour or something that something
	%%  sits on the agenda incompleted)

	findall(Deduction,
		(
		 itemOnUserAgendaP(UserAgendaName,Item),
		 hasScore(incompleteByEOD,Item,Deduction)
		),Deductions),
	sumlist(Deductions,Sum),
	view([sum,Sum,deductions,Deductions]),
	logScore(['_perl_hash','AgentID',1,'Event','incompleteUserAgendaItems','Quality',bad,'Score',Sum,'Count',1]),

	%% (add points for successful completion of agenda items, deduct
	%%  them for failure)

	%% (dock points if I don't brush, or take meds)

	%% (we need to input the information from SPSE2 into here)

	%% (we also need to input information from to.do into here)

	%% (we need to also integrate record mechanisms for different
	%%  actions that we reward or penalize.  For instance, record
	%%  different deontic violations.  Assign them a score)

	%% (completed
	%%  (integrate execution engine to penalize certain
	%%   commands, like log-analyzer))

	%% (completed
	%%  (log whenever we open the door))

	%% (completed
	%%  (log whenever we run log-analyzer))

	%% (monitor for good and bad running programs
	%%  (good right now: kdenline) (bad: xboard))

	%% (self-monitor/review behavior in real-time, so if the user is
	%%  going out of their room too frequently, have it message them to
	%%  stop earlier than EOD)

	true.