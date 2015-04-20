package com.genome2d.fbx;
using com.genome2d.fbx.GFbxTools;

private enum Token {
	TIdent( s : String );
	TNode( s : String );
	TInt( s : String );
	TFloat( s : String );
	TString( s : String );
	TLength( v : Int );
	TBraceOpen;
	TBraceClose;
	TColon;
	TEof;
}

class GFbxParser {

	static private var g2d_currentLine:Int;
	static private var g2d_data:String;
	static private var g2d_currentPosition:Int;
	static private var token:Null<Token>;

	static public function parse(p_data:String):GFbxParserNode {
		g2d_data = p_data;
		g2d_currentPosition = 0;
		g2d_currentLine = 1;
		token = null;
		return {
			name : "Root",
			props : [PInt(0),PString("Root"),PString("Root")],
			childs : parseNodes(),
		};
	}

	static private function parseNodes() {
		var nodes = [];
		while( true ) {
			switch( peek() ) {
                case TEof, TBraceClose:
                    return nodes;
                default:
			}
			nodes.push(parseNode());
		}
		return nodes;
	}

	static private function parseNode() : GFbxParserNode {
		var t = next();
		var name = switch( t ) {
		case TNode(n): n;
		default: unexpected(t);
		};
		var props = [], childs = null;
		while( true ) {
			t = next();
			switch( t ) {
			case TFloat(s):
				props.push(PFloat(Std.parseFloat(s)));
			case TInt(s):
				props.push(PInt(Std.parseInt(s)));
			case TString(s):
				props.push(PString(s));
			case TIdent(s):
				props.push(PIdent(s));
			case TBraceOpen, TBraceClose:
				token = t;
			case TLength(v):
				except(TBraceOpen);
				except(TNode("a"));
				var ints = [];
				var floats : Array<Float> = null;
				var i = 0;
				while( i < v ) {
					t = next();
					switch( t ) {
					case TColon:
						continue;
					case TInt(s):
						i++;
						if( floats == null )
							ints.push(Std.parseInt(s));
						else
							floats.push(Std.parseInt(s));
					case TFloat(s):
						i++;
						if( floats == null ) {
							floats = [];
							for( i in ints )
								floats.push(i);
							ints = null;
						}
						floats.push(Std.parseFloat(s));
					default:
						unexpected(t);
					}
				}
				props.push(floats == null ? PInts(ints) : PFloats(floats));
				except(TBraceClose);
				break;
			default:
				unexpected(t);
			}
			t = next();
			switch( t ) {
			case TNode(_), TBraceClose:
				token = t; // next
				break;
			case TColon:
				// next prop
			case TBraceOpen:
				childs = parseNodes();
				except(TBraceClose);
				break;
			default:
				unexpected(t);
			}
		}
		if( childs == null ) childs = [];
		return { name : name, props : props, childs : childs };
	}

	static private function except( except : Token ) {
		var t = next();
		if( !Type.enumEq(t, except) )
			error("Unexpected '" + tokenStr(t) + "' (" + tokenStr(except) + " expected)");
	}

	static private function peek() {
		if( token == null )
			token = nextToken();
		return token;
	}

	static private function next() {
		if( token == null )
			return nextToken();
		var tmp = token;
		token = null;
		return tmp;
	}

	static function error( msg : String ) : Dynamic {
		throw msg + " (line " + g2d_currentLine + ")";
		return null;
	}

	static function unexpected( t : Token ) : Dynamic {
		return error("Unexpected "+tokenStr(t));
	}

	static function tokenStr( t : Token ) {
		return switch( t ) {
            case TEof: "<eof>";
            case TBraceOpen: '{';
            case TBraceClose: '}';
            case TIdent(i): i;
            case TNode(i): i+":";
            case TFloat(f): f;
            case TInt(i): i;
            case TString(s): '"' + s + '"';
            case TColon: ',';
            case TLength(l): '*' + l;
		};
	}

	inline static private function nextChar():Int {
		return StringTools.fastCodeAt(g2d_data, g2d_currentPosition++);
	}

	inline static private function isIdentChar(c:Int):Bool {
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == '_'.code || c == '-'.code;
	}

	static private function nextToken() {
		var startPosition:Int = g2d_currentPosition;
		while(true) {
			var c:Int = nextChar();
			switch(c) {
                // Empty space
                case ' '.code, '\r'.code, '\t'.code:
                    startPosition++;
                // End line
                case '\n'.code:
                    g2d_currentLine++;
                    startPosition++;
                // Comment
                case ';'.code:
                    while(true) {
                        var c:Int = nextChar();
                        if(StringTools.isEof(c) || c == '\n'.code) {
                            g2d_currentPosition--;
                            break;
                        }
                    }
                    startPosition = g2d_currentPosition;
                case ','.code:
                    return TColon;
                case '{'.code:
                    return TBraceOpen;
                case '}'.code:
                    return TBraceClose;
                case '"'.code:
                    startPosition = g2d_currentPosition;
                    while(true) {
                        c = nextChar();
                        if(c == '"'.code)
                            break;
                        if(StringTools.isEof(c) || c == '\n'.code)
                            error("Unclosed string");
                    }
                    return TString(g2d_data.substr(startPosition, g2d_currentPosition - startPosition - 1));
                // Length
                case '*'.code:
                    startPosition = g2d_currentPosition;
                    do {
                        c = nextChar();
                    } while( c >= '0'.code && c <= '9'.code );
                    g2d_currentPosition--;
                    return TLength(Std.parseInt(g2d_data.substr(startPosition, g2d_currentPosition - startPosition)));
                default:
                    if( (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || c == '_'.code ) {
                        do {
                            c = nextChar();
                        } while(isIdentChar(c));
                        if( c == ':'.code ) {
                            return TNode(g2d_data.substr(startPosition, g2d_currentPosition - startPosition - 1));
                        }
                        g2d_currentPosition--;
                        return TIdent(g2d_data.substr(startPosition, g2d_currentPosition - startPosition));
                    }
                    if( (c >= '0'.code && c <= '9'.code) || c == '-'.code ) {
                        do {
                            c = nextChar();
                        } while( c >= '0'.code && c <= '9'.code );
                        if( c != '.'.code && c != 'E'.code && c != 'e'.code && g2d_currentPosition - startPosition < 10 ) {
                            g2d_currentPosition--;
                            return TInt(g2d_data.substr(startPosition, g2d_currentPosition - startPosition));
                        }
                        if( c == '.'.code ) {
                            do {
                                c = nextChar();
                            } while( c >= '0'.code && c <= '9'.code );
                        }
                        if( c == 'e'.code || c == 'E'.code ) {
                            c = nextChar();
                            if( c != '-'.code && c != '+'.code )
                                g2d_currentPosition--;
                            do {
                                c = nextChar();
                            } while( c >= '0'.code && c <= '9'.code );
                        }
                        g2d_currentPosition--;
                        return TFloat(g2d_data.substr(startPosition, g2d_currentPosition - startPosition));
                    }
                    if( StringTools.isEof(c) ) {
                        g2d_currentPosition--;
                        return TEof;
                    }
                    error("Unexpected char '" + String.fromCharCode(c) + "'");
			}
		}
	}
}