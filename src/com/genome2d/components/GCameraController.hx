/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components;

import com.genome2d.callbacks.GCallback.GCallback1;
import com.genome2d.context.GViewport;
import com.genome2d.textures.GTexture;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.node.GNode;
import com.genome2d.input.GMouseInput;

/**
    Component used for adding and handling custom camera
**/
class GCameraController extends GComponent
{
    private var g2d_viewRectangle:GRectangle;
    private var g2d_capturedThisFrame:Bool = false;
    private var g2d_renderedNodesCount:Int;
	
	private var g2d_onMouseInput:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseInput(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseInput) #end
	private function get_onMouseInput():GCallback1<GMouseInput> {
		if (g2d_onMouseInput == null) g2d_onMouseInput = new GCallback1(GMouseInput);
		return g2d_onMouseInput;
	}

	/**
	    Red components of viewport background color
	**/
	public var backgroundRed:Float = 0;

	/**
	    Green components of viewport background color
	**/
	public var backgroundGreen:Float = 0;

	/**
	    Blue components of viewport background color
	**/
	public var backgroundBlue:Float = 0;

	public var backgroundAlpha:Float = 0;

    /**
        Render textures used as a target for rendering this camera

        Default `null`
	**/
    public var renderTarget:GTexture = null;

    public var viewport:GViewport;
	
	public var id:String;
	
	/**
	    Get a viewport color
	**/
	public function getBackgroundColor():Int {
		var alpha:Int = Std.int(backgroundAlpha*255)<<24;
		var red:Int = Std.int(backgroundRed*255)<<16;
		var green:Int = Std.int(backgroundGreen*255)<<8;
		var blue:Int = Std.int(backgroundBlue*255);

		return alpha+red+green+blue;
	}

    private var g2d_contextCamera:GCamera;
    #if swc @:extern #end
    public var contextCamera(get, never):GCamera;
    #if swc @:getter(contextCamera) #end
    inline private function get_contextCamera():GCamera {
        return g2d_contextCamera;
    }

    public function setView(p_normalizedX:Float, p_normalizedY:Float, p_normalizedWidth:Float, p_normalizedHeight:Float):Void {
        // TODO can't add to >1
        g2d_contextCamera.normalizedViewX = p_normalizedX;
        g2d_contextCamera.normalizedViewY = p_normalizedY;
        g2d_contextCamera.normalizedViewWidth = p_normalizedWidth;
        g2d_contextCamera.normalizedViewHeight = p_normalizedHeight;
    }

    #if swc @:extern #end
    public var zoom(get, set):Float;
    #if swc @:getter(zoom) #end
	inline private function get_zoom():Float {
		return g2d_contextCamera.scaleX;
	}
    #if swc @:setter(zoom) #end
	inline private function set_zoom(p_value:Float):Float {
		return g2d_contextCamera.scaleX = g2d_contextCamera.scaleY = p_value;
	}

	override public function init():Void {
        g2d_contextCamera = new GCamera();
        g2d_viewRectangle = new GRectangle();

		if (node != node.core.root && node.isOnStage()) node.core.g2d_addCameraController(this);
		
		node.onAddedToStage.add(g2d_onAddedToStage);
		node.onRemovedFromStage.add(g2d_onRemovedFromStage);
	}

	public function render():Void {
		if (!node.isActive()) return;
		g2d_renderedNodesCount = 0;

		g2d_contextCamera.x = node.g2d_worldX;
        g2d_contextCamera.y = node.g2d_worldY;
        g2d_contextCamera.rotation = node.g2d_worldRotation;

		node.core.getContext().setActiveCamera(g2d_contextCamera);
        node.core.getContext().setRenderTarget(renderTarget);
		node.core.root.render(false, false, g2d_contextCamera, false, false);
	}

	public function captureMouseInput(p_input:GMouseInput):Void {
		if (g2d_capturedThisFrame || !node.isActive()) return;
		g2d_capturedThisFrame = true;

        var stageRect:GRectangle = node.core.getContext().getStageViewRect();
        g2d_viewRectangle.setTo(stageRect.width*g2d_contextCamera.normalizedViewX,
                                stageRect.height*g2d_contextCamera.normalizedViewY,
                                stageRect.width*g2d_contextCamera.normalizedViewWidth,
                                stageRect.height*g2d_contextCamera.normalizedViewHeight);

		if (!g2d_viewRectangle.contains(p_input.contextX, p_input.contextY)) return;

	    var tx:Float = p_input.contextX - g2d_viewRectangle.x - g2d_viewRectangle.width/2;
        var ty:Float = p_input.contextY - g2d_viewRectangle.y - g2d_viewRectangle.height/2;

		var cos:Float = Math.cos(-node.g2d_worldRotation);
		var sin:Float = Math.sin(-node.g2d_worldRotation);
		
		var rx:Float = (tx*cos - ty*sin);
		var ry:Float = (ty*cos + tx*sin);
		
		rx /= zoom;
		ry /= zoom;
		
		p_input.worldX = rx + node.g2d_worldX;
		p_input.worldY = ry + node.g2d_worldY;
		p_input.camera = g2d_contextCamera;

		if (g2d_onMouseInput != null) g2d_onMouseInput.dispatch(p_input);
		
		node.core.root.captureMouseInput(p_input);
	}

	override public function dispose():Void {
		node.core.g2d_removeCameraController(this);
		
		node.onAddedToStage.remove(g2d_onAddedToStage);
		node.onRemovedFromStage.remove(g2d_onRemovedFromStage);

		super.dispose();
	}

	private function g2d_onAddedToStage():Void {
		node.core.g2d_addCameraController(this);
	}

	private function g2d_onRemovedFromStage():Void {
		node.core.g2d_removeCameraController(this);
	}

    public function setViewport(p_width:Int, p_height:Int, p_resize:Bool = true):Void {
		if (viewport != null) viewport.dispose();
        viewport = new GViewport(this, p_width, p_height, p_resize);
    }
}