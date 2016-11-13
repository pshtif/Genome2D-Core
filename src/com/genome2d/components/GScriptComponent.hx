package com.genome2d.components;
import com.genome2d.scripts.GScript;
class GScriptComponent extends GComponent {
    private var g2d_script:GScript = null;
    @prototype("getReference")
    public var script(get,set):GScript;
    #if swc @:getter(script) #end
    inline private function get_script():GScript {
        return g2d_script;
    }
        #if swc @:setter(script) #end
    inline private function set_script(p_value:GScript):GScript {
        if (g2d_script != null) {
            g2d_script.onInvalidated.remove(invalidate);
            if (g2d_executeDispose != null) g2d_executeDispose();
        }
        g2d_script = p_value;
        g2d_script.onInvalidated.add(invalidate);
        invalidate();
        return g2d_script;
    }

    private var g2d_executeRender:Dynamic;
    private var g2d_executeInit:Dynamic;
    private var g2d_executeDispose:Void->Void;

    override public function dispose():Void {
        if (g2d_executeDispose != null) g2d_executeDispose();
    }

    private function invalidate():Void {
        if (g2d_script != null) {
            g2d_executeInit = g2d_script.getVariable("spawn");
            g2d_executeDispose = g2d_script.getVariable("update");
            g2d_executeRender = g2d_script.getVariable("render");
        }

        if (g2d_executeInit != null) g2d_executeInit();
    }
}
