let x = 2

type 'a state = {
  unionfind_state : 'a UnionFind.StoreVector.store;
  hashcons_state : (module Fix.HashCons.SERVICE with type data = 'a);
}
