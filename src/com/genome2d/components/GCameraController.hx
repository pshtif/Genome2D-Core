/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components;

import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;

class GCameraController extends GComponent
{
	/**
	 * 	Red component of viewport background color
	 */
	public var backgroundRed:Float = 0;
	/**
	 * 	Green component of viewport background color
	 */
	public var backgroundGreen:Float = 0;
	/**
	 * 	Blue component of viewport background color
	 */
	public var backgroundBlue:Float = 0;
	/**
	 * 	@private
	 */
	public var backgroundAlpha:Float = 0;
	
	/**
	 * 	Get a viewport color
	 */
	public function getBackgroundColor():Int {
		var alpha:Int = Std.int(backgroundAlpha*255)<<24;
		var red:Int = Std.int(backgroundRed*255)<<16;
		var green:Int = Std.int(backgroundGreen*255)<<8;
		var blue:Int = Std.int(backgroundBlue*255);

		return alpha+red+green+blue;
	}

    private var g2d_viewRectangle:GRectangle;

	/**
	 * 	@private
	 */	
	public var g2d_capturedThisFrame:Bool = false;
	
	public var g2d_renderedNodesCount:Int;

    private var g2d_contextCamera:GContextCamera;
    #if swc @:extern #end
    public var contextCamera(get, never):GContextCamera;
    #if swc @:getter(contextCamera) #end
    inline private function get_contextCamera():GContextCamera {
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
	
	/**
	 * 	@private
	 */
	public function new(p_node:GNode) {
		super(p_node);

        g2d_contextCamera = new GContextCamera();
        g2d_viewRectangle = new GRectangle();

		if (node != node.core.root && node.isOnStage()) node.core.g2d_addCameraController(this);
		
		node.onAddedToStage.add(onAddedToStage);
		node.onRemovedFromStage.add(onRemovedFromStage);
	}
	
	/**
	 * 	@private
	 */
	public function render():Void {
		if (!node.isActive()) return;
		g2d_renderedNodesCount = 0;

		g2d_contextCamera.x = node.transform.g2d_worldX;
        g2d_contextCamera.y = node.transform.g2d_worldY;
        g2d_contextCamera.rotation = node.transform.g2d_worldRotation;

		node.core.getContext().setCamera(g2d_contextCamera);
		node.core.root.render(false, false, g2d_contextCamera, false, false);
	}
	
	/**
	 * 	@private
	 */
	public function captureMouseEvent(p_context:IContext, p_captured:Bool, p_signal:GMouseSignal):Bool {
		if (g2d_capturedThisFrame || !node.isActive()) return false;
		g2d_capturedThisFrame = true;

        var stageRect:GRectangle = p_context.getStageViewRect();
        g2d_viewRectangle.setTo(stageRect.width*g2d_contextCamera.normalizedViewX,
                                stageRect.height*g2d_contextCamera.normalizedViewY,
                                stageRect.width*g2d_contextCamera.normalizedViewWidth,
                                stageRect.height*g2d_contextCamera.normalizedViewHeight);

		if (!g2d_viewRectangle.contains(p_signal.x, p_signal.y)) return false;

	    var tx:Float = p_signal.x - g2d_viewRectangle.x - g2d_viewRectangle.width/2;
        var ty:Float = p_signal.y - g2d_viewRectangle.y - g2d_viewRectangle.height/2;

		var cos:Float = Math.cos(-node.transform.g2d_worldRotation);
		var sin:Float = Math.sin(-node.transform.g2d_worldRotation);
		
		var rx:Float = (tx*cos - ty*sin);
		var ry:Float = (ty*cos + tx*sin);
		
		rx /= zoom;
		ry /= zoom;

		return node.core.root.processContextMouseSignal(p_captured, rx+node.transform.g2d_worldX, ry+node.transform.g2d_worldY, p_signal, g2d_contextCamera);
	}
	
	/**
	 *
	 */
	override public function dispose():Void {
		node.core.g2d_removeCameraController(this);
		
		node.onAddedToStage.remove(onAddedToStage);
		node.onRemovedFromStage.remove(onRemovedFromStage);

		super.dispose();
	}

	private function onAddedToStage():Void {
		node.core.g2d_addCameraController(this);
	}

	private function onRemovedFromStage():Void {
		node.core.g2d_removeCameraController(this);
	}
}