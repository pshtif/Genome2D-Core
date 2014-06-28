package com.genome2d.components.renderables.text;

import String;
import com.genome2d.textures.GCharTexture;

@:allow(com.genome2d.components.renderables.text.GTextureText)
class GChar
{
    private var g2d_code:Int;
    private var g2d_texture:GCharTexture;

    private var g2d_x:Float;
    private var g2d_y:Float;

    private var g2d_visible:Bool = false;

    public function new() {

    }

    public function toString():String {
        return String.fromCharCode(g2d_code)+":"+g2d_x+":"+g2d_y;
    }
}