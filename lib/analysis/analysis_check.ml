
type ('a, 'b) check = 'a -> 'b -> bool


let check_soundness_of_istate (events : Lang.Interp.IState.event list) =
  (* just iterate through all variables in all events and check that the concrete value is within the abstract. *)
  2



