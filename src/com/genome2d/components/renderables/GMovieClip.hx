/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables;

import com.genome2d.textures.GTexture;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;

class GMovieClip extends GTexturedQuad
{
	private var g2d_speed:Float = 1000/30;
	private var g2d_accumulatedTime:Float = 0;
	
	private var g2d_currentFrame:Int = -1;

    private var g2d_lastUpdatedFrameId:Int = 0;

    #if swc @:extern #end
	public var currentFrame(get, never):Int;
    #if swc @:getter(currentFrame) #end
	inline private function get_currentFrame():Int {
		return g2d_currentFrame;
	}
	
	private var g2d_startIndex:Int = -1;
	private var g2d_endIndex:Int = -1;
	private var g2d_playing:Bool = true;

    private var g2d_textureFrames:Array<GTexture>;
    private var g2d_textureFrameCount:Int;

	public function setTextureFrameIds(p_value:Array<String>):Void {
        g2d_textureFrames = new Array<GTexture>();
	    g2d_textureFrameCount = p_value.length;
        for (i in 0...g2d_textureFrameCount) {
            g2d_textureFrames.push(GTexture.getTextureById(p_value[i]));
        }
		g2d_currentFrame = 0;
		texture = g2d_textureFrames[0];
	}
	
	public var repeatable:Bool = true;
	
	static private var g2d_count:Int = 0;
	
	/**
	 * 	@private
	 */
	public function new(p_node:GNode) {
		super(p_node);
	}

    #if swc @:extern #end
	public var frameRate(get, set):Int;
    #if swc @:getter(frameRate) #end
	inline private function get_frameRate():Int {
		return Std.int(1000 / g2d_speed);
	}
	/**
	 * 	Set framerate at which this clip should play
	 */
    #if swc @:setter(frameRate) #end
	inline private function set_frameRate(p_value :Int):Int {
		g2d_speed = 1000 / p_value;
		return p_value;
	}

    #if swc @:extern #end
	public var numFrames(get, never):Int;
    #if swc @:getter(numFrames) #end
	inline private function get_numFrames():Int {
		return g2d_textureFrameCount;
	}
	
	/**
	 * 	Go to a specified frame of this movie clip
	 */
	public function gotoFrame(p_frame:Int):Void {
		if (g2d_textureFrames == null) return;
		g2d_currentFrame = p_frame;
		g2d_currentFrame %= g2d_textureFrameCount;
		texture = g2d_textureFrames[g2d_currentFrame];
	}
	
	public function gotoAndPlay(p_frame:Int):Void {
		gotoFrame(p_frame);
		play();
	}
	
	public function gotoAndStop(p_frame:Int):Void {
		gotoFrame(p_frame);
		stop();
	}
	
	/**
	 * 	Stop playback of this movie clip
	 */
	public function stop():Void {
		g2d_playing = false;
	}
	
	/**
	 * 	Start the playback of this movie clip
	 */
	public function play():Void {
		g2d_playing = true;
	}
	
	/**
	 * 	@private
	 */
	override public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (texture != null) {
            var currentFrameId:Int = node.core.getCurrentFrameId();
            if (g2d_playing && currentFrameId != g2d_lastUpdatedFrameId) {
                g2d_lastUpdatedFrameId = currentFrameId;
                g2d_accumulatedTime += g2d_node.core.getCurrentFrameDeltaTime();

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += Std.int(g2d_accumulatedTime / g2d_speed);
                    if (g2d_currentFrame<g2d_textureFrameCount || repeatable) {
                        g2d_currentFrame %= g2d_textureFrameCount;
                    } else {
                        g2d_currentFrame = g2d_textureFrameCount-1;
                    }

                    texture = g2d_textureFrames[g2d_currentFrame];
                }
                g2d_accumulatedTime %= g2d_speed;
            }

            super.render(p_camera, p_useMatrix);
        }
	}
}