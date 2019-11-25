open Graph 
(*#use "/mnt/c/Users/FACHE Rémi/Documents/Programmation/ocaml/Ford-Fulkerson/graph.ml" *)
(*
let gmap g f = 
let rec loop node_r f=
match node_r with
|empty_graph->empty_graph
|(n,arc)::r->(n,(e_fold arc (fun acc id1 id2 lab -> (f (id1 id2 lab))::acc) empty_graph))::(loop r f) 
in
loop g f *)
let clone_nodes g = n_fold g new_node empty_graph;;
let add_arcs g id1 id2 lab = 
  match find_arc g id1 id2 with
  |None -> new_arc g id1 id2 (lab)
  |Some x -> new_arc g id1 id2 (lab+x);;

(* peut etre directement remplacée par new_arc *)
let add_arcs_c g id1 id2 lab = 
  match find_arc g id1 id2 with
  |None -> raise Not_found
  |Some x -> new_arc g id1 id2 lab;;

(* la fonction new_arc ne crée pas de node, parmi ceux qui lui sont passés (tous via l'accu) elle ajoute des arcs=> on reconstruit le graphe comme ça => si noeud inexistant (ec: empty_graph => raise exception )*)
let gmap g f = e_fold g (fun gr id1 id2 lab-> new_arc gr id1 id2 (f lab)) (clone_nodes g);;
(*
let res= gmap empty_graph int_of_string;;
*)
type labels = 
  { max: int;
    current: int;
    visited: bool;
    cost: int;
    sign:int}
type parents=
  {origin:int;
   arc:labels}

let label_of_string s =
  {max=(int_of_string s);
   current=0;
   visited=false ;
   cost= 0 ;
   sign=1}                        (*<- /!\ a remplacer avec un sscanf !!!!!!*)

let string_of_label l=
  "["^string_of_int(l.current)^"/"^string_of_int(l.max)^"]("^string_of_int(l.cost)^") A"^string_of_int(l.sign)

(* add_arcs g accu_arcs *)
(* find arcs to use then add_arcs_labels min accu labels_arcs *)
(* List.reverse à la fin *)
(*n fold concatene 2 graphs sans les arcs=> add_arcs de n_fold *)

let not_visited_node gr id=
  try let out = (out_arcs gr id) in
    let rec loop reste =
      match reste with 
      |[] -> true
      |(id2,lab)::r-> if (lab.visited) then false else loop r in
    loop out
  with Not_found -> false;;

let make_ecart gr =
  e_fold gr (fun gr id1 id2 lab -> new_arc (new_arc gr id1 id2 {lab with current = lab.max-lab.current}) id2 id1 {lab with sign = -1}) (clone_nodes gr);;

let find_path_ford gr id idfin accu =
  let gre =  make_ecart gr in
  let rec find_path gra id idfin accu =
    if id = idfin then accu else (
      try 
        let out = (out_arcs gra id) in 
        let rec loop reste =
          match reste with 
          | [] -> []
          | (id2,lab) :: r -> if ((lab.current > 0) && (not_visited_node gra id2))  then 
              let () = Printf.printf "%d->%d   %s\n%!" id id2 (string_of_label lab) in
              let chemin = (find_path (add_arcs_c (add_arcs_c gra id2 id { lab with visited = true } (* pas necessaire normalement*) ) id id2 { lab with visited = true }) id2 idfin ((id,(id2,lab))::accu) ) in
              match chemin with
              | [] -> loop r
              | _ -> chemin
            else loop r 
        in
        loop out
      with Not_found -> [])
  in find_path gre id idfin accu 

let rec print_path = function 
  | [] -> Printf.printf "\n%!"
  | (id,(id2,lab))  :: lereste -> Printf.printf "%d->%d  %s\n%!" id id2 (string_of_label lab)

let rec max_flow res = function 
  | [] -> res
  | (id,(id2,lab)) :: lereste -> max_flow (min (lab.max - lab.current) res) lereste

(* J'ai essayé de faire de mon mieux avec des labels de partout mais il y a une fatal error que je n'explique pas :(. l'encadrant m'a soufflé l'idée d'implémentation suivante :
   remarque : il faut faire un graphe d'ecart avec des entiers (comme label)
        -> faire des find_path dessus
        -> faire des update dessus : ça consiste à 
                                        -> réduire le flot résiduel* de maxflow  -> *flot résiduel = flot de l'arc qui pointe dans le sens du chemin trouvé 
                                        -> augmenter le flot en contresens de maxflow
        -> à la toute fin : faire une fonction update_graphe_initial qui prend en entrée : le graphe d'ecart et le graphe initial
                                        -> find arc inversé (id2-> id1) par rapport aux arcs de graphe initial (id1->id2) sur le graphe d'ecart 
                                        -> pour y lire le flow et le remplacer sur le graphe initial        
   on peut donc enlever sign de labels_____________*)

let update_residu gre path lemax = 
  let rec loop chem acugraph =
    match chem with 
    | [] -> acugraph
    | (src, (dest, lab)) :: r -> loop r (add_arcs_c (add_arcs_c acugraph src dest {lab with current = lab.current - lemax}) dest src {lab with current = lab.current + lemax})
  in loop path (clone_nodes gre)

let update_graphe_initial gre gri = 
  e_fold gri (fun gr src dest lab -> match find_arc gre dest src with 
      | None -> failwith "residual edge doesn't exist\n" 
      | Some labe -> add_arcs_c gri src dest labe) (clone_nodes gri)

let ford_fulkerson2 gr debut fin =
  let gre = make_ecart gr in
  let rec loop gre d f =
    let chemin = find_path_ford gr d f [] in
    let () = print_path chemin in                (*debuggage*)
    match chemin with
    |[] -> update_graphe_initial gre gr
    |_ -> loop (update_residu gre chemin (max_flow 9999 chemin)) d f
  in
  loop gre debut fin

(* fin rajout______________________________________*)




(*let parcours_larg gr id idfin accu =
  let gre =  make_ecart gr in
  let out = (out_arcs gre id) in
  let rec loop = function 
    | [] -> []
    | (id2,lab) :: r -> if (((lab.current>0) && (not_visited_node gre id2)) then 
            let chemin = (find_path_ford (add_arcs_c gre id id2 { lab with visited = true }) id2 idfin ((id,(id2,lab))::accu) ) in
            match chemin with
            | [] -> loop r
            | _ -> chemin
          else loop r 
  in loop out*)


let empty_parent={origin=(-1);arc={max=0;current=0;visited=false;cost=0;sign=1}}

let init_list gr iddebut=
  n_fold gr (fun accu id->if id =iddebut then (iddebut,0,empty_parent,false)::accu else (id,9999,empty_parent,false)::accu) []

let maj_node_list liste id cost parent marked=
  ((id, cost, parent, marked) ::  List.filter (fun (i, cost, parent, marked)->(i<>id) ) liste);; (*List.remove_assoc id liste ;; *)

let maj_list_mark liste id =
  let rec loop l id =
    match l with
    |[]->raise Not_found
    |(id1, cost,parent,marked)::r -> if id1 = id then maj_node_list liste id cost parent true else loop r id
  in
  loop liste id;;

let select_node liste =
  let rec loop elected min reste=
    match reste with
    |[] -> if elected <> (-1) then elected else raise Not_found
    |(id, cost,parent,marked)::r ->if (marked = false && cost <min ) then loop id cost r else loop elected min r
  in
  loop (-1) 9999 liste;;

let rec get_current_cost liste id=
  match liste with
  |[]-> raise Not_found
  |(id1, cost, parent, marked)::r-> if id1 = id then cost else get_current_cost r id


(* si on veut de meilleures perfs => 
   1)remplacer la liste par un Array (mutable) => évite de faire des parcours de liste pour trouver chq element
   la correspondance id node, index tableau étant instantanée,
   2) si possibilité il y avait de modifier la définition d'un graphe, on créerait un type label_node et on n'aurait pas à maintenir de liste  
*)
let reconstitution liste idfin=
  let rec loop l accu idwanted=
    match l with
    |[] -> accu
    |(id, cost, parent, marked)::r ->
      if id = idwanted then (
        if parent.origin = (-1)  then
          accu
        else
          loop liste ((parent.origin,(id,parent.arc))::accu) (parent.origin) )
      else 
        loop r accu idwanted
  in
  loop liste [] idfin


(*remplacer find_path par un find_shortest_path_available => dijkstra+check lab.max - lab.current) > 0 *)
(* via a list of (id,cost, next *)
let find_path gr iddebut idfin =

  let liste = init_list gr iddebut in 
  let rec loop0 gr id_courant idfin l =
    if id_courant = idfin then reconstitution l idfin else (
      try let out = (out_arcs gr id_courant) in 
        let rec loop reste l =
          match reste with 
          |[]->let new_liste = maj_list_mark l id_courant in
            loop0 gr (select_node new_liste) idfin  new_liste
          |(id2,lab) :: r -> let cout = (lab.cost + (get_current_cost l id_courant)) in 
            if cout < (get_current_cost l id2) && (lab.max - lab.current) >0 then 
              let new_liste = maj_node_list l id2 cout {origin=id_courant;arc=lab} false in
              loop r new_liste
            else
              loop r l
        in
        loop out l
      with Not_found -> [])
  in
  loop0 gr iddebut idfin liste

let update_graphe lemax g path =
  let rec loop lemax gr path =
    match path with 
    |[] -> gr
    |(id1, (id2, lab))::r ->
      let new_lab = { lab with current = (lab.current + lab.sign * lemax) ; visited = false } in
      loop lemax (add_arcs_c gr id1 id2 new_lab ) r
  in
  loop lemax g path


let ford_fulkerson gr debut fin =
  let rec loop gr d f =
    let chemin = find_path_ford gr d f [] in
    let () = print_path chemin in                (*debuggage*)
    match chemin with
    |[] -> gr
    |_ -> loop (update_graphe (max_flow 9999 chemin) gr chemin) d f
  in
  loop gr debut fin


let max_flow_min_cost gr debut fin =
  let rec loop gr d f=
    let chemin = find_path gr d f in
    match chemin with
    |[]->gr
    |_->loop (update_graphe (max_flow 9999 chemin) gr chemin) d f
  in
  loop gr debut fin;;

(*let res = find_path ((1,(2,(20,0)) :: (4,(10,0)) :: [] ) :: (2,(4,(20,0)) :: [] ) :: (2,(4,(20,0)) :: [] ) :: (4,(1,(20,0)) :: [] ) :: []) 1 4 [];;*)

(*
let majed=maj_node_list (init_list ((1,(2,(20,0)) :: (4,(10,0)) :: [] ) :: (2,(4,(20,0)) :: [] ) :: (3,(4,(20,0)) :: [] ) :: (4,(1,(20,0)) :: [] ) :: []) 0) 4 42 {origin=3; arc = {max=25;current=0;visited=false;cost=10}} true;;
majed;;
reconstitution majed 4;; (* chemin censé exister => ok *)
let maj2=(maj_node_list majed 2 22 {origin=0; arc = {max=25;current=0;visited=false;cost=10}} true);;
maj2;;
let maj3=(maj_node_list maj2 3 20 {origin=2; arc = {max=25;current=0;visited=false;cost=10}} false);;
maj3;;
reconstitution maj3 4
;;
get_current_cost maj3 2;;
select_node maj3;;
maj_list_mark maj3 1;;
*)
