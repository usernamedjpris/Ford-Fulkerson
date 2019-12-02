open Graph
open Tools

val max_flow : int -> ('a * ('b * labels)) list -> int
  
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
