open Graph

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

val not_visited_node : labels Graph.graph -> int -> bool
val max_flow : int -> ('a * ('b * labels)) list -> int  

val max_flow_min_cost :
  labels Graph.graph ->
  int -> int -> labels Graph.graph

val max_flow_min_cost_verbose :
  labels Graph.graph ->
  int -> int -> labels Graph.graph
