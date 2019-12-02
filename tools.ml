open Graph

let clone_nodes g = n_fold g new_node empty_graph

(*ajoute lab au flot courant de l'arc *) 
let add_arcs g id1 id2 lab = 
  match find_arc g id1 id2 with
    |None -> new_arc g id1 id2 (lab)
    |Some x -> new_arc g id1 id2 (lab+x);;


(* la fonction new_arc ne crée pas de node, parmi ceux qui lui sont passés (tous via l'accu) elle ajoute des arcs=> on reconstruit le graphe comme ça => si noeud inexistant (ec: empty_graph => raise exception )*)
let gmap g f = e_fold g (fun gr id1 id2 lab-> new_arc gr id1 id2 (f lab)) (clone_nodes g);;

type labels = 
    { max: int;
      current: int;
      visited: bool;
      cost: int;
    }
type parents=
    {origin:int;
     arc:labels}


let label_of_string s =
  {max=(int_of_string s);
   current=0;
   visited=false ;
   cost= 0 ;}                    


let string_of_label l=
  "["^string_of_int(l.current)^"/"^string_of_int(l.max)^"]("^string_of_int(l.cost)^")"


let empty_parent={origin=(-1);arc={max=0;current=0;visited=false;cost=0}}

