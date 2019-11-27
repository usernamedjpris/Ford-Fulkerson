open Graph
(*#use "/mnt/c/Users/FACHE Rémi/Documents/Programmation/ocaml/Ford-Fulkerson/graph.ml"*)
(*
let gmap g f = 
let rec loop node_r f=
match node_r with
|empty_graph->empty_graph
|(n,arc)::r->(n,(e_fold arc (fun acc id1 id2 lab -> (f (id1 id2 lab))::acc) empty_graph))::(loop r f) 
in
loop g f *)
let clone_nodes g = n_fold g new_node empty_graph;;
(*ajoute lab au flot courant de l'arc *) 
let add_arcs g id1 id2 lab = 
  match find_arc g id1 id2 with
    |None -> new_arc g id1 id2 (lab)
    |Some x -> new_arc g id1 id2 (lab+x);;


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

let not_visited_node gr id=
  try let out = (out_arcs gr id) in
    let rec loop reste =
      match reste with 
        |[] -> true
        |(id2,lab)::r-> if (lab.visited) then false else loop r in
      loop out
  with Not_found -> false;;


let make_ecart gr =
  e_fold gr (fun gr id1 id2 lab -> new_arc (new_arc gr id1 id2 {lab with current = lab.max-lab.current}) id2 id1 lab) (clone_nodes gr);;


let rec find_path_ford gr id idfin accu =
  if id = idfin then accu else (
    try 
      let out = (out_arcs gr id) in 
      let rec loop reste =
        match reste with 
          | [] -> []
          | (id2,lab) :: r -> if ((lab.current > 0) && (not_visited_node gr id2))  then 
                let chemin = (find_path_ford (new_arc gr id id2 { lab with visited = true }) id2 idfin ((id,(id2,lab))::accu) ) in
                  match chemin with
                    | [] -> loop r
                    | _ -> chemin
              else loop r 
      in
        loop out
    with Not_found -> [])
(* let () = Printf.printf "%d->%d   %s\n%!" id id2 (string_of_label lab) in *)


let rec print_path = function 
  | [] -> Printf.printf "\n%!"
  | (id,(id2,lab))  :: lereste -> Printf.printf "%d->%d  %s\n%!" id id2 (string_of_label lab)


let rec max_flow res = function 
  | [] -> res
  | (id,(id2,lab)) :: lereste -> max_flow (min lab.current res) lereste


let update_residu gre path lemax = 
  let rec loop chem acugraph =
    match chem with 
      | [] -> acugraph
      | (src, (dest, lab)) :: r -> let arc_inverse = find_arc gre dest src in 
            match arc_inverse with
              |None -> raise Not_found
              |Some lab_inv ->
                  let graphe_moins=(new_arc acugraph src dest {lab with current = lab.current - lemax}) in
                  let graphe_plus = (new_arc graphe_moins dest src {lab_inv with current = lab_inv.current + lemax}) in
                    loop r graphe_plus
  in loop path gre


let update_graphe_initial gre gri = 
  e_fold gri (fun gr src dest lab -> 
               match find_arc gre dest src with 
                 | None -> raise Not_found
                 | Some lab_inv -> new_arc gr src dest lab_inv) (clone_nodes gri)




let ford_fulkerson2 gr debut fin =
  let gre = make_ecart gr in
  let rec loop gre d f =
    let chemin = find_path_ford gre d f [] in
      match chemin with
        |[] -> update_graphe_initial gre gr
        |_ -> loop (update_residu gre chemin (max_flow 9999 chemin)) d f
  in
    loop gre debut fin


(* fin Fulk______________________________________*)

      




let empty_parent={origin=(-1);arc={max=0;current=0;visited=false;cost=0}}


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
                  if cout < (get_current_cost l id2) && lab.current >0 then 
                    let new_liste = maj_node_list l id2 cout {origin=id_courant;arc=lab} false in
                      loop r new_liste
                  else
                    loop r l
        in
          loop out l
      with Not_found -> [])
  in
    loop0 gr iddebut idfin liste

let max_flow_min_cost gr debut fin =
  let gre = make_ecart gr in
  let rec loop gre d f =
    let chemin = find_path gre d f in
      match chemin with
        |[] -> update_graphe_initial gre gr   (*to get the final graph *)
        |_ -> loop (update_residu gre chemin (max_flow 9999 chemin)) d f
  in
    loop gre debut fin

(* Tests *)
(*
let arc={max=1;current=0;visited=false;cost=0};;
let arc_grand={max=3;current=0;visited=false;cost=0};;
let arc2={max=1;current=0;visited=false;cost=0};;
let graphe_ini =((1,(2,arc ) :: (3,arc2):: [] ) :: (2,(3,arc ) :: [] ):: (3,(4,arc_grand ) :: [] ) :: (4,(1,arc ) :: [] ):: []);;
let graphe_reverse_need =((1,(2,arc ) :: (3,arc):: [] ) :: (2,(3,arc ) :: (4,arc )::[] ):: (3,(4,arc ) :: [] ) :: (4,(1,arc ) :: [] ):: []);;
let gre= make_ecart graphe_ini
let cloned=clone_nodes gre;;
let gre_get_arc1_2={max=2;current=2;visited=false;cost=0}
let gre_get_arc2_3={max=2;current=2;visited=false;cost=0}
let path = (1,(2,gre_get_arc1_2))::(2,(3,gre_get_arc2_3))::[]
let updated =update_residu gre path 1;;
let updated_ini = update_graphe_initial updated graphe_ini;;
updated;;
let chemin= find_path_ford updated 1 4 [];;
let full= ford_fulkerson2 graphe_reverse_need  1 4;;
*)
(*let res = find_path ((1,(2,(20,0)) :: (4,(10,0)) :: [] ) :: (2,(4,(20,0)) :: [] ) :: (2,(4,(20,0)) :: [] ) :: (4,(1,(20,0)) :: [] ) :: []) 1 4 [];;*)

(* min cost *) (*
let arc={max=1;current=0;visited=false;cost=0};;
let arc_grand={max=3;current=0;visited=false;cost=0};;
let arc2={max=1;current=0;visited=false;cost=0};;
let arc_couteux={max=3;current=0;visited=false;cost=1};;
let graphe_ini =((1,(2,arc ) :: (3,arc2):: [] ) :: (2,(3,arc) :: [] ):: (3,(4,arc_grand ) :: [] ) :: (4,(1,arc ) :: [] ):: []);;
let graphe_cout =((1,(2,arc ) :: (3,arc_grand):: [] ) :: (2,(3,arc_couteux ) :: [] ):: (3,(4,arc_grand ) :: [] ) :: (4,(1,arc ) :: [] ):: []);;
let graphe_reverse_need =((1,(2,arc ) :: (3,arc):: [] ) :: (2,(3,arc ) :: (4,arc )::[] ):: (3,(4,arc ) :: [] ) :: (4,(1,arc ) :: [] ):: []);;
let gre= make_ecart graphe_ini
let cloned=clone_nodes gre;;
let gre_get_arc1_2={max=2;current=2;visited=false;cost=0}
let gre_get_arc2_3={max=2;current=2;visited=false;cost=0}
let path = (1,(2,gre_get_arc1_2))::(2,(3,gre_get_arc2_3))::[]
let updated =update_residu gre path 1;;
let updated_ini = update_graphe_initial updated graphe_ini;;
updated;;
let chemin= find_path updated 1 4 ;;
graphe_ini;;
let full= max_flow_min_cost graphe_ini 1 4;;
graphe_cout;;
let full2= max_flow_min_cost graphe_cout 1 4;;*)
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
