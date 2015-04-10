/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d;

import com.genome2d.callbacks.GCallback;
import com.genome2d.debug.IGDebuggableInternal;
import com.genome2d.macros.MGDebug;
import com.genome2d.macros.MGBuildID;
import com.genome2d.ui.skin.GUISkinManager;
import com.genome2d.assets.GAssetManager;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.textures.GTextureManager;
import com.genome2d.input.GKeyboardInput;
import com.genome2d.context.IContext;
import com.genome2d.geom.GMatrix;
import com.genome2d.components.GCameraController;
import com.genome2d.node.GNode;
import com.genome2d.input.GMouseInput;

import com.genome2d.context.GContextConfig;

/**
    Genome2D core class
**/
class Genome2D implements IGDebuggableInternal
{    /**
        Genome2D Version
    **/
	inline static public var VERSION:String = "1.1";
    inline static public var BUILD:String = MGBuildID.getBuildId();
    inline static public var DATE:String = MGBuildID.getBuildDate();

	static private var g2d_instance:Genome2D;
	static private var g2d_instantiable:Bool = false;

    /**
        Get the singleton instance of Genome2D
    **/
	inline static public function getInstance():Genome2D {
		if (g2d_instance == null) {
            g2d_instantiable = true;
            new Genome2D();
		    g2d_instantiable = false;
        }
		return g2d_instance;
	}

    /**
        Enable/disable auto updating and rendering of Genome2D node graph

        default `true`
    **/
    public var autoUpdateAndRender:Bool = true;

    /*
     *  CALLBACKS
     */
    private var g2d_onInitialized:GCallback0;
    /**
        Callback dispatched when Genome2D initializes successfully
    **/
    #if swc @:extern #end
	public var onInitialized(get, never):GCallback0;
    #if swc @:getter(onInitialized) #end
    inline private function get_onInitialized():GCallback0 {
        return g2d_onInitialized;
    }

    private var g2d_onFailed:GCallback1<String>;
    /**
        Callback dispatched when Genome2D fails to initialize

        Sends reason message
    **/
    #if swc @:extern #end
	public var onFailed(get, never):GCallback1<String>;
    #if swc @:getter(onFailed) #end
    inline private function get_onFailed():GCallback1<String> {
        return g2d_onFailed;
    }

    private var g2d_onInvalidated:GCallback0;
    /**
        Callback dispatched when Genome2D is invalidated
    **/
    #if swc @:extern #end
    public var onInvalidated(get, never):GCallback0;
    #if swc @:getter(onInvalidated) #end
    inline private function get_onInvalidated():GCallback0 {
        return g2d_onInvalidated;
    }

    private var g2d_onUpdate:GCallback1<Float>;
    /**
        Callback dispatched when Genome2D is updated to next frame

        Sends deltaTime `Float` passed between updates
    **/
    #if swc @:extern #end
	public var onUpdate(get, never):GCallback1<Float>;
    #if swc @:getter(onUpdate) #end
    inline private function get_onUpdate():GCallback1<Float> {
        return g2d_onUpdate;
    }

    private var g2d_onPreRender:GCallback0;
    /**
        Callback dispatched when Genome2D is rendering, before it renders its own node graph
    **/
    #if swc @:extern #end
	public var onPreRender(get, never):GCallback0;
    #if swc @:getter(onPreRender) #end
    inline private function get_onPreRender():GCallback0 {
        return g2d_onPreRender;
    }

    private var g2d_onPostRender:GCallback0;
    /**
        Callback dispatched when Genome2D is rendering, after it rendered its own node graph
    **/
    #if swc @:extern #end
	public var onPostRender(get, never):GCallback0;
    #if swc @:getter(onPostRender) #end
    inline private function get_onPostRender():GCallback0 {
        return g2d_onPostRender;
    }

    private var g2d_onKeyboardInput:GCallback1<GKeyboardInput>;
    /**
        Callback dispatched when Genome2D processes keyboard callbacks
    **/
    #if swc @:extern #end
    public var onKeyboardInput(get, never):GCallback1<GKeyboardInput>;
    #if swc @:getter(onKeyboardInput) #end
    inline private function get_onKeyboardInput():GCallback1<GKeyboardInput> {
        return g2d_onKeyboardInput;
    }

	private var g2d_currentFrameId:Int = 0;
    /**
        Return current Genome2D frame Id
    **/
    inline public function getCurrentFrameId():Int {
        return g2d_currentFrameId;
    }

    private var g2d_runTime:Float = 0;
    /**
        Return current Genome2D time from start
    **/
    inline public function getRunTime():Float {
        return g2d_runTime;
    }

    private var g2d_currentFrameDeltaTime:Float;
    /**
        Return current frame delta time
    **/
    inline public function getCurrentFrameDeltaTime():Float {
        return g2d_currentFrameDeltaTime;
    }

    private var g2d_root:GNode;
    /**
        Root `GNode` the parent of the whole node graph
    **/
    #if swc @:extern #end
	public var root(get, never):GNode;
    #if swc @:getter(root) #end
    inline private function get_root():GNode {
        return g2d_root;
    }

	private var g2d_context:IContext;
	inline public function getContext():IContext {
		return g2d_context;
	}

    // TODO move this somewhere else for complext matrix transforms
    @:allow(com.genome2d.components.renderable.GTexturedQuad)
    private var g2d_renderMatrix:GMatrix;
    private var g2d_renderMatrixIndex:Int = 0;
    private var g2d_renderMatrixArray:Array<GMatrix>;

    private var g2d_contextConfig:GContextConfig;
    private var g2d_cameras:Array<GCameraController>;

	/**
       CONSTRUCTOR
    **/
    @:dox(hide)
	private function new() {
		if (!g2d_instantiable) MGDebug.ERROR("Can't instantiate singleton directly");

		g2d_instance = this;

        g2d_onInitialized = new GCallback0();
        g2d_onFailed = new GCallback1<String>();
        g2d_onInvalidated = new GCallback0();
        g2d_onUpdate = new GCallback1<Float>();
        g2d_onPreRender = new GCallback0();
        g2d_onPostRender = new GCallback0();
        g2d_onKeyboardInput = new GCallback1<GKeyboardInput>();
	}

    /**
        Initialize Genome2D

        @param p_config `GContextConfig` instance configuring Genome2D context
    **/
	public function init(p_config:GContextConfig):Void {
        GPrototypeFactory.initializePrototypes();
        GAssetManager.init();

        // Initialize root
        if (g2d_root != null) g2d_root.dispose();
        g2d_root = GNode.create("root");

        // Initialize camera controller array
        g2d_cameras = new Array<GCameraController>();

        // Prepare matrix structures
        g2d_renderMatrix = new GMatrix();
        g2d_renderMatrixIndex = 0;
        g2d_renderMatrixArray = new Array<GMatrix>();

        if (g2d_context != null) g2d_context.dispose();
        g2d_contextConfig = p_config;
		g2d_context = Type.createInstance(p_config.contextClass, [g2d_contextConfig]);
		g2d_context.onInitialized.add(g2d_contextInitialized_handler);
		g2d_context.onFailed.add(g2d_contextFailed_handler);
        g2d_context.onInvalidated.add(g2d_contextInvalidated_handler);
		g2d_context.init();
	}

    /**
        Update node graph

        This method is called automatically if `autoUpdateAndRender` is true
    **/
	public function update(p_deltaTime:Float):Void {
        g2d_currentFrameDeltaTime = p_deltaTime;
        onUpdate.dispatch(g2d_currentFrameDeltaTime);
	}

    /**
        Render node graph

        This method is called automatically if `autoUpdateAndRender` is true
    **/
    @:access(com.genome2d.components.GTransform)
	public function render(p_camera:GCameraController = null):Void {
		if (g2d_context.begin()) {
            onPreRender.dispatch();

            // Check if there is matrix usage in the pipeline
            if (root.g2d_useMatrix > 0) {
                g2d_renderMatrix.identity();
                g2d_renderMatrixArray = [];
            }

            if (p_camera != null) {
                p_camera.render();
            } else {
                var cameraCount:Int = g2d_cameras.length;
                // If there is no camera render the root node directly
                if (cameraCount==0) {
                    root.render(false, false, g2d_context.getDefaultCamera(), false, false);
                // If there are cameras render the root through them
                } else {
                    for (i in 0...cameraCount) {
                        g2d_cameras[i].render();
                    }
                }
            }

            if (onPostRender.hasListeners()) {
                g2d_context.setActiveCamera(g2d_context.getDefaultCamera());
                g2d_context.setRenderTarget(null);
                onPostRender.dispatch();
            }
            g2d_context.end();
        }
	}

    /**
        Dispose Genome2D framework
    **/
    public function dispose():Void {
        if (g2d_root != null) g2d_root.dispose();
        g2d_root = null;

        g2d_onInitialized.removeAll();
        g2d_onFailed.removeAll();
        g2d_onPostRender.removeAll();
        g2d_onPreRender.removeAll();
        g2d_onUpdate.removeAll();
        g2d_onInvalidated.removeAll();
        g2d_onKeyboardInput.removeAll();

        g2d_context.dispose();
        g2d_context = null;
    }

    private function g2d_contextInitialized_handler():Void {
        GTextureManager.init();
        GUISkinManager.init();

        g2d_context.onFrame.add(g2d_frame_handler);
        g2d_context.onMouseInput.add(g2d_contextMouseInput_handler);
        g2d_context.onKeyboardInput.add(g2d_contextKeyboardInput_handler);

        onInitialized.dispatch();
    }

    private function g2d_contextFailed_handler(p_error:String):Void {
        if (g2d_contextConfig.fallbackContextClass != null) {
            g2d_context = Type.createInstance(g2d_contextConfig.fallbackContextClass, [g2d_contextConfig]);
            g2d_context.onInitialized.add(g2d_contextInitialized_handler);
            g2d_context.onFailed.add(g2d_contextFailed_handler);
            g2d_context.init();
        }

        onFailed.dispatch(p_error);
    }

    private function g2d_contextInvalidated_handler():Void {
        onInvalidated.dispatch();
    }

    private function g2d_frame_handler(p_deltaTime:Float):Void {
        if (autoUpdateAndRender) {
            g2d_currentFrameId++;
            g2d_runTime += p_deltaTime;
            update(p_deltaTime);
            render();
        }
    }

    @:allow(com.genome2d.components.GCameraController)
	private function g2d_addCameraController(p_camera:GCameraController):Void {
        for (i in 0...g2d_cameras.length) {
            if (g2d_cameras[i] == p_camera) return;
        }
        g2d_cameras.push(p_camera);
    }

    @:allow(com.genome2d.components.GCameraController)
    private function g2d_removeCameraController(p_camera:GCameraController):Void {
        for (i in 0...g2d_cameras.length) {
            if (g2d_cameras[i] == p_camera) g2d_cameras.splice(i, 1);
        }
    }

    @:access(com.genome2d.components.GCameraController)
	private function g2d_contextMouseInput_handler(p_input:GMouseInput):Void {
        // If there is no camera process the callbacks directly by root node
		if (g2d_cameras.length == 0) {
            root.processContextMouseInput(p_input.nativeCaptured, p_input.x, p_input.y, p_input, null);
        // If there are cameras we need to process the callbacks through them
		} else {
            var captured:Bool = p_input.nativeCaptured;
		    for (i in 0...g2d_cameras.length) {
				g2d_cameras[i].g2d_capturedThisFrame = false;
			}
            var i:Int = g2d_cameras.length-1;
            while (i>=0) {
                captured = captured || g2d_cameras[i].captureMouseInput(g2d_context, captured, p_input);
                i--;
            }
		}
	}

    private function g2d_contextKeyboardInput_handler(p_input:GKeyboardInput):Void {
        onKeyboardInput.dispatch(p_input);
    }
}