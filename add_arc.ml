let add_arc g id1 id2 n=
  let rec loop1 gr accug=
    match gr with
      |[]-> raise Not_found
      |(id,arc)::r-> if id = id1 then 
            let rec loop2 arcs accu =
              match arcs with 
                |[]->accug@((id,(id2,n)::accu)::r) (* @ concatene 2 listes *) 
                |(ele,lab)::reste-> if ele = id2 then (accug@((id,accu@((id2,n)::reste))::r)) else loop2 reste ((ele,lab)::accu)
            in loop2 arc []
          else
            loop1 r ((id,arc)::accug)
  in loop1 g [];;

