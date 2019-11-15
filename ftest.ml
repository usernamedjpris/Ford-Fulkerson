open Gfile
open Tools
open Graph
let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 5 then
    begin
      Printf.printf "\nUsage: %s infile source sink outfile\n\n%!" Sys.argv.(0) ;
      exit 0
    end ;


  (* Arguments are : infile(1) source-id(2) sink-id(3) outfile(4) *)

  let infile = Sys.argv.(1)
  and outfile = Sys.argv.(4)

  (* These command-line arguments are not used for the moment. *)
  (* and _source = int_of_string Sys.argv.(2)
     and _sink = int_of_string Sys.argv.(3)*)
  in

  (* Open file *)
  let graph = from_file infile in

  (*ajout et insertion test *)
  (* let res = add_arcs (add_arcs (gmap graph int_of_string) 1 2 1000) 0 3 999 in *)
  (* let res=clone_nodes graph in *)

  (* Rewrite the graph that has been read. *)
  (*let () = write_file outfile (gmap res string_of_int) in*)


  let path = find_path (gmap graph label_of_string) 0 5 [] in
  ()
(*let () = export outfile (gmap path string_of_label) in
  ()*)
(* let () = export outfile (gmap res string_of_int) in
   ()
*)
