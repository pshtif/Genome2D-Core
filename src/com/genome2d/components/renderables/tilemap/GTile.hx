package com.genome2d.components.renderables.tilemap;

import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;
import com.genome2d.error.GError;

@:allow(com.genome2d.components.renderables.tilemap.GTileMap)
class GTile
{
    /**
        Texture id used by this sprite
    **/
    #if swc @:extern #end
    @prototype public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        return (texture != null) ? texture.getId() : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTexture.getTextureById(p_value);
        if (texture == null) new GError("Invalid texture with id "+p_value);
        return p_value;
    }

    public var texture:GTexture;
    public var value:Int = 0;
    public var rotation:Float = 0;
    public var alpha:Float = 1;

    public var repeatable:Bool = true;

    public var mapX:Int = 0;
    public var mapY:Int = 0;
    public var rows:Int = 1;
    public var cols:Int = 1;

    private var g2d_lastFrameRendered:Int = 0;
    private var g2d_lastTimeRendered:Float = 0;
    private var g2d_playing:Bool = true;
    private var g2d_speed:Float = 1000/5;

    private var g2d_accumulatedTime:Float = 0;

    private var g2d_currentFrame:Int = 0;
    private var g2d_frameTexturesCount:Int = 0;
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

        return g2d_frameTextures;
    }

    public function new(p_rows:Int = 1, p_cols:Int = 1, p_mapX:Int = -1, p_mapY:Int = -1) {
        if ((p_rows != 1 || p_cols != 1) && (p_mapX == -1 || p_mapY == -1)) new GError("Invalid tile definition.");

        rows = p_rows;
        cols = p_cols;
        mapX = p_mapX;
        mapY = p_mapY;
    }

    inline public function render(p_context:IContext, p_x:Float, p_y:Float, p_frameId:Int, p_time:Float, p_blendMode:Int):Void {
        if (texture != null) {
            if (g2d_playing && p_frameId != g2d_lastFrameRendered) {
                g2d_lastFrameRendered = p_frameId;
                g2d_accumulatedTime += p_time - g2d_lastTimeRendered;

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += Std.int(g2d_accumulatedTime / g2d_speed);
                    if (g2d_currentFrame<g2d_frameTexturesCount || repeatable) {
                        g2d_currentFrame %= g2d_frameTexturesCount;
                    } else {
                        g2d_currentFrame = g2d_frameTexturesCount-1;
                    }
                    texture = g2d_frameTextures[g2d_currentFrame];
                }
                g2d_accumulatedTime %= g2d_speed;
            }

            p_context.draw(texture, p_x, p_y, 1, 1, rotation, 1, 1, 1, alpha, p_blendMode);
            g2d_lastTimeRendered = p_time;
        }
    }
}