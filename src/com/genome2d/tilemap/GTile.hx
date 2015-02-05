package com.genome2d.tilemap;

import com.genome2d.textures.GTextureManager;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;
import com.genome2d.debug.GDebug;

@:allow(com.genome2d.components.renderables.tilemap.GTileMap)
class GTile
{
    public var texture:GTexture;#if swc @:extern #end
    @prototype public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    private function get_textureId():String {
        return (texture != null) ? texture.id : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTextureManager.getTextureById(p_value);
        if (texture == null) GDebug.error("Invalid textures with id "+p_value);
        return p_value;
    }

    public var value:Int = 0;
    public var rotation:Float = 0;
    public var alpha:Float = 1;
    public var visible:Bool = true;
    public var repeatable:Bool = true;
    public var reversed:Bool = false;

    public var red:Float = 1;
    public var green:Float = 1;
    public var blue:Float = 1;

    /**
	    Abstract reference to user defined data, if you want keep some custom data binded to GTile instance use it.
	**/
    private var g2d_userData:Map<String, Dynamic>;
    #if swc @:extern #end
    public var userData(get, never):Map<String, Dynamic>;
    #if swc @:getter(userData) #end
    inline private function get_userData():Map<String, Dynamic> {
        if (g2d_userData == null) g2d_userData = new Map<String,Dynamic>();
        return g2d_userData;
    }

    public var mapX:Int = 0;
    public var mapY:Int = 0;
    public var sizeX:Int = 1;
    public var sizeY:Int = 1;

    private var g2d_lastFrameRendered:Int = 0;
    #if swc @:extern #end
    public var lastFrameRendered(get, never):Int;
    #if swc @:getter(lastFrameRendered) #end
    inline private function get_lastFrameRendered():Int {
        return g2d_lastFrameRendered;
    }

    private var g2d_lastTimeRendered:Float = 0;
    private var g2d_playing:Bool = false;
    private var g2d_speed:Float = 1000/5;

    private var g2d_accumulatedTime:Float = 0;

    private var g2d_currentFrame:Int = 0;
    #if swc @:extern #end
    public var currentFrame(get, never):Int;
    #if swc @:getter(currentFrame) #end
    inline private function get_currentFrame():Int {
        return g2d_currentFrame;
    }

    private var g2d_frameTexturesCount:Int = 0;
    #if swc @:extern #end
    public var frameCount(get, never):Int;
    #if swc @:getter(frameCount) #end
    inline private function get_frameCount():Int {
        return g2d_frameTexturesCount;
    }

    private var g2d_frameTextures:Array<GTexture>;
    #if swc @:extern #end
    public var frameTextures(never, set):Array<GTexture>;
    #if swc @:setter(frameTextures) #end
    inline private function set_frameTextures(p_value:Array<GTexture>):Array<GTexture> {
        g2d_frameTextures = p_value;
        g2d_frameTexturesCount = p_value.length;
        g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            texture = g2d_frameTextures[0];
        } else {
            texture = null;
        }
        if (g2d_frameTextures.length>1) g2d_playing = true;
        return g2d_frameTextures;
    }

    #if swc @:extern #end
    public var frameTextureIds(never, set):Array<String>;
    #if swc @:setter(frameTextureIds) #end
    inline private function set_frameTextureIds(p_value:Array<String>):Array<String> {
        g2d_frameTextures = new Array<GTexture>();
        g2d_frameTexturesCount = p_value.length;
        for (i in 0...g2d_frameTexturesCount) {
            var frameTexture:GTexture = GTextureManager.getTextureById(p_value[i]);
            if (frameTexture == null) GDebug.error("Invalid texture id "+p_value[i]);
            g2d_frameTextures.push(frameTexture);
        }
        g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            texture = g2d_frameTextures[0];
        } else {
            texture = null;
        }
        if (g2d_frameTexturesCount>1) g2d_playing = true;
        return p_value;
    }

    #if swc @:extern #end
    public var frameRate(get, set):Int;
    #if swc @:getter(frameRate) #end
    inline private function get_frameRate():Int {
        return Std.int(1000 / g2d_speed);
    }
    #if swc @:setter(frameRate) #end
    inline private function set_frameRate(p_value :Int):Int {
        g2d_speed = 1000 / p_value;
        return p_value;
    }

    public function new(p_sizeX:Int = 1, p_sizeY:Int = 1, p_mapX:Int = -1, p_mapY:Int = -1) {
        if ((p_sizeX != 1 || p_sizeY != 1) && (p_mapX == -1 || p_mapY == -1)) GDebug.error("Invalid tile definition.");

        sizeX = p_sizeX;
        sizeY = p_sizeY;
        mapX = p_mapX;
        mapY = p_mapY;
    }

    public function stop():Void {
        g2d_playing = false;
    }

    public function play():Void {
        g2d_playing = true;
    }

    public function gotoFrame(p_frame:Int):Void {
        if (g2d_frameTextures == null) return;
        g2d_currentFrame = p_frame;
        g2d_currentFrame %= g2d_frameTexturesCount;
        texture = g2d_frameTextures[g2d_currentFrame];
    }

    public function gotoAndPlayFrame(p_frame:Int):Void {
        gotoFrame(p_frame);
        g2d_playing = true;
    }

    public function gotoAndStopFrame(p_frame:Int):Void {
        gotoFrame(p_frame);
        g2d_playing = false;
    }

    inline public function render(p_context:IContext, p_x:Float, p_y:Float, p_frameId:Int, p_time:Float, p_blendMode:Int):Void {
        if (texture != null && visible) {
            if (g2d_playing && g2d_frameTextures != null && p_frameId != g2d_lastFrameRendered) {
                g2d_accumulatedTime += p_time - g2d_lastTimeRendered;

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += (reversed) ? -Std.int(g2d_accumulatedTime / g2d_speed) : Std.int(g2d_accumulatedTime / g2d_speed);
                    if (reversed && g2d_currentFrame<0) {
                        g2d_currentFrame = (repeatable) ? (g2d_frameTexturesCount+g2d_currentFrame%g2d_frameTexturesCount)%g2d_frameTexturesCount : 0;
                    } else if (!reversed && g2d_currentFrame>=g2d_frameTexturesCount) {
                        g2d_currentFrame = (repeatable) ? g2d_currentFrame%g2d_frameTexturesCount : g2d_frameTexturesCount-1;
                    }
                    texture = g2d_frameTextures[g2d_currentFrame];
                }
                g2d_accumulatedTime %= g2d_speed;
            }
            p_context.draw(texture, p_x, p_y, 1, 1, rotation, red, green, blue, alpha, p_blendMode);
            g2d_lastTimeRendered = p_time;
            g2d_lastFrameRendered = p_frameId;
        }
    }
}