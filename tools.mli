(** module Tools *) 
open Graph
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val clone_nodes: 'a graph -> 'b graph
val add_arcs: int graph -> id -> id -> int -> int graph
type labels = { max : int; current : int; }
val empty: labels empty_graph
val label_of_string : string -> labels
val string_of_label : labels -> string
val find_path :
  labels graph ->
  int ->
  int -> labels graph -> labels graph