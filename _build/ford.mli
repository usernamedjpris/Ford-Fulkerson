open Graph
open Tools

val max_flow : int -> ('a * ('b * labels)) list -> int
val not_visited_node : labels Graph.graph -> int -> bool
val print_path : (int * (int * labels)) list -> unit
val update_residu : labels Graph.graph -> (int * (int * labels)) list-> int -> labels Graph.graph
val update_graphe_initial: labels Graph.graph ->labels Graph.graph ->labels Graph.graph
val make_ecart: labels Graph.graph ->labels Graph.graph

val find_path_ford :
  labels Graph.graph ->
  Graph.id -> Graph.id ->
  (Graph.id * (Graph.id * labels)) list -> (Graph.id * (Graph.id * labels)) list
 
val ford_fulkerson2 :
  labels Graph.graph ->
  Graph.id -> Graph.id ->
  labels Graph.graph

val ford_fulkerson2_verbose :
  labels Graph.graph ->
  Graph.id -> Graph.id ->
  labels Graph.graph
