# what is in a goal?  a goal is a more complex data structure, I would
# probably do well to read Justin's writing on the subject and to
# understand them before proceeding, though they still need
# integration, and clear still needs to be made into a seemlessly
# installable debian package.


# having said  this, we can  recognize certain goals or  goal clusters
# and then consider the relative importance of these different goals.

# it would also help to have a language for structuring and discussing
# these goals.  for this some of the systems for linguistic KR such as
# recognizing "after that", etc. would come in very handy.

# Note that most goals are consistent with other goals, for instance
# cause /dev/hdb4 to not be mounted by default, the question is why?
# because we don't want to cause damage to the drive.  The system may
# consider asking us, why? until it UNDERSTANDS the reason for doing
# something.  What don't we want to cause damage to the drive?
# Because we will lose our data then.  Why, because we want to
# increase the number of backup copies of our data.  Also we don't
# want to loose stuff that may not have been copied over from the
# system when it crashed.

# If proceeding with these question elicitations, we eventually
# connect and root the major reasons for a goal to other goals, we can
# use our semantic similarity analysis to determine.

#  Basic algorithm:

sub AddGoal {
  my $goal = QueryUser(Query => "Goal?");

  # now obtain reasons for this goal
  # to prevent continous process, we decay against justification branch depth and importance

  my $depth = 1;
  my @reasons = QueryUser
      (Type => "List",
       Query => "What is the importance of this goal?  What does it serve to accomplish?  Please list the primary reasons.");
  # try to match these reasons
  MatchGoals();

  # this can be the phase for linking a goal right here determine
  # whether it is necessary or sufficient either way, the relation is
  # sort of abelien as to parent and child, there is a symbiosis

  # assert this relation somewhere, and then retrieve it for each of
  # the subgoals, but again, only have so much interest and once it
  # falls beneath threshold, metered by a general indication of
  # importance

  # based on match data and personal ordering, based on contexts, then order the goals
  OrderGoals();

  # this same system can be used then to represent reading goals, it
  # simply has to recognize that the reading is a goal of this type

  # the requesting agent must be kept in mind
}
