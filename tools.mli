(** module Tools *) 
open Graph
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val clone_nodes: 'a graph -> 'b graph
val add_arcs: int graph -> id -> id -> int -> int graph
type labels = { max : int; current : int; }

val label_of_string : string -> labels
val string_of_label : labels -> string
(*val find_path :
  'a graph ->
  id ->
  id -> 'a graph -> 'a graph*)


val find_path :
  (int * int) Graph.graph ->
  Graph.id ->
  Graph.id ->
  (Graph.id * (Graph.id * (int * int)) list) list ->
  (Graph.id * (Graph.id * (int * int)) list) list