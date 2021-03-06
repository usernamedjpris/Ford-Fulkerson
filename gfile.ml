open Graph
open Printf
open Tools
type path = string

(* Format of Gfiles:
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


let export_visible path graph debut fin =
  (* Open a write-file. *)
  let ff = open_out path in
  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n rankdir=LR;\n	size=\"8,5\";\n" ;
  (* double circle src *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=blue]; %d;\n" debut;
  (* double circle dest *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=red]; %d;\n" fin ;
  (* double circle src *)
  fprintf ff "node [shape = circle, style=filled, fillcolor=\"#dde0ea\", color=\"#737683\"];\n" ;
  e_iter graph (fun id1 id2 lbl -> fprintf ff "%d -> %d [ label = \"%s\"];\n" id1 id2 lbl) ;
  fprintf ff "}\n";
  close_out ff ;
  ()

let export_simplified path graph debut fin =
  (* Open a write-file. *)
  let ff = open_out path in
  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n rankdir=LR;\n  size=\"8,5\";\n" ;
  (* double circle src *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=blue]; %d;\n" debut;
  (* double circle dest *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=red]; %d;\n" fin ;
  (* double circle src *)
  fprintf ff "node [shape = circle, style=filled, fillcolor=\"#dde0ea\", color=\"#737683\"];\n" ;
  e_iter graph (fun id1 id2 lbl -> if lbl.current>0 then fprintf ff "%d -> %d [ label = \"%s\"];\n" id1 id2 (string_of_label lbl) else fprintf ff "");
  fprintf ff "}\n";
  close_out ff ;
  ()

type node = {id: int ; ptitnom: string}

let rec get_ptitnom i = function
  | [] -> "DF"
  | e :: r -> if e.id = i then e.ptitnom else get_ptitnom i r 

(* Reads a line with a project. retourne la liste projects mise a jour*)
let read_projet id graph line projects =
  try Scanf.sscanf line "p %s %d %s" (fun ptitnom nbmax _ -> (new_arc (new_node graph id) id 1 {max = nbmax ; current = 0 ; visited = false ; cost = 0 }) ,
                                                             {id = id; ptitnom = ptitnom} :: projects) (*puits id=1*)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "import projet"

(* Reads a line with an etudiant. retourne la liste etudiants mise a jour *)
let read_etudiant id gr line projects_etudiants =
  try Scanf.sscanf line "e %s %s %s" (fun initiales str_proj1 str_proj2 -> (*fait lien projet1 <- etudiant -> projet2 et etudiant et source -> etudiant*)
      let graph = new_node gr id in
      let rec search str_proj = function
        |[] -> failwith "Projet non défini"
        |proj :: r -> if proj.ptitnom = str_proj then proj.id else search str_proj r
      in new_arc (new_arc (new_arc graph 0 id {max = 1 ; current = 0 ; visited = false ; cost = 0}  (*source -> etudiant*)) id (search str_proj2 projects_etudiants) {max = 1 ; current = 0 ; visited = false ; cost = 1 }) id (search str_proj1 projects_etudiants) {max = 1 ; current = 0 ; visited = false ; cost = 0 } , 
         {id = id ; ptitnom = initiales} :: projects_etudiants)
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "import etudiant"


(* import affectations as graph*)
let import path = 
  let infile = open_in path in

  (* Read all lines until end of file. 
   * n is the current project/etudiant counter. *)
  let rec loop n graph projet_etudiant =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let (n2, graph2, pro_etud) =
        (* Ignore empty lines *)
        if line = "" then (n, graph, projet_etudiant)

        (* The first character of a line determines its content : p or e. *)
        else match line.[0] with
          | 'p' -> (match read_projet n graph line projet_etudiant with (gr, proj) -> n+1, gr, proj)
          | 'e' -> (match read_etudiant n graph line projet_etudiant with (gr, etud) -> n+1, gr, etud)

          (* It should be a comment, otherwise we complain. *)
          | _ -> (n, read_comment graph line, projet_etudiant)
      in      
      loop n2 graph2 pro_etud

    with End_of_file -> graph, projet_etudiant (* Done *)
  in

  let final_graph = loop 2 (new_node (new_node empty_graph 0) 1) [{id=0;ptitnom="S"};{id=1;ptitnom="P"}] in (*acu n fixé à 2 car puits et source sont déjà 1 et 2*)

  close_in infile ;
  final_graph


let export2_simplified path graph projets_etudiants =
  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n rankdir=LR;\n	size=\"8,5\";\n" ;
  (* double circle src *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=\"#c7cde2\", color=\"#bec4da\"]; %s;\n" "S";
  (* double circle dest *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=\"#c7cde2\", color=\"#bec4da\"]; %s;\n" "P" ;

  (* circle *)
  fprintf ff "node [shape = circle, style=filled, fillcolor=\"#dde0ea\", color=\"#737683\"];\n" ;
  e_iter graph (fun id1 id2 lbl -> if lbl.current>0 then
                   fprintf ff "%s -> %s [ label = \"%s\"];\n" (get_ptitnom id1 projets_etudiants) (get_ptitnom id2 projets_etudiants) (string_of_label lbl)
                 else  
                   fprintf ff "");

  fprintf ff "}\n";
  close_out ff ;
  ()


let export2_visible path graph projets_etudiants =
  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n rankdir=LR;\n	size=\"8,5\";\n" ;
  (* double circle src *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=\"#c7cde2\", color=\"#bec4da\"]; %s;\n" "S";
  (* double circle dest *)
  fprintf ff "node [shape = doublecircle, style=filled, fillcolor=\"#c7cde2\", color=\"#bec4da\"]; %s;\n" "P" ;

  (* circle *)
  fprintf ff "node [shape = circle, style=filled, fillcolor=\"#dde0ea\", color=\"#737683\"];\n" ;
  e_iter graph (fun id1 id2 lbl -> fprintf ff "%s -> %s [ label = \"%s\"];\n" (get_ptitnom id1 projets_etudiants) (get_ptitnom id2 projets_etudiants) (string_of_label lbl));


  fprintf ff "}\n";

  close_out ff ;
  ()

let export2_text path graph projets_etudiants =
  let ff = open_out path in
  fprintf ff "  digraph html {
abc [shape=none, margin=0, label=<
        <TABLE  CELLBORDER=\"0\" CELLSPACING=\"0\" CELLPADDING=\"4\">
            <TR BGCOLOR=\"#1B1F24\" >
                    <TD BORDER=\"1px solid #d4d4d4\"><FONT COLOR=\"#9EA2A8\">Student</FONT></TD>
                    <TD BORDER=\"1px solid #d4d4d4\"><FONT COLOR=\"#9EA2A8\">Project</FONT></TD>
            </TR>";
  e_iter graph (fun id1 id2 lbl -> if lbl.current>0 && id1 <> 0 && id1 <> 1 && id2 <> 0 && id2 <> 1 then 
                   fprintf ff ("<TR BGCOLOR=\"#EBEBEB\"><TD BORDER=\"1px solid #d4d4d4\"><FONT COLOR=\"#75778A\">%s</FONT></TD><TD BORDER=\"1px solid #d4d4d4\"><FONT COLOR=\"#75778A\"> %s </FONT></TD></TR>\n") (get_ptitnom id1 projets_etudiants) (get_ptitnom id2 projets_etudiants)
                 else  
                   fprintf ff "");
  fprintf ff "</TABLE>>]}\n";
  close_out ff ;
  ()
