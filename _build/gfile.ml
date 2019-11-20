open Graph
open Printf
open Tools
type path = string

(* Format of text files:
   % This is a comment

   % A node with its coordinates (which are not used).
   n 88.8 209.7
   n 408.9 183.0

   % The first node has id 0, the next is 1, and so on.

   % Edges: e source dest label
   e 3 1 11
   e 0 2 8

*)

let write_file path graph =

  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "%% This is a graph.\n\n" ;

  (* Write all nodes (with fake coordinates) *)
  n_iter_sorted graph (fun id -> fprintf ff "n %.1f 1.0\n" (float_of_int id)) ;
  fprintf ff "\n" ;

  (* Write all arcs *)
  e_iter graph (fun id1 id2 lbl -> fprintf ff "e %d %d %s\n" id1 id2 lbl) ;

  fprintf ff "\n%% End of graph\n" ;

  close_out ff ;
  ()

(* Reads a line with a node. *)
let read_node id graph line =
  try Scanf.sscanf line "n %f %f" (fun _ _ -> new_node graph id)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file"

(* Reads a line with an arc. *)
let read_arc graph line =
  try Scanf.sscanf line "e %d %d %s" (fun id1 id2 label -> new_arc graph id1 id2 label)
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file"

(* Reads a comment or fail. *)
let read_comment graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "from_file"

let from_file path =

  let infile = open_in path in

  (* Read all lines until end of file. 
   * n is the current node counter. *)
  let rec loop n graph =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let (n2, graph2) =
        (* Ignore empty lines *)
        if line = "" then (n, graph)

        (* The first character of a line determines its content : n or e. *)
        else match line.[0] with
          | 'n' -> (n+1, read_node n graph line)
          | 'e' -> (n, read_arc graph line)

          (* It should be a comment, otherwise we complain. *)
          | _ -> (n, read_comment graph line)
      in      
      loop n2 graph2

    with End_of_file -> graph (* Done *)
  in

  let final_graph = loop 0 empty_graph in

  close_in infile ;
  final_graph


let export path graph debut fin=
  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n rankdir=LR;\n	size=\"8,5\";\n" ;
  (* double circle src *)
  fprintf ff "node [shape = doublecircle, fillcolor=blue]; LR_%d;\n" debut;
  (* double circle dest *)
  fprintf ff "node [shape = doublecircle, fillcolor=red]; LR_%d;\n" fin ;

  (* double circle src *)
  fprintf ff "node [shape = circle];\n" ;
  e_iter graph (fun id1 id2 lbl -> fprintf ff "LR_%d -> LR_%d [ label = \"%s\"];\n" id1 id2 lbl) ;

  fprintf ff "}\n";
  close_out ff ;
  ()



type projet = {id: int ; ptitnom: string ; nomcomplet: string}
type etudiant = {id: int ; initiale : string}

(* Reads a line with a project. retourne la liste projects mise a jour*)
let read_projet id graph line projects =
  try Scanf.sscanf line "p %s %d %s" (fun ptitnom nbmax nomcomplet -> (new_arc (new_node graph id) id 1 {max = nbmax ; current = 0 ; visited = false ; cost = 0}) ,
                                                                      {id = id; ptitnom = ptitnom ; nomcomplet = nomcomplet} :: projects) (*puits id=1*)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "import projet"

(* Reads a line with an etudiant. retourne la liste etudiants mise a jour *)
let read_etudiant id gr line projects etudiants =
  try Scanf.sscanf line "e %s %s %s" (fun initiales str_proj1 str_proj2 -> (*fait lien projet1 <- etudiant -> projet2 et etudiant et source -> etudiant*)
      let graph = new_node gr id in
      let rec search str_proj = function
        |[] -> failwith "Projet non défini"
        |proj :: r -> if proj.ptitnom = str_proj then proj.id else search str_proj r
      in new_arc (new_arc (new_arc graph 0 id {max = 1 ; current = 0 ; visited = false ; cost = 0}  (*source -> etudiant*)) id (search str_proj2 projects) {max = 1 ; current = 0 ; visited = false ; cost = 0}) id (search str_proj1 projects) {max = 1 ; current = 0 ; visited = false ; cost = 1} , 
         {id = id ; initiale = initiales} :: etudiants)
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "import etudiant"


(* import affectations as string graph*)
let import path = 
  let infile = open_in path in

  (* Read all lines until end of file. 
   * n is the current project/etudiant counter. *)
  let rec loop n graph projet etudiant =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let (n2, graph2, pro, etud) =
        (* Ignore empty lines *)
        if line = "" then (n, graph, projet, etudiant)

        (* The first character of a line determines its content : p or e. *)
        else match line.[0] with
          | 'p' -> (match read_projet n graph line projet with (gr, proj) -> n+1, gr, proj, etudiant)
          | 'e' -> (match read_etudiant n graph line projet etudiant with (gr, etud) -> n+1, gr, projet, etud)

          (* It should be a comment, otherwise we complain. *)
          | _ -> (n, read_comment graph line, projet, etudiant)
      in      
      loop n2 graph2 pro etud

    with End_of_file -> graph, projet, etudiant (* Done *)
  in

  let final_graph = match loop 2 (new_node (new_node empty_graph 0) 1) [] [] with (gr, p, e) -> gr in (*acu n fixé à 2 car puits et source sont déjà 1 et 2*)

  close_in infile ;
  final_graph