let rec clone_node = function
  | [] -> []
  | (src, arc) :: r -> src :: clone_node r  

let gmap gr f = 
    let rec loop1 = function
        | [] -> []
        | (src, arcs) :: lereste -> 
            let rec loop2 = function
               | [] -> []
               | (dest, label) :: r -> (dest, f label) :: loop2 r 
        in (src, loop2 arcs) :: loop1 lereste
    in loop1 gr ;;

let add_arc g id1 id2 n =
  let rec loop1 gr accug =
    match gr with
      | []-> raise Not_found
      | (src, arc) :: r -> if src = id1 then 
            let rec loop2 arcs accu =
              match arcs with 
                | [] -> accug@((src, (id2, n) :: accu) :: r) (* @ concatene 2 listes *) 
                | (dest, lab) :: reste-> if dest = id2 then (accug@((src, accu@((id2, n) :: reste)) :: r)) else loop2 reste ((dest, lab) :: accu)
            in loop2 arc []
          else
            loop1 r ((src, arc) :: accug)
  in loop1 g [];;

let print_ gr f =
    let rec loop1 = function 
    | [] -> "\n"
    | (src, arcs) :: lereste -> 
            let rec loop2 = function
               | [] -> "\n"
               | (dest, label) :: r -> "    --" ^ f label ^ "-> • " ^ string_of_int dest ^ "\n" ^ loop2 r 
        in string_of_int src ^ " • \n" ^ loop2 arcs ^ loop1 lereste
    in Printf.printf ("%s%!") (loop1 gr) ;; 

let graph = [ ( 1 , [ ( 2, 12 ) ;
                      ( 3, 3 ) ;
                      ( 4, 45 ) ;
                      ( 5, 456 ) ] ) ;
              ( 2 , [ ( 1, 1 ) ;
                      ( 3, 1 ) ;
                      ( 4, 12 ) ;
                      ( 5, 24 ) ] ) ;
              ( 3 , [ ( 1, 12 ) ;
                      ( 2, 0 ) ;
                      ( 4, 0 ) ;
                      ( 5, 0 ) ] ) ;
              ( 4 , [] ) ;                          
              ( 5 , [ ( 2, 1 ) ;
                      ( 3, 4 ) ;
                      ( 1, 4657 ) ] ) ];;
                      
        
print_ graph string_of_int;;
Printf.printf ("       ***     \n%!"); Printf.printf ("\n%!");;
print_ (gmap graph (fun x -> x*2)) string_of_int;;
Printf.printf ("       ***    \n%!"); Printf.printf ("\n%!");;
print_ (add_arc graph 4 5 123) string_of_int;;
