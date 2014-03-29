package com.genome2d.utils;

#if flash
class FastIter<T> {
	var values:Array<Dynamic>;
	var curent:Int = 0;
	var len:Int;
	
	public function new(obj:Dynamic) {
		values = new Array<Dynamic>();
		var t = 0;
		untyped {
			while ( __has_next__(obj, t)) {
				values.push(obj[__forin__(obj,t)]);
			}
		}
		len = values.length;
	}
	
	public inline function hasNext():Bool {
		return curent < len;
	}
	
	public inline function next():T {
		return values[curent++];
	}
}

abstract GMap<K,V>(flash.utils.Dictionary) {

	public inline function new(weakKeys : Bool = false) 
	{
		this = new flash.utils.Dictionary(weakKeys);
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

	public inline function remove( key : K ) : Bool {
		if( !exists(key) ) return false;
		untyped __delete__(this, key);
		return true;
	}

 	public inline function iterator() : Iterator<V> {
		return new FastIter<V>(this);
 	}
	
	public function toString() : String {
		var s = "";		
		var t = 0;
		var i:K;
		while ( untyped __has_next__(this, t)) untyped {
			i = __forin__(this, t);
			s += (s == "" ? "" : ",") + Std.string(i) + " => " + Std.string(this[i]);
		}
		return '{$s}';
	}
}
#else
typedef GMap<K,V> = Map<K,V>;
#end