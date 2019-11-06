type id = int

type 'a out_arcs = (id * 'a) list

(* A graph is just a list of pairs: a node & its outgoing arcs. *)
type 'a graph = (id * 'a out_arcs) list

exception Graph_error of string

let empty_graph = []

let node_exists gr id = List.mem_assoc id gr

let out_arcs gr id =
  try List.assoc id gr
  with Not_found -> raise (Graph_error ("Node " ^ string_of_int id ^ " does not exist in this graph."))

let find_arc gr id1 id2 =
  let out = out_arcs gr id1 in
  try Some (List.assoc id2 out)
  with Not_found -> None

let new_node gr id =
  if node_exists gr id then raise (Graph_error ("Node " ^ string_of_int id ^ " already exists in the graph."))
  else (id, []) :: gr

let new_arc gr id1 id2 lbl =

  (* Existing out-arcs *)
  let outa = out_arcs gr id1 in

  (* Update out-arcs.
   * remove_assoc does not fail if id2 is not bound.  *)
  let outb = (id2, lbl) :: List.remove_assoc id2 outa in
  
  (* Replace out-arcs in the graph. *)
  let gr2 = List.remove_assoc id1 gr in
  (id1, outb) :: gr2

let n_iter gr f = List.iter (fun (id, _) -> f id) gr

let n_iter_sorted gr f = n_iter (List.sort compare gr) f

let n_fold gr f acu = List.fold_left (fun acu (id, _) -> f acu id) acu gr

let e_iter gr f = List.iter (fun (id1, out) -> List.iter (fun (id2, x) -> f id1 id2 x) out) gr

let e_fold gr f acu = List.fold_left (fun acu (id1, out) -> List.fold_left (fun acu (id2, x) -> f acu id1 id2 x) acu out) acu gr

