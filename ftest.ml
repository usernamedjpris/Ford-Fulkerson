open Gfile
open Tools
open Graph

let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 6 then
    begin
      Printf.printf "\nUsage: %s infile source sink outfile\n\n%!" Sys.argv.(0) ;
      exit 0
    end ;

  (* Arguments are : infile(1) source-id(2) sink-id(3) outfile(4) *)

  let infile = Sys.argv.(1)
  and outfile = Sys.argv.(4)

  and _source = int_of_string Sys.argv.(2)
  and _sink = int_of_string Sys.argv.(3)
  and _export = Sys.argv.(5)
  in

  if _export = "--fromfile" then
    let graph = from_file infile in
    let gr = gmap graph label_of_string in
    let () = export outfile (gmap (ford_fulkerson2 gr 0 1) string_of_label) 0 1 in (*final_graph*)
    ()
  else
    let (gr, projets_etudiants) = import infile in  (*from_file *) 
    (*let gr = gmap graph label_of_string in *)
    let debut = _source in
    let fin = _sink in

    let final_graph = ford_fulkerson2 gr debut fin in
    if _export = "--text" then 
      let () = export2_text outfile final_graph projets_etudiants 0 1 in (*final_graph*)
      ()
    else if _export = "--easygraph" then
      let () = export2 outfile final_graph projets_etudiants 0 1 in (*final_graph*)
      ()
    else  
      let () = export2_visible outfile final_graph projets_etudiants in (*final_graph*)
      ()


(* let () = export outfile (gmap res string_of_int) in
   ()
*)
(*ajout et insertion test *)
(* let res = add_arcs (add_arcs (gmap graph int_of_string) 1 2 1000) 0 3 999 in *)
(* let res=clone_nodes graph in *)

(* Rewrite the graph that has been read. *)
(*let () = write_file outfile (gmap res string_of_int) in*)
