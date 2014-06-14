/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.context;

#if stage3Donly
typedef IContext = com.genome2d.context.stage3d.GStage3DContext;
#elseif webGLonly
typedef IContext = com.genome2d.context.webgl.GWebGLContext;
#else
#if swc
import flash.utils.Object;
#end
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import com.genome2d.signals.GKeyboardSignal;
import com.genome2d.textures.GContextTexture;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix3D;
import com.genome2d.context.filters.GFilter;

interface IContext {
    function hasFeature(p_feature:Int):Bool;

    #if flash
    var onInitialized(get,null):Signal0;
    var onFailed(get,null):Signal1<String>;
    var onInvalidated(get,null):Signal0;
    var onFrame(get,null):Signal1<Float>;
    var onMouseSignal(get,null):Signal1<GMouseSignal>;
    var onKeyboardSignal(get,null):Signal1<GKeyboardSignal>;
    #else
    var onInitialized(default,null):Signal0;
    var onFailed(default,null):Signal1<String>;
    var onInvalidated(default,null):Signal0;
    var onFrame(default,null):Signal1<Float>;
    var onMouseSignal(default,null):Signal1<GMouseSignal>;
    var onKeyboardSignal(default,null):Signal1<GKeyboardSignal>;
    #end
    function getStageViewRect():GRectangle;
    function getDefaultCamera():GContextCamera;
    #if swc
    function getNativeStage():Object;
    function getNativeContext():Object;;
    #else
    function getNativeStage():Dynamic;
    function getNativeContext():Dynamic;
    #end

    function getMaskRect():GRectangle;
    function setMaskRect(p_maskRect:GRectangle):Void;

    function setCamera(p_camera:GContextCamera):Void;

    function init():Void;
    function dispose():Void;

    function begin(p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float, p_useDefaultCamera:Bool = true):Void;
    function end():Void;

    function draw(p_texture:GContextTexture, p_x:Float, p_y:Float, p_scaleX:Float = 1, p_scaleY:Float = 1, p_rotation:Float = 0, p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1, p_blendMode:Int = 1, p_filter:GFilter = null):Void;

    function drawSource(p_texture:GContextTexture, p_sourceX:Float, p_sourceY:Float, p_sourceWidth:Float, p_sourceHeight:Float, p_x:Float, p_y:Float, p_scaleX:Float = 1, p_scaleY:Float = 1, p_rotation:Float = 0, p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1, p_blendMode:Int = 1, p_filter:GFilter = null):Void;

    function drawMatrix(p_texture:GContextTexture, p_a:Float, p_b:Float, p_c:Float, p_d:Float, p_tx:Float, p_ty:Float, p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float=1, p_blendMode:Int=1, p_filter:GFilter = null):Void;

    function drawPoly(p_texture:GContextTexture, p_vertices:Array<Float>, p_uvs:Array<Float>, p_x:Float, p_y:Float, p_scaleX:Float = 1, p_scaleY:Float = 1, p_rotation:Float = 0, p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1, p_blendMode:Int=1, p_filter:GFilter = null):Void;

    function bindRenderer(p_renderer:Dynamic):Void;

    // Low level
    function clearStencil():Void;
    function renderToStencil(p_stencilLayer:Int):Void;
    function renderToColor(p_stencilLayer:Int):Void;
    function setDepthTest(p_depthMask:Bool, p_compareMode:Dynamic):Void;
    function setRenderTarget(p_texture:GContextTexture = null, p_transform:GMatrix3D = null):Void;
    function setRenderTargets(p_textures:Array<GContextTexture>, p_transform:GMatrix3D = null):Void;
}
#end