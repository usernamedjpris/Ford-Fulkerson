let copy_node g = n_fold g new_node empty_graph;;
let add_arcs g id1 id2 lab = 
match find_arc g id1 id2 with
|None-> new_arc g id1 id2 (lab)
|Some x->new_arc g id1 id2 (lab+x)

let gmap g f = e_fold g f empty_graph