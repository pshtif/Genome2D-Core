/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d;

import com.genome2d.signals.GKeyboardSignal;
import com.genome2d.components.GTransform;
import com.genome2d.textures.factories.GTextureAtlasFactory;
import com.genome2d.textures.factories.GTextureFactory;
import com.genome2d.context.IContext;
import com.genome2d.geom.GMatrix;
import com.genome2d.components.GCameraController;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.error.GError;
import msignal.Signal;

import com.genome2d.context.GContextConfig;

/**
    Genome2D core class
**/
class Genome2D
{
    static public function main():Void {
        // Abstract method to enable Haxe direct build
    }

    /**
        Genome2D Version
    **/
	inline static public var VERSION:String = "1.0.274";

	static private var g2d_instance:Genome2D;
	static private var g2d_instantiable:Bool = false;

    /**
        Get the singleton instance of Genome2D
    **/
	static public function getInstance():Genome2D {
		g2d_instantiable = true;
		if (g2d_instance == null) new Genome2D();
		g2d_instantiable = false;
		return g2d_instance;
	}

    /**
        Enable/disable auto updating and rendering of Genome2D node graph

        default `true`
    **/
    public var autoUpdateAndRender:Bool = true;

    /*
     *  SIGNALS
     */
    private var g2d_onInitialized:Signal0;
    /**
        Signal dispatched when Genome2D initializes successfully
    **/
    #if swc @:extern #end
	public var onInitialized(get, never):Signal0;
    #if swc @:getter(onInitialized) #end
    inline private function get_onInitialized():Signal0 {
        return g2d_onInitialized;
    }

    private var g2d_onFailed:Signal1<String>;
    /**
        Signal dispatched when Genome2D fails to initialize

        Sends reason message
    **/
    #if swc @:extern #end
	public var onFailed(get, never):Signal1<String>;
    #if swc @:getter(onFailed) #end
    inline private function get_onFailed():Signal1<String> {
        return g2d_onFailed;
    }

    private var g2d_onInvalidated:Signal0;
    /**
        Signal dispatched when Genome2D is invalidated
    **/
    #if swc @:extern #end
    public var onInvalidated(get, never):Signal0;
    #if swc @:getter(onInvalidated) #end
    inline private function get_onInvalidated():Signal0 {
        return g2d_onInvalidated;
    }

    private var g2d_onUpdate:Signal1<Float>;
    /**
        Signal dispatched when Genome2D is updated to next frame

        Sends deltaTime `Float` passed between updates
    **/
    #if swc @:extern #end
	public var onUpdate(get, never):Signal1<Float>;
    #if swc @:getter(onUpdate) #end
    inline private function get_onUpdate():Signal1<Float> {
        return g2d_onUpdate;
    }

    private var g2d_onPreRender:Signal0;
    /**
        Signal dispatched when Genome2D is rendering, before it renders its own node graph
    **/
    #if swc @:extern #end
	public var onPreRender(get, never):Signal0;
    #if swc @:getter(onPreRender) #end
    inline private function get_onPreRender():Signal0 {
        return g2d_onPreRender;
    }

    private var g2d_onPostRender:Signal0;
    /**
        Signal dispatched when Genome2D is rendering, after it rendered its own node graph
    **/
    #if swc @:extern #end
	public var onPostRender(get, never):Signal0;
    #if swc @:getter(onPostRender) #end
    inline private function get_onPostRender():Signal0 {
        return g2d_onPostRender;
    }

    private var g2d_onKeySignal:Signal1<GKeyboardSignal>;
    /**
        Signal dispatched when Genome2D processes keyboard signal
    **/
    #if swc @:extern #end
    public var onKeySignal(get, never):Signal1<GKeyboardSignal>;
    #if swc @:getter(onKeySignal) #end
    inline private function get_onKeySignal():Signal1<GKeyboardSignal> {
        return g2d_onKeySignal;
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

    @:allow(com.genome2d.components.renderables.GTexturedQuad)
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
		if (!g2d_instantiable) new GError("Can't instantiate singleton directly");
		g2d_instance = this;

        g2d_onInitialized = new Signal0();
        g2d_onFailed = new Signal1<String>();
        g2d_onInvalidated = new Signal0();
        g2d_onUpdate = new Signal1<Float>();
        g2d_onPreRender = new Signal0();
        g2d_onPostRender = new Signal0();
        g2d_onKeySignal = new Signal1<GKeyboardSignal>();
	}

    /**
        Initialize Genome2D

        @param p_config `GContextConfig` instance configuring Genome2D context
    **/
	public function init(p_config:GContextConfig):Void {
        // Initialize root
        if (g2d_root != null) g2d_root.dispose();
        g2d_root = new GNode("root");

        // Initialize camera controller array
        g2d_cameras = new Array<GCameraController>();

        // Prepare matrix structures
        g2d_renderMatrix = new GMatrix();
        g2d_renderMatrixIndex = 0;
        g2d_renderMatrixArray = new Array<GMatrix>();

        if (g2d_context != null) g2d_context.dispose();
        g2d_contextConfig = p_config;
		g2d_context = Type.createInstance(p_config.contextClass, [g2d_contextConfig]);
		g2d_context.onInitialized.add(g2d_contextInitializedHandler);
		g2d_context.onFailed.add(g2d_contextFailedHandler);
        g2d_context.onInvalidated.add(g2d_contextInvalidatedHandler);
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
	public function render():Void {
        var cameraCount:Int = g2d_cameras.length;
		g2d_context.begin();
		onPreRender.dispatch();

        // Check if there is matrix usage in the pipeline
        if (root.transform.g2d_useMatrix > 0) {
            g2d_renderMatrix.identity();
            g2d_renderMatrixArray = [];
        }

        // If there is no camera render the root node directly
		if (cameraCount==0) {
			root.render(false, false, g2d_context.getDefaultCamera(), false, false);
        // If there are cameras render the root through them
		} else {
			for (i in 0...cameraCount) {
				g2d_cameras[i].render();
			}
		}

        if (onPostRender.numListeners>0) {
            g2d_context.setCamera(g2d_context.getDefaultCamera());
            g2d_context.setRenderTarget(null);
		    onPostRender.dispatch();
        }
		g2d_context.end();
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
        g2d_onKeySignal.removeAll();

        g2d_context.dispose();
        g2d_context = null;
    }

    private function g2d_contextInitializedHandler():Void {
        GTextureFactory.g2d_context = GTextureAtlasFactory.g2d_context = g2d_context;

        g2d_context.onFrame.add(g2d_frameHandler);
        g2d_context.onMouseSignal.add(g2d_contextMouseSignalHandler);
        g2d_context.onKeyboardSignal.add(g2d_contextKeySignalHandler);

        onInitialized.dispatch();
    }

    private function g2d_contextFailedHandler(p_error:String):Void {
        if (g2d_contextConfig.fallbackContextClass != null) {
            g2d_context = Type.createInstance(g2d_contextConfig.fallbackContextClass, [g2d_contextConfig]);
            g2d_context.onInitialized.add(g2d_contextInitializedHandler);
            g2d_context.onFailed.add(g2d_contextFailedHandler);
            g2d_context.init();
        }

        onFailed.dispatch(p_error);
    }

    private function g2d_contextInvalidatedHandler():Void {
        onInvalidated.dispatch();
    }

    private function g2d_frameHandler(p_deltaTime:Float):Void {
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
	private function g2d_contextMouseSignalHandler(p_signal:GMouseSignal):Void {
        // If there is no camera process the signal directly by root node
		if (g2d_cameras.length == 0) {
            root.processContextMouseSignal(p_signal.nativeCaptured, p_signal.x, p_signal.y, p_signal, null);
        // If there are cameras we need to process the signal through them
		} else {
		    for (i in 0...g2d_cameras.length) {
				g2d_cameras[i].g2d_capturedThisFrame = false;
			}
            for (i in 0...g2d_cameras.length) {
                g2d_cameras[i].captureMouseEvent(g2d_context, p_signal.nativeCaptured, p_signal);
            }
		}
	}

    private function g2d_contextKeySignalHandler(p_signal:GKeyboardSignal):Void {
        onKeySignal.dispatch(p_signal);
    }
}