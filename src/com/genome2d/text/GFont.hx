package com.genome2d.text;
import com.genome2d.proto.IGPrototypable;

@:access(com.genome2d.text.GFontManager)
class GFont implements IGPrototypable {
    private var g2d_id:String;
    /**
	 * 	Id
	 */
    @prototype
    #if swc @:extern #end
    public var id(get,set):String;
    #if swc @:getter(id) #end
    inline private function get_id():String {
        return g2d_id;
    }
    #if swc @:setter(id) #end
    inline private function set_id(p_value:String):String {
        if (p_value != g2d_id) {
            GFontManager.g2d_removeFont(cast this);
            g2d_id = p_value;
            GFontManager.g2d_addFont(cast this);
        }
        return g2d_id;
    }

    /*
	 *	Get a reference value
	 */
    public function toReference():String {
        return "@"+id;
    }
}
