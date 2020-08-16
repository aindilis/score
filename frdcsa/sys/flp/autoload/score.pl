getProposition(Input,Proposition) :-
	(   alert(TmpPropositon) -> (Proposition = TmpPropositon) ;
	    (	warning(TmpPropositon) -> (Proposition = TmpPropositon) ;
		(   completed(TmpPropositon) -> (Proposition = TmpPropositon) ; Proposition = Input))).

%% atTime([2019-08-20,13:23:01],completed(do(andrewDougherty,prepare(food)))).

%% fassert_argt('Agent1','Yaswi',[term(tellDoctor(CurrentAgent,Agent,TmpStatement)),context(Context)]).
%% Org::FRDCSA::Score::Log

%% hasAssignedContext(score,'Org::FRDCSA::Score::Log').

%% formalog_load_contexts('KBFS-Agent1','KBFS-Yaswi1',[])





%% currentWSMContext(WSMContext),
%% getContextFromWSMContext(WSMContext,Context),

%% fassert_argt('Agent1','Yaswi1',[term(Assertion),context(Context)],Result3),
