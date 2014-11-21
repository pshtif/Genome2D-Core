/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables;

import msignal.Signal.Signal1;
import com.genome2d.error.GError;
import com.genome2d.textures.GTexture;
import com.genome2d.context.GCamera;
import com.genome2d.node.GNode;

/**
    Component used for rendering animations defined by set of textures
**/
class GMovieClip extends GTexturedQuad
{
	private var g2d_speed:Float = 1000/30;
	private var g2d_accumulatedTime:Float = 0;
	private var g2d_currentFrame:Int = -1;
    private var g2d_lastUpdatedFrameId:Int = 0;
    private var g2d_startIndex:Int = -1;
    private var g2d_endIndex:Int = -1;
    private var g2d_playing:Bool = true;
    private var g2d_frameTextures:Array<GTexture>;
    private var g2d_frameTexturesCount:Int;

    private var g2d_onPlaybackEnd:Signal1<GMovieClip>;
    #if swc @:extern #end
    public var onPlaybackEnd(get, never):Signal1<GMovieClip>;
    #if swc @:getter(onPlaybackEnd) #end
    private function get_onPlaybackEnd():Signal1<GMovieClip> {
        if (g2d_onPlaybackEnd == null) g2d_onPlaybackEnd = new Signal1(GMovieClip);
        return g2d_onPlaybackEnd;
    }

    /**
        Get the current frame count
    **/
    #if swc @:extern #end
    public var frameCount(get, never):Int;
    #if swc @:getter(frameCount) #end
    inline private function get_frameCount():Int {
        return g2d_frameTexturesCount;
    }

    /**
        Get the current frame index the movieclip is at
    **/
    #if swc @:extern #end
	public var currentFrame(get, never):Int;
    #if swc @:getter(currentFrame) #end
	inline private function get_currentFrame():Int {
		return g2d_currentFrame;
	}

    /**
        Texture ids used for movieclip frames
    **/
    #if swc @:extern #end
    public var frameTextureIds(never, set):Array<String>;
    #if swc @:setter(frameTextureIds) #end
	inline private function set_frameTextureIds(p_value:Array<String>):Array<String> {
        g2d_frameTextures = new Array<GTexture>();
	    g2d_frameTexturesCount = p_value.length;
        for (i in 0...g2d_frameTexturesCount) {
            var frameTexture:GTexture = GTexture.getTextureById(p_value[i]);
            if (frameTexture == null) new GError("Invalid textures id "+p_value[i]);
            g2d_frameTextures.push(frameTexture);
        }
		g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            texture = g2d_frameTextures[0];
        } else {
            texture = null;
        }

        return p_value;
	}

    /**
        Textures used for movieclip frames
    **/
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

    /**
        Is movieclip repeating after reaching the last frame, default true
    **/
	public var repeatable:Bool = true;

    /**
        Is playback reversed, default false
    **/
    public var reversed:Bool = false;

    /**
        Framerate the movieclips is playing at, default 30
    **/
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

    /**
        Number of frames in this movieclip
    **/
    #if swc @:extern #end
	public var numFrames(get, never):Int;
    #if swc @:getter(numFrames) #end
	inline private function get_numFrames():Int {
		return g2d_frameTexturesCount;
	}
	
	/**
	    Go to a specified frame of this movie clip
	**/
	public function gotoFrame(p_frame:Int):Void {
		if (g2d_frameTextures == null) return;
		g2d_currentFrame = p_frame;
		g2d_currentFrame %= g2d_frameTexturesCount;
		texture = g2d_frameTextures[g2d_currentFrame];
	}

    /**
        Go to a specified frame of this movieclip and start playing
    **/
	public function gotoAndPlay(p_frame:Int):Void {
		gotoFrame(p_frame);
		play();
	}

    /**
        Go to a specified frame of this movieclip and stop playing
    **/
	public function gotoAndStop(p_frame:Int):Void {
		gotoFrame(p_frame);
		stop();
	}
	
	/**
	    Stop playback of this movie clip
	**/
	public function stop():Void {
		g2d_playing = false;
	}
	
	/**
	    Start the playback of this movie clip
	**/
	public function play():Void {
		g2d_playing = true;
	}
	
	@:doc(hide)
	override public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		if (texture != null) {
            var dispatchEnd:Bool = false;
            var currentFrameId:Int = node.core.getCurrentFrameId();
            if (g2d_playing && currentFrameId != g2d_lastUpdatedFrameId) {
                g2d_lastUpdatedFrameId = currentFrameId;
                g2d_accumulatedTime += g2d_node.core.getCurrentFrameDeltaTime();

                if (g2d_accumulatedTime >= g2d_speed) {
                    g2d_currentFrame += (reversed) ? -Std.int(g2d_accumulatedTime / g2d_speed) : Std.int(g2d_accumulatedTime / g2d_speed);
                    if (reversed && g2d_currentFrame<0) {
                        if (repeatable) {
                            g2d_currentFrame = g2d_frameTexturesCount+g2d_currentFrame%g2d_frameTexturesCount;
                        } else {
                            g2d_currentFrame = 0;
                            g2d_playing = false;
                            dispatchEnd = true;
                        }
                    } else if (!reversed && g2d_currentFrame>=g2d_frameTexturesCount) {
                        if (repeatable) {
                            g2d_currentFrame = g2d_currentFrame%g2d_frameTexturesCount;
                        } else {
                            g2d_currentFrame = g2d_frameTexturesCount-1;
                            g2d_playing = false;
                            dispatchEnd = true;
                        }
                    }
                    texture = g2d_frameTextures[g2d_currentFrame];
                }
                g2d_accumulatedTime %= g2d_speed;
            }
            super.render(p_camera, p_useMatrix);

            if (dispatchEnd && g2d_onPlaybackEnd != null) g2d_onPlaybackEnd.dispatch(this);
        }
	}

    override public function dispose():Void {
        if (g2d_onPlaybackEnd != null) g2d_onPlaybackEnd.removeAll();
    }
}