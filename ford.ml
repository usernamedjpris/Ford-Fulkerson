open Graph
open Tools

let not_visited_node gr id=
  try let out = (out_arcs gr id) in
    let rec loop reste =
      match reste with 
        |[] -> true
        |(id2,lab)::r-> if (lab.visited) then false else loop r in
      loop out
  with Not_found -> false;;

(*-lab current si flow initial != 0*)
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
  | (id,(id2,lab)) :: lereste -> print_path lereste ; Printf.printf "%d->%d  %s\n%!" id id2 (string_of_label lab) 


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
                  let graphe_moins = (new_arc acugraph src dest {lab with current = lab.current - lemax}) in
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


let ford_fulkerson2_verbose gr debut fin =
  let gre = make_ecart gr in
  let rec loop gre d f =
    let chemin = find_path_ford gre d f [] in
    let () = print_path chemin in 
      match chemin with
        |[] -> update_graphe_initial gre gr
        |_ -> let max_f = max_flow 9999 chemin in
        let () = Printf.printf "max flow %d\n%!" max_f in
        loop (update_residu gre chemin max_f) d f  
  in
    loop gre debut fin


(* fin Fulk______________________________________*)
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
