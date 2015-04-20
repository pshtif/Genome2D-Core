package com.genome2d.fbx;

enum FbxProp {
	PInt( v : Int );
	PFloat( v : Float );
	PString( v : String );
	PIdent( i : String );
	PInts( v : Array<Int> );
	PFloats( v : Array<Float> );
}

class GFbxTools {

	static public function get(p_node:GFbxParserNode, p_path:String, opt = false):GFbxParserNode {
		var parts:Array<String> = p_path.split(".");
		var cur:GFbxParserNode = p_node;
		for(p in parts) {
			var found:Bool = false;
			for(c in cur.childs) {
				if(c.name == p) {
					cur = c;
					found = true;
					break;
				}
            }
			if(!found) {
				if(opt) {
					return null;
                }
				throw p_node.name + " does not have " + p_path+" ("+p+" not found)";
			}
		}
		return cur;
	}

	static public function getAll(p_node:GFbxParserNode, p_path:String):Array<GFbxParserNode> {
		var parts = p_path.split(".");
		var cur = [p_node];
		for( p in parts ) {
			var out = [];
			for( n in cur ) {
				for( c in n.childs ) {
					if( c.name == p ) {
						out.push(c);
                    }
                }
            }
			cur = out;
			if( cur.length == 0 ) {
				return cur;
            }
		}
		return cur;
	}

	static public function getInts(p_node:GFbxParserNode):Array<Int> {
		if( p_node.props.length != 1 ) throw p_node.name + " has " + p_node.props + " props";

		switch(p_node.props[0]) {
            case PInts(v):
                return v;
            default:
                throw p_node.name + " has " + p_node.props + " props";
		}
	}

	static public function getFloats(p_node:GFbxParserNode):Array<Float> {
		if(p_node.props.length != 1) throw p_node.name + " has " + p_node.props + " props";

		switch(p_node.props[0]) {
            case PFloats(v):
                return v;
            case PInts(i):
                var fl = new Array<Float>();
                for( x in i )
                    fl.push(x);
                p_node.props[0] = PFloats(fl); // keep data synchronized
                // this is necessary for merging geometries since we are pushing directly into the
                // float buffer
                return fl;
            default:
                throw p_node.name + " has " + p_node.props + " props";
		}
	}

	static public function hasProp(p_node:GFbxParserNode, p_prop:FbxProp):Bool {
		for( p2 in p_node.props ) {
			if(Type.enumEq(p_prop, p2)) {
				return true;
            }
        }
		return false;
	}

	static public function toInt(p_prop:FbxProp):Int {
		if( p_prop == null ) throw "null prop";

		return switch(p_prop) {
		    case PInt(v):
                v;
		    case PFloat(f):
                Std.int(f);
		    default:
                throw "Invalid prop " + p_prop;
		}
	}

	static public function toFloat(p_prop:FbxProp):Float {
		if( p_prop == null ) throw "null prop";

		return switch(p_prop) {
		    case PInt(v):
                v * 1.0;
		    case PFloat(v):
                v;
		    default:
                throw "Invalid prop " + p_prop;
		}
	}

	static public function toString(p_prop:FbxProp):String {
		if( p_prop == null ) throw "null prop";
		return switch( p_prop ) {
		    case PString(v):
                v;
		    default:
                throw "Invalid prop " + p_prop;
		}
	}

	static public function getId(p_node:GFbxParserNode):Int {
		if( p_node.props.length != 3 ) throw p_node.name + " is not an object";

		return switch( p_node.props[0] ) {
            case PInt(id):
                id;
            case PFloat(id):
                Std.int(id);
            default:
                throw p_node.name + " is not an object " + p_node.props;
		}
	}

	static public function getName(p_node:GFbxParserNode):String {
		if( p_node.props.length != 3 ) throw p_node.name + " is not an object";

		return switch( p_node.props[1] ) {
            case PString(p_node):
                p_node.split("::").pop();
            default:
                throw p_node.name + " is not an object";
		}
	}

	static public function getType(n:GFbxParserNode):String {
		if( n.props.length != 3 ) throw n.name + " is not an object";

		return switch( n.props[2] ) {
            case PString(n):
                n;
            default:
                throw n.name + " is not an object";
		}
	}

}