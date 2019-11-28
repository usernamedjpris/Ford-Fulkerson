open Gfile
open Tools
open Graph

let () =
  if Array.length Sys.argv <> 8 then
    begin
      Printf.printf "\nUsage: %s infile src dest outfile --option_import --option_algo --option_export\n\n%!" Sys.argv.(0) ;
      exit 0
    end ;

  let infile  = Sys.argv.(1)
  and outfile = Sys.argv.(4)
  and _source = int_of_string Sys.argv.(2)
  and _sink   = int_of_string Sys.argv.(3)
  and _import = Sys.argv.(5)
  and _algo   = Sys.argv.(6)
  and _export = Sys.argv.(7)
  in
  if _import = "--fromGfile" then 
    let graph = from_file infile in
    let gr = gmap graph label_of_string in
    if  _algo = "fordF" then
      let final_graph = ford_fulkerson2 gr 0 1 in
      if _export = "--easygraph" then
        let () = export outfile (gmap final_graph string_of_label) 0 1 in ()
      else  if _export = "--visible"
        let () = export_visible outfile (gmap final_graph string_of_label) 0 1 in ()
    else if _algo = "minFmaxC" then
      let final_graph = max_flow_min_cost gr 0 1 in
      if _export = "--easygraph" then
        let () = export outfile (gmap final_graph string_of_label) 0 1 in ()
      else  if _export = "--visible"
        let () = export_visible outfile (gmap final_graph string_of_label) 0 1 in ()
  else
  if _import = "fromaffect" then 
    let (gr, projets_etudiants) = import infile in  
    if  _algo = "fordF" then
      let final_graph = ford_fulkerson2 gr 0 1 in
      if _export = "--text" then 
        let () = export2_text outfile final_graph projets_etudiants 0 1 in ()
      else if _export = "--easygraph" then
        let () = export2 outfile final_graph projets_etudiants 0 1 in ()
      else  if _export = "--visible"
        let () = export2_visible outfile final_graph projets_etudiants in ()
    else if _algo = "minFmaxC" then
      let final_graph = max_flow_min_cost gr 0 1 in
      if _export = "--text" then 
        let () = export2_text outfile final_graph projets_etudiants 0 1 in ()
      else if _export = "--easygraph" then
        let () = export2 outfile final_graph projets_etudiants 0 1 in ()
      else  if _export = "--visible"
        let () = export2_visible outfile final_graph projets_etudiants in ()
