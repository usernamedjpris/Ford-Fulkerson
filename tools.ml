(*open Graph *)
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

    


(* rq: l graph à la sortie du ficher est un string, le mod avec gmap int_fo_string pour pouvoir considérer les labels comme des nombres et non des strings *) 
let clone_nodes g = n_fold g new_node empty_graph;;
let add_arcs g id1 id2 lab = 
  match find_arc g id1 id2 with
    |None -> new_arc g id1 id2 (lab)
    |Some x -> new_arc g id1 id2 (lab+x);; 

(*
let gmap g f = 
let rec loop node_r f=
match node_r with
|empty_graph->empty_graph
|(n,arc)::r->(n,(e_fold arc (fun acc id1 id2 lab -> (f (id1 id2 lab))::acc) empty_graph))::(loop r f) 
in
loop g f *)

(* la fonction new_arc ne crée pas de node, parmi ceux qui lui sont passés (tous via l'accu) elle ajoute des arcs=> on reconstruit le graphe comme ça => si noeud inexistant (ec: empty_graph => raise exception )*)
let gmap g f = e_fold g (fun gr id1 id2 lab-> new_arc gr id1 id2 (f lab)) (clone_nodes g);;
(*
let res= gmap empty_graph int_of_string;;
*)
type labels =
    { max: int;
      current: int }
let label_of_string s=
  {max=(int_of_string s);current=0}
let string_of_label l=
  string_of_int(l.current)

(* find arcs to use then add_arcs_labels min accu labels_arcs *)
(* List.reverse à la fin *)
let rec find_path gr id idfin accu =
  if id = idfin then accu else
    try let out=out_arcs id gr in 
      let rec loop reste =
        match reste with 
          |[]->[]
          |(id2,(m,c))::r-> if (m -c >0) then find_path gr id2 idfin ((id2,(m,c))::accu) else loop r   (* sinon mettre 2 ids si matter *)
      in
        loop out
    with Not_found ->[]
                       [];;


