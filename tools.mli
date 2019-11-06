(** module Tools *) 
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val clone_nodes: 'a graph -> 'b graph
val add_arc: int graph -> id -> id -> int -> int graph
