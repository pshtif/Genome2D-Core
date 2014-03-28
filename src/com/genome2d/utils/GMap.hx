package com.genome2d.utils;

#if flash
abstract GMap<K,V>(flash.utils.Dictionary) {

	public inline function new() 
	{
		this = new flash.utils.Dictionary();
	}
	
	@:arrayAccess public inline function get(key : K) : V {
		return untyped this[key];
	}

	@:arrayAccess public inline function set(key : K, val : V) : V {
		return untyped this[key] = val;
	}
	
	public inline function keys() : Iterator<K> {
		return untyped __keys__(this).iterator();
 	}
	
	public inline function exists( key : K ) : Bool {
		return untyped __in__(key,this);
	}

	public function remove( key : K ) : Bool {
		if( !exists(key) ) return false;
		untyped __delete__(this, key);
		return true;
	}

 	public function iterator() : Iterator<V> {
		var ret = [];
		for (i in keys())
			ret.push(get(i));
		return ret.iterator();
 	}
	
	public function toString() : String {
		var s = "";
		var it = keys();
		for( i in it ) {
			s += (s == "" ? "" : ",") + Std.string(i);
			s += " => ";
			s += Std.string(get(i));
		}
		return '{$s}';
	}
}
#else
typedef GMap<K,V> = Map<K,V>;
#end