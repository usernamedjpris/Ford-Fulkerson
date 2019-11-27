(** module Tools *) 
open Graph
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val clone_nodes: 'a graph -> 'b graph
val add_arcs: int graph -> id -> id -> int -> int graph

type labels = { max : int; current : int; visited: bool ; cost: int}
type parents = { origin : int ; arc : labels}

val init_list : 'a Graph.graph -> Graph.id -> (int * int * parents * bool) list
val maj_node_list :
  ('a * 'b * 'c * 'd) list ->
  'a -> 'b -> 'c -> 'd -> ('a * 'b * 'c * 'd) list

val maj_list_mark :('a * 'b * 'c * bool) list -> 'a -> ('a * 'b * 'c * bool) list 

val select_node : (int * int * parents * bool) list -> int 
val get_current_cost : ('a * 'b * 'c * 'd) list -> 'a -> 'b
val reconstitution :
  (int * 'a * parents * 'b) list -> int -> (int * (int * labels)) list
val find_path :
  labels Graph.graph ->
  Graph.id -> Graph.id -> (int * (Graph.id * labels)) list
val max_flow_min_cost :
  labels Graph.graph ->
  int -> int -> labels Graph.graph


val label_of_string : string -> labels
val string_of_label : labels -> string

val not_visited_node : labels Graph.graph -> int -> bool
val max_flow : int -> ('a * ('b * labels)) list -> int
  
val find_path_ford :
  labels Graph.graph ->
  Graph.id -> Graph.id ->
  (Graph.id * (Graph.id * labels)) list -> (Graph.id * (Graph.id * labels)) list
 
val ford_fulkerson2 :
  labels Graph.graph ->
  Graph.id -> Graph.id ->
  labels Graph.graph
  