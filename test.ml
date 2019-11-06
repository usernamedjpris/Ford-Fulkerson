let rec clone_node = function
  |[]->[]
  |(id,arc) :: r -> id :: clone_node r  


let gmap gr f = 
  let rec loop1 = function
    | [] -> []
    | (node1, arcs) :: lereste -> 
        let rec loop2 = function
          | [] -> []
          | (node2,label)::r -> (node2,f label) :: loop2 r
        in (node1,loop2 arcs) :: loop1 lereste
  in loop1 gr
