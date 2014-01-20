package com.genome2d;

import com.genome2d.geom.GMatrix;
import com.genome2d.components.GCameraController;
import com.genome2d.node.GNode;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.error.GError;
import msignal.Signal;

import com.genome2d.context.GContext;
import com.genome2d.context.GContextConfig;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
class Genome2D
{
    // Genome2D version
	inline static public var VERSION:String = "1.0.235hx";

    // Singleton instance
	static private var g2d_instance:Genome2D;
    // Enforce singleton creation through getInstance
	static private var g2d_instantiable:Bool = false;

    // Get Genome2D instance
	static public function getInstance():Genome2D {
		g2d_instantiable = true;
		if (g2d_instance == null) new Genome2D();
		g2d_instantiable = false;
		return g2d_instance;
	}

    public var enabled:Bool = true;



    // Physics instance
	//public var physics:GPhysics;

    // Genome2D signals
    private var g2d_onInitialized:Signal0;
    #if swc @:extern #end
	public var onInitialized(get, never):Signal0;
    #if swc @:getter(onInitialized) #end
    inline private function get_onInitialized():Signal0 {
        return g2d_onInitialized;
    }

    private var g2d_onFailed:Signal0;
    #if swc @:extern #end
	public var onFailed(get, never):Signal0;
    #if swc @:getter(onFailed) #end
    inline private function get_onFailed():Signal0 {
        return g2d_onFailed;
    }

    private var g2d_onUpdate:Signal1<Float>;
    #if swc @:extern #end
	public var onUpdate(get, never):Signal1<Float>;
    #if swc @:getter(onUpdate) #end
    inline private function get_onUpdate():Signal1<Float> {
        return g2d_onUpdate;
    }

    private var g2d_onPreRender:Signal0;
    #if swc @:extern #end
	public var onPreRender(get, never):Signal0;
    #if swc @:getter(onPreRender) #end
    inline private function get_onPreRender():Signal0 {
        return g2d_onPreRender;
    }

    private var g2d_onPostRender:Signal0;
    #if swc @:extern #end
	public var onPostRender(get, never):Signal0;
    #if swc @:getter(onPostRender) #end
    inline private function get_onPostRender():Signal0 {
        return g2d_onPostRender;
    }

    // Current frame time
	private var g2d_currentTime:Float = 0;
    // Render frame id
	private var g2d_currentFrameId:Int = 0;
    inline public function getCurrentFrameId():Int {
        return g2d_currentFrameId;
    }

    // Last delta time
    private var g2d_currentFrameDeltaTime:Float;
    inline public function getCurrentFrameDeltaTime():Float {
        return g2d_currentFrameDeltaTime;
    }

    private var g2d_root:GNode;
    #if swc @:extern #end
	public var root(get, never):GNode;
    #if swc @:getter(root) #end
    inline private function get_root():GNode {
        return g2d_root;
    }

	private var g2d_context:GContext;
	inline public function getContext():GContext {
		return g2d_context;
	}

    private var g2d_cameras:Array<GCameraController>;

    public var backgroundRed:Float = 0;
    public var backgroundGreen:Float = 0;
    public var backgroundBlue:Float = 0;
    public var backgroundAlpha:Float = 1;

    public var g2d_renderMatrix:GMatrix;
    public var g2d_renderMatrixIndex:Int = 0;
    public var g2d_renderMatrixArray:Array<GMatrix>;

	/**
     *  CONSTRUCTOR
     **/
	private function new() {
		if (!g2d_instantiable) new GError("Can't instantiate singleton directly");
		
		g2d_instance = this;

        g2d_renderMatrix = new GMatrix();
        g2d_renderMatrixIndex = 0;
        g2d_renderMatrixArray = new Array<GMatrix>();

        // Initialize root
		g2d_root = new GNode("root");

        // Initialize camera controller array
        g2d_cameras = new Array<GCameraController>();

        // Initialize signals
		g2d_onInitialized = new Signal0();
		g2d_onFailed = new Signal0();

        g2d_onUpdate = new Signal1<Float>();
		g2d_onPreRender = new Signal0();
		g2d_onPostRender = new Signal0();
	}

    /**
     *  Initialize context
     **/
	public function init(p_config:GContextConfig):Void {
		if (g2d_context != null) g2d_context.dispose();
		
		g2d_context = Type.createInstance(p_config.g2d_contextClass, [p_config]);
		g2d_context.onInitialized.add(contextInitializedHandler);
		g2d_context.onFailed.add(contextFailedHandler);
		g2d_context.init();
	}

    /**
     *  Context initialized handler
     **/
	private function contextInitializedHandler():Void {
		g2d_context.onFrame.add(frameHandler);
        g2d_context.onMouseInteraction.add(contextMouseSignalHandler);
		
		onInitialized.dispatch();
	}

    /**
     *  Context failed to initialize handler
     **/
	private function contextFailedHandler():Void {
		onFailed.dispatch();
	}

    /**
     *  Frame handler called each frame
     **/
	private function frameHandler(p_deltaTime:Float):Void {
        if (enabled) {
            g2d_currentFrameId++;
		    update(p_deltaTime);
            render();
        }
	}

    /**
     *  Update node graph
     **/
	public function update(p_deltaTime:Float):Void {
        g2d_currentFrameDeltaTime = p_deltaTime;
        onUpdate.dispatch(g2d_currentFrameDeltaTime);

        /*
		if (physics != null && g2d_currentDeltaTime > 0) {
			physics.step(g2d_currentDeltaTime);
		}
		/**/
	}

    /**
     *  Render node graph
     **/
	public function render():Void {
        var cameraCount:Int = g2d_cameras.length;
		g2d_context.begin(backgroundRed, backgroundGreen, backgroundBlue, backgroundAlpha, cameraCount==0);
		onPreRender.dispatch();

        // Check if there is matrix useage in the pipeline
        if (root.transform.g2d_useMatrix > 0) {
            g2d_renderMatrix.identity();
            g2d_renderMatrixArray = [];
        }

        // If there is no camera render the root node directly
		if (cameraCount==0) {
			root.render(false, false, g2d_context.g2d_defaultCamera, false, false);
        // If there are cameras render the root through them
		} else {
			for (i in 0...cameraCount) {
				g2d_cameras[i].render();
			}
		}

        g2d_context.setCamera(g2d_context.g2d_defaultCamera);
		onPostRender.dispatch();
		g2d_context.end();
	}

    /**
     *  Add camera
     **/
	public function addCamera(p_camera:GCameraController):Void {
        for (i in 0...g2d_cameras.length) if (g2d_cameras[i] == p_camera) return;
        g2d_cameras.push(p_camera);
    }

    /**
     *  Remove camera
     **/
    public function removeCamera(p_camera:GCameraController):Void {
        for (i in 0...g2d_cameras.length) if (g2d_cameras[i] == p_camera) g2d_cameras.splice(i, 1);
    }

    /**
     *  Context mouse interaction handler
     **/
	private function contextMouseSignalHandler(p_signal:GMouseSignal):Void {
		var captured:Bool = false;

        // If there is no camera process the signal directly by root node
		if (g2d_cameras.length == 0) {
            root.processContextMouseSignal(captured, p_signal.x, p_signal.y, p_signal, null);
        // If there are cameras we need to process the signal through them
		} else {
		    for (i in 0...g2d_cameras.length) {
					g2d_cameras[i].g2d_capturedThisFrame = false;
			}
            for (i in 0...g2d_cameras.length) {
                g2d_cameras[i].captureMouseEvent(g2d_context, captured, p_signal);
            }
		}
	}
}