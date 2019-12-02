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
  and _source = int_of_string Sys.argv.(2)
  and _sink   = int_of_string Sys.argv.(3)
  and outfile = Sys.argv.(4)
  and _import = Sys.argv.(5)
  and _algo   = Sys.argv.(6)
  and _export = Sys.argv.(7)
  in
  match _import with
    |"--fromGfile" -> (
    let graph = from_file infile in
    let gr = gmap graph label_of_string in
    match _algo with
      | "--fordF" -> (
        let final_graph = ford_fulkerson2 gr _source _sink in
        match _export with
          | "--easygraph" -> let () = export_simplified outfile final_graph _source _sink in ()
          | "--visible" ->   let () = export_visible outfile (gmap final_graph string_of_label) _source _sink in ()
          |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())    
      | "--fordFverbose" -> (
          let final_graph = ford_fulkerson2_verbose gr _source _sink in
          match _export with
          | "--easygraph" -> let () = export_simplified outfile final_graph _source _sink in ()
          | "--visible" ->   let () = export_visible outfile (gmap final_graph string_of_label) _source _sink in ()
          |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())
      |"--maxFminC" -> (
        let final_graph = max_flow_min_cost gr _source _sink in
            match _export with
            |"--easygraph" -> let () = export_simplified outfile final_graph _source _sink in ()
            |"--visible"  ->  let () = export_visible outfile (gmap final_graph string_of_label) _source _sink in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())
          
      |"--maxFminCverbose" -> (
        let final_graph = max_flow_min_cost_verbose gr _source _sink in
          match _export with
            |"--easygraph" -> let () = export_simplified outfile final_graph _source _sink in ()
            |"--visible" ->   let () = export_visible outfile (gmap final_graph string_of_label) _source _sink in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())
      |_ -> let () = Printf.printf "_algo wrong %s\n%!" _algo in ())
    | "--fromaffect" -> (
      let (gr, projets_etudiants) = import infile in 
      match _algo with
        |"--fordF" -> (
          let final_graph = ford_fulkerson2 gr 0 1 in
          match _export with
            | "--text" -> let () = export2_text outfile final_graph projets_etudiants in ()
            | "--easygraph" -> let () = export2_simplified outfile final_graph projets_etudiants in ()
            | "--visible" -> let () = export2_visible outfile final_graph projets_etudiants in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())            
        |"--fordFverbose" -> (
          let final_graph = ford_fulkerson2_verbose gr 0 1 in
          match _export with
            | "--text" -> let () = export2_text outfile final_graph projets_etudiants in ()
            | "--easygraph" -> let () = export2_simplified outfile final_graph projets_etudiants in ()
            | "--visible" -> let () = export2_visible outfile final_graph projets_etudiants in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())  
                
        |"--maxFminC" -> (
          let final_graph = max_flow_min_cost gr 0 1 in
          match _export with
            | "--text" -> let () = export2_text outfile final_graph projets_etudiants in ()
            | "--easygraph" -> let () = export2_simplified outfile final_graph projets_etudiants in ()
            | "--visible" -> let () = export2_visible outfile final_graph projets_etudiants in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())  
        |"--maxFminCverbose" -> (
          let final_graph = max_flow_min_cost_verbose gr 0 1 in
          match _export with
            | "--text" -> let () = export2_text outfile final_graph projets_etudiants in ()
            | "--easygraph" -> let () = export2_simplified outfile final_graph projets_etudiants in ()
            | "--visible" -> let () = export2_visible outfile final_graph projets_etudiants in ()
            |_ -> let () = Printf.printf "export wrong %s\n%!" _export in ())  
        |_ -> let () = Printf.printf "_algo wrong %s\n%!" _algo in ())
      |_-> let () = Printf.printf "_import wrong %s\n%!" _import in ()
