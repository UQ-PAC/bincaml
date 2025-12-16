include Containers

exception
  ReplError of {
    msg : string;
    cmd : string;
    __FILE__ : string;
    __FUNCTION__ : string;
    __LINE__ : int;
  }

include Util.Common
