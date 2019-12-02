(** module Tools *) 
open Graph
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val clone_nodes: 'a graph -> 'b graph
val add_arcs: int graph -> id -> id -> int -> int graph

type labels = { max : int; current : int; visited: bool ; cost: int}
type parents = { origin : int ; arc : labels}

val empty_parent: parents

val label_of_string : string -> labels
val string_of_label : labels -> string
