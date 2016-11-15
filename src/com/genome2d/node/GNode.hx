/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.node;

import com.genome2d.components.renderable.IGInteractive;
import com.genome2d.components.renderable.GSprite;
import com.genome2d.callbacks.GCallback;
import com.genome2d.geom.GPoint;
import com.genome2d.context.filters.GFilter;
import com.genome2d.input.IGFocusable;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.context.GContextFeature;
import com.genome2d.context.stats.GStats;
import com.genome2d.geom.GRectangle;
import com.genome2d.postprocess.GPostProcess;
import com.genome2d.geom.GMatrix;
import com.genome2d.geom.GMatrixUtils;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.context.GCamera;
import com.genome2d.input.GMouseInputType;
import com.genome2d.debug.GDebug;
import com.genome2d.input.GMouseInput;

/**
    Node class
**/
@:access(com.genome2d.Genome2D)
@:access(com.genome2d.node.GNodePool)
@prototypeName("node")
@:build(com.genome2d.macros.MGMouseCallbackBuild.build())
class GNode implements IGFocusable implements IGPrototypable
{
    /****************************************************************************************************
	 * 	FACTORY METHODS
	 ****************************************************************************************************/

    /**
	 * 	Create node with a specific component
	 *
	 *	@param p_componentClass component type that should be instanced and attached to this node
	 *  @param p_name optional name for the node
	 *  @param p_lookupClass option lookup class for component
	 */
    static public function createWithComponent<T:GComponent>(p_componentClass:Class<GComponent>, p_name:String = ""):T {
        var node:GNode = new GNode();
        if (p_name != "") node.name = p_name;

        return node.addComponent(p_componentClass);
    }


    static private var g2d_cachedArray:Array<GNode>;
    static private var g2d_cachedMatrix:GMatrix;
    static private var g2d_activeMasks:Array<GNode>;

    /**
	    Genome2D core instance
	**/
    static private var g2d_core:Genome2D;
    #if swc @:extern #end
    public var core(get, never):Genome2D;
    #if swc @:getter(core) #end
    inline private function get_core():Genome2D {
        if (g2d_core == null) g2d_core = Genome2D.getInstance();
        return g2d_core;
    }
	
	/**
	    Camera group this node belongs to, a node is rendered through this camera if camera.mask&node.cameraGroup != 0
	**/
	public var cameraGroup:Int = 0;

	private var g2d_pool:GNodePool;
	private var g2d_poolNext:GNode;
	private var g2d_poolPrevious:GNode;

    /**
	    Masking _rectangle
	**/
    public var maskRect:GRectangle;

    /**
	    Masking node
	**/
    private var g2d_usedAsMask:Int = 0;
    private var g2d_mask:GNode;
    #if swc @:extern #end
    public var mask(get, set):GNode;
    #if swc @:getter(mask) #end
    inline private function get_mask():GNode {
        return g2d_mask;
    }
    #if swc @:setter(mask) #end
    inline private function set_mask(p_value:GNode):GNode {
        if (!core.getContext().hasFeature(GContextFeature.STENCIL_MASKING)) GDebug.error("Stencil masking feature not supported.");
        if (g2d_mask != null) g2d_mask.g2d_usedAsMask--;
        g2d_mask = p_value;
        g2d_mask.g2d_usedAsMask++;
        return g2d_mask;
    }
	
	/**
	    Abstract reference to user defined data, if you want keep some custom data binded to G2DNode instance use it.
	**/
	public var userData:Dynamic;

	private var g2d_active:Bool = true;

    /**
	    Check if node is active
	**/
	inline public function isActive():Bool {
        return g2d_active;
	}

    /**
	    Set node active state
	**/
	public function setActive(p_value:Bool):Void {
		if (p_value != g2d_active) {
			if (g2d_disposed) GDebug.error("Node already disposed.");
			
			g2d_active = p_value;

            for (i in 0...g2d_componentCount) {
                g2d_components[i].setActive(p_value);
            }

            var child:GNode = g2d_firstChild;
            while (child != null) {
                var next:GNode = child.g2d_next;
                child.setActive(p_value);
                child = next;
            }
		}
	}

	private var g2d_id:Int;
    #if swc @:extern #end
    public var id(get, never):Int;
    #if swc @:getter(id) #end
    inline private function get_id():Int {
        return g2d_id;
    }

	/**
	    Node name
	**/
	@prototype
	public var name:String;

    /**
	    Node postprocess
	**/
	@prototype
    public var postProcess:GPostProcess;

    /**
	    Node parent
	**/
	private var g2d_parent:GNode;
	#if swc @:extern #end
	public var parent(get, never):GNode;
	#if swc @:getter(parent) #end
	inline private function get_parent():GNode {
		return g2d_parent;
	}

    /**
	    Check if the node is disposed
	**/
	private var g2d_disposed:Bool = false;
    inline private function isDisposed():Bool {
        return g2d_disposed;
    }

	static private var g2d_nodeCount:Int = 0;

	@:dox(hide)
	public function new(p_name:String = "") {
		g2d_id = g2d_nodeCount++;
		name = p_name == "" ? "node" : p_name;
        // Create cached instances
        if (g2d_cachedMatrix == null)  {
            g2d_cachedMatrix = new GMatrix();
            g2d_cachedTransformMatrix = new GMatrix();
            g2d_activeMasks = new Array<GNode>();
        }
	}
	
	/**
	 * 	This method disposes this node, this will also dispose all of its children, components and callbacks
	 */
	public function dispose():Void {
		if (g2d_disposed) return;

        disposeComponents();
		disposeChildren();
		
		if (parent != null) {
			parent.removeChild(this);
		}

		disposeCallbacks();
		
		g2d_disposed = true;
	}

    public function disposeCallbacks():Void {
        // Dispose callbacks
        if (g2d_onAddedToStage != null) { g2d_onAddedToStage.removeAll(); g2d_onAddedToStage = null; }
        if (g2d_onRemovedFromStage != null) { g2d_onRemovedFromStage.removeAll(); g2d_onRemovedFromStage = null; }
        if (g2d_onMouseClick != null) { g2d_onMouseClick.removeAll(); g2d_onMouseClick = null; }
        if (g2d_onMouseDown != null) { g2d_onMouseDown.removeAll(); g2d_onMouseDown = null; }
        if (g2d_onMouseMove != null) { g2d_onMouseMove.removeAll(); g2d_onMouseMove = null; }
        if (g2d_onMouseOut != null) { g2d_onMouseOut.removeAll(); g2d_onMouseOut = null; }
        if (g2d_onMouseOver != null) { g2d_onMouseOver.removeAll(); g2d_onMouseOver = null; }
        if (g2d_onMouseUp != null) { g2d_onMouseUp.removeAll(); g2d_onMouseUp = null; }
        if (g2d_onRightMouseClick != null) { g2d_onRightMouseClick.removeAll(); g2d_onRightMouseClick = null; }
        if (g2d_onRightMouseDown != null) { g2d_onRightMouseDown.removeAll(); g2d_onRightMouseDown = null; }
        if (g2d_onRightMouseUp != null) { g2d_onRightMouseUp.removeAll(); g2d_onRightMouseUp = null; }
    }
	
	public function hitTest(p_x:Float, p_y:Float, p_hierarchy:Bool = false):Bool {
		if (isActive() && visible) {
			if (p_hierarchy) {
				var child:GNode = g2d_lastChild;
				while (child != null) {
					var previous:GNode = child.g2d_previous;
					if (child.hitTest(p_x, p_y, true)) return true;
					child = previous;
				}
			}
			
			if (g2d_renderable != null || g2d_defaultRenderable != null) {
				var tx:Float = p_x - g2d_worldX;
				var ty:Float = p_y - g2d_worldY;

				if (g2d_worldRotation != 0) {
					var cos:Float = Math.cos(-g2d_worldRotation);
					var sin:Float = Math.sin(-g2d_worldRotation);

					var ox:Float = tx;
					tx = (tx*cos - ty*sin);
					ty = (ty*cos + ox*sin);
				}

				tx /= g2d_worldScaleX;
				ty /= g2d_worldScaleY;
				
				if ((g2d_defaultRenderable != null) ? g2d_defaultRenderable.hitTest(tx, ty) : g2d_renderable.hitTest(tx, ty)) return true;
			}
		}
		
		return false;
	}
	
	public function getNodesUnderPoint(p_x:Float, p_y:Float):Array<GNode> {
		var found:Array<GNode> = new Array<GNode>();
		if (isActive() && visible) {
			var child:GNode = g2d_lastChild;
			while (child != null) {
				var previous:GNode = child.g2d_previous;
				found = found.concat(child.getNodesUnderPoint(p_x, p_y));
				child = previous;
			}
			
			if (g2d_renderable != null || g2d_defaultRenderable != null) {
				var tx:Float = p_x - g2d_worldX;
				var ty:Float = p_y - g2d_worldY;

				if (g2d_worldRotation != 0) {
					var cos:Float = Math.cos(-g2d_worldRotation);
					var sin:Float = Math.sin(-g2d_worldRotation);

					var ox:Float = tx;
					tx = (tx*cos - ty*sin);
					ty = (ty*cos + ox*sin);
				}

				tx /= g2d_worldScaleX;
				ty /= g2d_worldScaleY;
				
				if ((g2d_defaultRenderable != null) ? g2d_defaultRenderable.hitTest(tx, ty) : g2d_renderable.hitTest(tx, ty)) found.push(this);
			}
		}
		
		return found;
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/
	
	public function getPrototype(p_prototype:GPrototype = null):GPrototype {
		p_prototype = getPrototypeDefault(p_prototype);
		
		if (g2d_components != null) {
			for (component in g2d_components) {
				p_prototype.addChild(component.getPrototype(), "components");
			}
		}
		
		var child:GNode = g2d_firstChild;
        while (child != null) {
            p_prototype.addChild(child.getPrototype(), "children");
            child = child.g2d_next;
		}
		
		return p_prototype;
	}
	
	public function bindPrototype(p_prototype:GPrototype):Void {
		bindPrototypeDefault(p_prototype);

		var components:Array<GPrototype> = p_prototype.getGroup("components");
		if (components != null) {
			for (component in components) {
				addComponentPrototype(component);
			}
		}
		
		var children:Array<GPrototype> = p_prototype.getGroup("children");
		if (children != null) {
			for (child in children) {
				addChild(cast GPrototypeFactory.createInstance(child));
			}
		}
	}

	/****************************************************************************************************
	 * 	MOUSE CODE
	 ****************************************************************************************************/

    /**
	    True if children should process mouse callbacks
	**/
	public var mouseChildren:Bool = true;
    /**
	    True if node should process mouse callbacks
	**/
	public var mouseEnabled:Bool = false;

	// Mouse callbacks
    // Now generated in macro
	/*
	private var g2d_onMouseDown:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseDown(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseDown) #end
	private function get_onMouseDown():GCallback1<GMouseInput> {
		if (g2d_onMouseDown == null) g2d_onMouseDown = new GCallback1(GMouseInput);
		return g2d_onMouseDown;
	}

    private var g2d_onRightMouseDown:GCallback1<GMouseInput>;
    #if swc @:extern #end
    public var onRightMouseDown(get, never):GCallback1<GMouseInput>;
        #if swc @:getter(onRightMouseDown) #end
    private function get_onRightMouseDown():GCallback1<GMouseInput> {
        if (g2d_onRightMouseDown == null) g2d_onRightMouseDown = new GCallback1(GMouseInput);
        return g2d_onRightMouseDown;
    }
	private var g2d_onMouseMove:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseMove(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseMove) #end
	private function get_onMouseMove():GCallback1<GMouseInput> {
		if (g2d_onMouseMove == null) g2d_onMouseMove = new GCallback1(GMouseInput);
		return g2d_onMouseMove;
	}
	private var g2d_onMouseClick:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseClick(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseClick) #end
	private function get_onMouseClick():GCallback1<GMouseInput> {
		if (g2d_onMouseClick == null) g2d_onMouseClick = new GCallback1(GMouseInput);
		return g2d_onMouseClick;
	}
	private var g2d_onMouseUp:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseUp(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseUp) #end
	private function get_onMouseUp():GCallback1<GMouseInput> {
		if (g2d_onMouseUp == null) g2d_onMouseUp = new GCallback1(GMouseInput);
		return g2d_onMouseUp;
	}
	private var g2d_onMouseOver:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseOver(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseOver) #end
	private function get_onMouseOver():GCallback1<GMouseInput> {
		if (g2d_onMouseOver == null) g2d_onMouseOver = new GCallback1(GMouseInput);
		return g2d_onMouseOver;
	}
	private var g2d_onMouseOut:GCallback1<GMouseInput>;
    #if swc @:extern #end
	public var onMouseOut(get, never):GCallback1<GMouseInput>;
    #if swc @:getter(onMouseOut) #end
	private function get_onMouseOut():GCallback1<GMouseInput> {
		if (g2d_onMouseOut == null) g2d_onMouseOut = new GCallback1(GMouseInput);
		return g2d_onMouseOut;
	}
	/*
    // TODO setup getter/setter
	private var g2d_onRightMouseUp:GCallback1<GMouseInput>;
	public var onRightMouseUp:GCallback1<GMouseInput>;
	private var g2d_onRightMouseClick:GCallback1<GMouseInput>;
	public var onRightMouseClick:GCallback1<GMouseInput>;
	/**/
	public var g2d_mouseDownNode:GNode;
	public var g2d_mouseOverNode:GNode;
	public var g2d_rightMouseDownNode:GNode;

	/**
     *  Capture context mouse callbacks
     **/
	public function captureMouseInput(p_input:GMouseInput):Void {
		if (!isActive() || !visible || (p_input.camera != null && (cameraGroup & p_input.camera.contextCamera.group) == 0 && cameraGroup != 0)) return;
		
		if (mouseChildren) {
            var child:GNode = g2d_lastChild;
            while (child != null) {
                var previous:GNode = child.g2d_previous;
				child.captureMouseInput(p_input);
                child = previous;
			}
		}
		
		if (mouseEnabled) {
			if (p_input.captured && p_input.type == GMouseInputType.MOUSE_UP) g2d_mouseDownNode = null;
			
			var previouslyCaptured:Bool = p_input.captured;
			
			//if (g2d_renderable != null || g2d_defaultRenderable != null) {
			if (g2d_components != null) {
				var tx:Float = p_input.worldX - g2d_worldX;
				var ty:Float = p_input.worldY - g2d_worldY;

				if (g2d_worldRotation != 0) {
					var cos:Float = Math.cos(-g2d_worldRotation);
					var sin:Float = Math.sin(-g2d_worldRotation);
					var ox:Float = tx;
					tx = (tx*cos - ty*sin);
					ty = (ty*cos + ox*sin);
				}

				p_input.localX = (g2d_worldScaleX == 0) ? Math.POSITIVE_INFINITY : tx / g2d_worldScaleX;
				p_input.localY = (g2d_worldScaleY == 0) ? Math.POSITIVE_INFINITY : ty / g2d_worldScaleY;

				for (component in g2d_components) {
					if (Std.is(component,IGInteractive)) {
						cast (component,IGInteractive).captureMouseInput(p_input);
					}
				}
				/*
				if (g2d_defaultRenderable != null) {
					g2d_defaultRenderable.captureMouseInput(p_input);
				} else {
					g2d_renderable.captureMouseInput(p_input);
				}
				/**/
			}
			
			if (!previouslyCaptured && p_input.captured) {
				g2d_dispatchMouseCallback(p_input.type, this, p_input);
				if (g2d_mouseOverNode != this) {
					g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OVER, this, p_input);
				}
			} else if (g2d_mouseOverNode == this) {
				g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OUT, this, p_input);
			}
		}
	}

    private var g2d_lastClickTime:Float = -1;
	/**
     *  Dispatch node mouse callbacks
     **/
	private function g2d_dispatchMouseCallback(p_type:String, p_object:GNode, p_input:GMouseInput):Void {
		if (mouseEnabled) { 
			var mouseInput:GMouseInput = p_input.clone(this, p_object, p_type);

            switch (p_type) {
                case GMouseInputType.MOUSE_WHEEL:
                    if (g2d_onMouseWheel != null) g2d_onMouseWheel.dispatch(mouseInput);
                case GMouseInputType.MOUSE_DOWN:
                    g2d_mouseDownNode = p_object;
                    if (g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseInput);
                case GMouseInputType.RIGHT_MOUSE_DOWN:
                    g2d_rightMouseDownNode = p_object;
                    if (g2d_onRightMouseDown != null) g2d_onRightMouseDown.dispatch(mouseInput);
                case GMouseInputType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseInput);
                case GMouseInputType.MOUSE_UP:
                    if (g2d_mouseDownNode == p_object && g2d_onMouseClick != null) {
                        var mouseClickInput:GMouseInput = p_input.clone(this, p_object, GMouseInputType.MOUSE_UP);
                        if (g2d_onMouseClick != null) g2d_onMouseClick.dispatch(mouseClickInput);
                        if (g2d_lastClickTime>0 && p_input.time-g2d_lastClickTime<GMouseInput.DOUBLE_CLICK_TIME) {
                            if (g2d_onDoubleMouseClick != null) g2d_onDoubleMouseClick.dispatch(mouseClickInput);
                            g2d_lastClickTime = -1;
                        } else {
                            g2d_lastClickTime = p_input.time;
                        }
                    }
                    g2d_mouseDownNode = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseInput);
                case GMouseInputType.MOUSE_OVER:
                    g2d_mouseOverNode = p_object;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseInput);
                case GMouseInputType.MOUSE_OUT:
                    g2d_mouseOverNode = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseInput);
            }
		}
		if (parent != null) parent.g2d_dispatchMouseCallback(p_type, p_object, p_input);
	}

	private function gotFocus():Void {

	}

	private function lostFocus():Void {

	}
	
	/****************************************************************************************************
	 * 	COMPONENT CODE
	 ****************************************************************************************************/
    private var g2d_renderable:IGRenderable;
    private var g2d_defaultRenderable:GSprite;
	private var g2d_components:Array<GComponent>;
	private var g2d_componentCount:Int = 0;
	
	/**
	 * 	Get a components of specified type attached to this node
	 * 
	 * 	@param p_componentClass Component type that should be retrieved
	 */
	public function getComponent<T:GComponent>(p_componentClass:Class<GComponent>):T {
        // TODO use Lambda
		if (g2d_disposed) GDebug.error("Node already disposed.");
        for (i in 0...g2d_componentCount) {
            var component:T = cast g2d_components[i];
            if (Std.is(component,p_componentClass)) return component;
        }
		return null;
	}

    public function getComponents():Array<GComponent> {
        return g2d_components;
    }

	/**
     *  Has components
     **/
	public function hasComponent(p_componentLookupClass:Class<GComponent>):Bool {
		if (g2d_disposed) GDebug.error("Node already disposed.");
        return getComponent(p_componentLookupClass) != null;
	}
	
	/**
	 * 	Add a components of specified type to this node, node can always have only a single components of a specific class to avoid redundancy
	 * 
	 *	@param p_componentClass Component type that should be instanced and attached to this node
	 */
	public function addComponent<T:GComponent>(p_componentClass:Class<GComponent>):T {
		if (g2d_disposed) GDebug.error("Node already disposed.");


        var lookup:T = getComponent(p_componentClass);
		if (lookup != null) return lookup;

        var component:T = cast Type.createInstance(p_componentClass,[]);
        if (component == null) GDebug.error("Invalid components.");
        component.g2d_node = this;

        if (Std.is(component, GSprite)) {
            g2d_defaultRenderable = cast component;
        } else if (Std.is(component, IGRenderable)) {
            g2d_renderable = cast component;
        }

        if (g2d_components == null) {
            g2d_components = new Array<GComponent>();
        }
		g2d_components.push(component);
		g2d_componentCount++;

        component.init();
		return component;
	}

    public function addComponentPrototype<T:GComponent>(p_prototype:GPrototype):T {
        if (g2d_disposed) GDebug.error("Node already disposed.");

        var component:T = addComponent(cast p_prototype.prototypeClass);

        component.bindPrototype(p_prototype);

        return component;
    }

	
	/**
	 * 	Remove components of specified type from this node
	 * 
	 * 	@param p_componentClass Component type that should be removed
	 */
	public function removeComponent(p_componentClass:Class<GComponent>):Void {
		if (g2d_disposed) GDebug.error("Node already disposed.");
		var component:GComponent = getComponent(p_componentClass);

		if (component == null) return;

        g2d_components.remove(component);
        g2d_componentCount--;

        if (Std.is(component, GSprite)) {
            g2d_defaultRenderable = null;
        } else if (Std.is(component, IGRenderable)) {
            g2d_renderable = null;
        }
		
		component.g2d_dispose();
	}

    public function disposeComponents():Void {
        while (g2d_componentCount>0) {
            g2d_components.pop().g2d_dispose();
            g2d_componentCount--;
        }

        g2d_defaultRenderable = null;
        g2d_renderable = null;
    }
	
	/****************************************************************************************************
	 * 	CONTAINER CODE
	 ****************************************************************************************************/
	private var g2d_firstChild:GNode;
    #if swc @:extern #end
    public var firstChild(get, never):GNode;
    #if swc @:getter(firstChild) #end
    inline private function get_firstChild():GNode {
        return g2d_firstChild;
    }

    private var g2d_lastChild:GNode;
	#if swc @:extern #end
    public var lastChild(get, never):GNode;
    #if swc @:getter(lastChild) #end
    inline private function get_lastChild():GNode {
        return g2d_lastChild;
    }

    private var g2d_next:GNode;
    #if swc @:extern #end
    public var next(get, never):GNode;
    #if swc @:getter(next) #end
    inline private function get_next():GNode {
        return g2d_next;
    }
    private var g2d_previous:GNode;
	#if swc @:extern #end
    public var previous(get, never):GNode;
    #if swc @:getter(previous) #end
    inline private function get_previous():GNode {
        return g2d_previous;
    }

    private var g2d_childCount:Int = 0;
    #if swc @:extern #end
	public var childCount(get, never):Int;
    #if swc @:getter(childCount) #end
    inline private function get_childCount():Int {
        return g2d_childCount;
    }

    private var g2d_onAddedToStage:GCallback0;
    #if swc @:extern #end
    public var onAddedToStage(get, never):GCallback0;
    #if swc @:getter(onAddedToStage) #end
    inline private function get_onAddedToStage():GCallback0 {
        if (g2d_onAddedToStage == null) g2d_onAddedToStage = new GCallback0();
        return g2d_onAddedToStage;
    }

    private var g2d_onRemovedFromStage:GCallback0;
    #if swc @:extern #end
    public var onRemovedFromStage(get, never):GCallback0;
    #if swc @:getter(onRemovedFromStage) #end
    inline private function get_onRemovedFromStage():GCallback0 {
        if (g2d_onRemovedFromStage == null) g2d_onRemovedFromStage = new GCallback0();
        return g2d_onRemovedFromStage;
    }
	
	/**
	 * 	Add a child node to this node
	 * 
	 * 	@param p_child node that should be added
	 */
	public function addChild(p_child:GNode, p_before:GNode = null):GNode {
		if (g2d_disposed) GDebug.error("Node already disposed.");
		if (p_child == this) GDebug.error("Can't add child to itself.");
		if (p_child.parent != null) p_child.parent.removeChild(p_child);
		p_child.g2d_parent = this;
        if (g2d_firstChild == null) {
            g2d_firstChild = p_child;
            g2d_lastChild = p_child;
        } else {
            if (p_before == null) {
                g2d_lastChild.g2d_next = p_child;
                p_child.g2d_previous = g2d_lastChild;
                g2d_lastChild = p_child;
            } else {
                if (p_before != g2d_firstChild) {
                    p_before.g2d_previous.g2d_next = p_child;
                } else {
                    g2d_firstChild = p_child;
                }
                p_child.g2d_previous = p_before.g2d_previous;
                p_child.g2d_next = p_before;
                p_before.g2d_previous = p_child;
            }
        }

		g2d_childCount++;
        if (g2d_childCount == 1 && hasUniformRotation()) g2d_useMatrix++;
		
		if (isOnStage()) p_child.addedToStage();
        return p_child;
	}

    public function addChildAt(p_child:GNode, p_index:Int):GNode {
        if (g2d_disposed) GDebug.error("Node already disposed.");
        if (p_child == this) GDebug.error("Can't add child to itself.");
        if (p_child.parent != null) p_child.parent.removeChild(p_child);

        var i:Int = 0;
        var after:GNode = g2d_firstChild;
        while (i<p_index && after != null) {
            after = after.g2d_next;
            i++;
        }
        return addChild(p_child, (after == null) ? null : after);
    }
	
	public function getChildAt(p_index:Int):GNode {
        if (p_index>=g2d_childCount) GDebug.error("Index out of bounds.");
        var child:GNode = g2d_firstChild;
        for (i in 0...p_index) {
            child = child.g2d_next;
        }
		return child;
	}

    public function getChildIndex(p_child:GNode):Int {
        if (p_child.parent != this) return -1;
        var child:GNode = g2d_firstChild;
        for (i in 0...g2d_childCount) {
            if (child == p_child) return i;
            child = child.g2d_next;
        }
        return -1;
    }

    public function setChildIndex(p_child:GNode, p_index:Int):Void {
        if (p_child.parent != this) GDebug.error("Not a child of this node.");
        if (p_index>=g2d_childCount) GDebug.error("Index out of bounds.");

        var index:Int = 0;
        var child:GNode = g2d_firstChild;
        while (child!=null && index<p_index) {
            child = child.g2d_next;
            index++;
        }
        if (index == p_index && child != p_child) {
            // Remove child from current index
            if (p_child != g2d_lastChild) {
                p_child.g2d_next.g2d_previous = p_child.g2d_previous;
            } else {
                g2d_lastChild = p_child.g2d_previous;
            }
            if (p_child != g2d_firstChild) {
                p_child.g2d_previous.g2d_next = p_child.g2d_next;
            } else {
                g2d_firstChild = p_child.g2d_next;
            }
            // Insert it before the found one
            if (child != g2d_firstChild) {
                child.g2d_previous.g2d_next = p_child;
            } else {
                g2d_firstChild = p_child;
            }
            p_child.g2d_previous = child.g2d_previous;
            p_child.g2d_next = child;
            child.g2d_previous = p_child;
        }
    }

    public function swapChildrenAt(p_index1:Int, p_index2:Int):Void {
        swapChildren(getChildAt(p_index1), getChildAt(p_index2));
    }

    public function swapChildren(p_child1:GNode, p_child2:GNode):Void {
        if (p_child1.parent != this || p_child2.parent != this) return;

        var temp:GNode = p_child1.g2d_next;
        if (p_child2.g2d_next == p_child1) {
            p_child1.g2d_next = p_child2;
        } else {
            p_child1.g2d_next = p_child2.g2d_next;
            if (p_child1.g2d_next != null) p_child1.g2d_next.g2d_previous = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_next = p_child1;
        } else {
            p_child2.g2d_next = temp;
            if (p_child2.g2d_next != null)  p_child2.g2d_next.g2d_previous = p_child2;
        }

        temp = p_child1.g2d_previous;
        if (p_child2.g2d_previous == p_child1) {
            p_child1.g2d_previous = p_child2;
        } else {
            p_child1.g2d_previous = p_child2.g2d_previous;
            if (p_child1.g2d_previous != null)  p_child1.g2d_previous.g2d_next = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_previous = p_child1;
        } else {
            p_child2.g2d_previous = temp;
            if (p_child2.g2d_previous != null) p_child2.g2d_previous.g2d_next = p_child2;
        }

        if (p_child1 == g2d_firstChild) g2d_firstChild = p_child2;
        else if (p_child2 == g2d_firstChild) g2d_firstChild = p_child1;
        if (p_child1 == g2d_lastChild) g2d_lastChild = p_child2;
        else if (p_child2 == g2d_lastChild) g2d_lastChild = p_child1;
    }

    public function putChildToFront(p_child:GNode):Void {
        if (p_child.parent != this || p_child == g2d_lastChild) return;

        if (p_child.g2d_next != null) p_child.g2d_next.g2d_previous = p_child.g2d_previous;
        if (p_child.g2d_previous != null) p_child.g2d_previous.g2d_next = p_child.g2d_next;
        if (p_child == g2d_firstChild) g2d_firstChild = g2d_firstChild.g2d_next;

        if (g2d_lastChild != null) g2d_lastChild.g2d_next = p_child;
        p_child.g2d_previous = g2d_lastChild;
        p_child.g2d_next = null;
        g2d_lastChild = p_child;
    }

    public function putChildToBack(p_child:GNode):Void {
        if (p_child.parent != this || p_child == g2d_firstChild) return;

        if (p_child.g2d_next != null) p_child.g2d_next.g2d_previous = p_child.g2d_previous;
        if (p_child.g2d_previous != null) p_child.g2d_previous.g2d_next = p_child.g2d_next;
        if (p_child == g2d_lastChild) g2d_lastChild = g2d_lastChild.g2d_previous;

        if (g2d_firstChild != null) g2d_firstChild.g2d_previous = p_child;
        p_child.g2d_previous = null;
        p_child.g2d_next = g2d_firstChild;
        g2d_firstChild = p_child;
    }

	/**
	 * 	Remove a child node from this node
	 * 
	 * 	@param p_child node that should be removed
	 */
	public function removeChild(p_child:GNode):GNode {
		if (g2d_disposed) GDebug.error("Node already disposed.");
		if (p_child.parent != this) return null;

		if (p_child.g2d_previous != null) {
            p_child.g2d_previous.g2d_next = p_child.g2d_next;
        } else {
            g2d_firstChild = g2d_firstChild.g2d_next;
        }
        if (p_child.g2d_next != null) {
            p_child.g2d_next.g2d_previous = p_child.g2d_previous;
        } else {
            g2d_lastChild = g2d_lastChild.g2d_previous;
        }

        p_child.g2d_next = p_child.g2d_previous = p_child.g2d_parent = null;
		
		g2d_childCount--;
        if (g2d_childCount == 0 && hasUniformRotation()) g2d_useMatrix--;

		if (isOnStage()) p_child.removedFromStage();
        return p_child;
	}

	public function removeChildAt(p_index:Int):GNode {
        if (p_index>=g2d_childCount) GDebug.error("Index out of bounds.");
        var index:Int = 0;
        var child:GNode = g2d_firstChild;
		while (child != null && index<p_index) {
            child = child.g2d_next;
            index++;
        }

        return removeChild(child);
	}

    /**
	 * 	This method will call dispose on all children of this node which will remove them
	 */
    public function disposeChildren():Void {
        while (g2d_firstChild != null) {
            g2d_firstChild.dispose();
        }
    }
	
	public function callOnChild(p_function:GNode->Void):Void {
		var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_next;
			p_function(child);
            child = next;
		}
	}

	inline private function addedToStage():Void {
		if (g2d_onAddedToStage != null) g2d_onAddedToStage.dispatch();
        GStats.nodeCount++;

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_next;
			child.addedToStage();
            child = next;
		}
	}

	inline private function removedFromStage():Void {
		if (g2d_onRemovedFromStage != null) g2d_onRemovedFromStage.dispatch();
        GStats.nodeCount--;

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_next;
			child.removedFromStage();
            child = next;
		}
	}
	
	/**
	 * 	Returns true if this node is attached to Genome2D render tree false otherwise
	 */
	public function isOnStage():Bool {
		if (this == core.root) {
            return true;
        } else if (parent == null) {
            return false;
        } else {
            return parent.isOnStage();
        }
	}

    public function getBounds(p_targetSpace:GNode = null, p_bounds:GRectangle = null):GRectangle {
        if (p_targetSpace == null) p_targetSpace = core.root;
        if (p_bounds == null) p_bounds = new GRectangle();
        var found:Bool = false;
        // Reverted back to using constants as Math.POSITIVE_INFINITY/NEGATIVE_INFINITY doesn't work well with SWC target
        var minX:Float = 10000000;
        var maxX:Float = -10000000;
        var minY:Float = 10000000;
        var maxY:Float = -10000000;
        var aabb:GRectangle = new GRectangle(0,0,0,0);

        if (g2d_defaultRenderable != null) {
            g2d_defaultRenderable.getBounds(aabb);
        } else if (g2d_renderable != null) {
            g2d_renderable.getBounds(aabb);
        }
		
        if (aabb.width != 0 && aabb.height != 0) {
            var m:GMatrix = getTransformationMatrix(p_targetSpace, g2d_cachedMatrix);

            var tx1:Float = g2d_cachedMatrix.a * aabb.x + g2d_cachedMatrix.c * aabb.y + g2d_cachedMatrix.tx;
            var ty1:Float = g2d_cachedMatrix.d * aabb.y + g2d_cachedMatrix.b * aabb.x + g2d_cachedMatrix.ty;
            var tx2:Float = g2d_cachedMatrix.a * aabb.x + g2d_cachedMatrix.c * aabb.bottom + g2d_cachedMatrix.tx;
            var ty2:Float = g2d_cachedMatrix.d * aabb.bottom + g2d_cachedMatrix.b * aabb.x + g2d_cachedMatrix.ty;
            var tx3:Float = g2d_cachedMatrix.a * aabb.right + g2d_cachedMatrix.c * aabb.y + g2d_cachedMatrix.tx;
            var ty3:Float = g2d_cachedMatrix.d * aabb.y + g2d_cachedMatrix.b * aabb.right + g2d_cachedMatrix.ty;
            var tx4:Float = g2d_cachedMatrix.a * aabb.right + g2d_cachedMatrix.c * aabb.bottom + g2d_cachedMatrix.tx;
            var ty4:Float = g2d_cachedMatrix.d * aabb.bottom + g2d_cachedMatrix.b * aabb.right + g2d_cachedMatrix.ty;
            if (minX > tx1) minX = tx1; if (minX > tx2) minX = tx2; if (minX > tx3) minX = tx3; if (minX > tx4) minX = tx4;
            if (minY > ty1) minY = ty1; if (minY > ty2) minY = ty2; if (minY > ty3) minY = ty3; if (minY > ty4) minY = ty4;
            if (maxX < tx1) maxX = tx1; if (maxX < tx2) maxX = tx2; if (maxX < tx3) maxX = tx3; if (maxX < tx4) maxX = tx4;
            if (maxY < ty1) maxY = ty1; if (maxY < ty2) maxY = ty2; if (maxY < ty3) maxY = ty3; if (maxY < ty4) maxY = ty4;

            found = true;
        }

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_next;
            child.getBounds(p_targetSpace, aabb);
            if (aabb.width == 0 || aabb.height == 0) {
                child = next;
                continue;
            }
            if (minX > aabb.x) minX = aabb.x;
            if (maxX < aabb.right) maxX = aabb.right;
            if (minY > aabb.y) minY = aabb.y;
            if (maxY < aabb.bottom) maxY = aabb.bottom;

            found = true;
            child = next;
        }

        if (found) p_bounds.setTo(minX, minY, maxX-minX, maxY-minY);

        return p_bounds;
    }

    inline public function getCommonParent(p_node:GNode):GNode {
        // Store this hierarchy
        var current:GNode = this;
        // TODO optimize for targets where length = 0 is possible?
        g2d_cachedArray = [];
        while (current != null) {
            g2d_cachedArray.push(current);
            current = current.parent;
        }

        // Iterate from target to common
        current = p_node;
        while (current!=null && Lambda.indexOf(g2d_cachedArray, current) == -1) {
            current = current.parent;
        }

        return current;
    }

    public function sortChildren(p_nodeSorter:IGNodeSorter, p_ascending:Bool = true):Void {
        if (g2d_firstChild == null) return;

        var insize:Int = 1;
        var psize:Int;
        var qsize:Int;
        var nmerges:Int;
        var p:GNode;
        var q:GNode;
        var e:GNode;

        while (true) {
            p = g2d_firstChild;
            g2d_firstChild = null;
            g2d_lastChild = null;

            nmerges = 0;

            while (p != null) {
                nmerges++;
                q = p;
                psize = 0;
                for (i in 0...insize) {
                    psize++;
                    q = q.g2d_next;
                    if (q == null) break;
                }

                qsize = insize;

                while (psize > 0 || (qsize > 0 && q != null)) {
                    if (psize == 0) {
                        e = q;
                        q = q.g2d_next;
                        qsize--;
                    } else if (qsize == 0 || q == null) {
                        e = p;
                        p = p.g2d_next;
                        psize--;
                    } else if (p_ascending) {
                        if (p_nodeSorter.getSortValue(p) >= p_nodeSorter.getSortValue(q)) {
                            e = p;
                            p = p.g2d_next;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_next;
                            qsize--;
                        }
                    } else {
                        if (p_nodeSorter.getSortValue(p) <= p_nodeSorter.getSortValue(q)) {
                            e = p;
                            p = p.g2d_next;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_next;
                            qsize--;
                        }
                    }

                    if (g2d_lastChild != null) {
                        g2d_lastChild.g2d_next = e;
                    } else {
                        g2d_firstChild = e;
                    }

                    e.g2d_previous = g2d_lastChild;

                    g2d_lastChild = e;
                }

                p = q;
            }

            g2d_lastChild.g2d_next = null;

            if (nmerges <= 1) return;

            insize *= 2;
        }
    }

    public function sortChildrenOnY(p_ascending:Bool = true):Void {
        if (g2d_firstChild == null) return;

        var insize:Int = 1;
        var psize:Int;
        var qsize:Int;
        var nmerges:Int;
        var p:GNode;
        var q:GNode;
        var e:GNode;

        while (true) {
            p = g2d_firstChild;
            g2d_firstChild = null;
            g2d_lastChild = null;

            nmerges = 0;

            while (p != null) {
                nmerges++;
                q = p;
                psize = 0;
                for (i in 0...insize) {
                    psize++;
                    q = q.g2d_next;
                    if (q == null) break;
                }

                qsize = insize;

                while (psize > 0 || (qsize > 0 && q != null)) {
                    if (psize == 0) {
                        e = q;
                        q = q.g2d_next;
                        qsize--;
                    } else if (qsize == 0 || q == null) {
                        e = p;
                        p = p.g2d_next;
                        psize--;
                    } else if (p_ascending) {
                        if (p.y >= q.y) {
                            e = p;
                            p = p.g2d_next;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_next;
                            qsize--;
                        }
                    } else {
                        if (p.y <= q.y) {
                            e = p;
                            p = p.g2d_next;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_next;
                            qsize--;
                        }
                    }

                    if (g2d_lastChild != null) {
                        g2d_lastChild.g2d_next = e;
                    } else {
                        g2d_firstChild = e;
                    }

                    e.g2d_previous = g2d_lastChild;

                    g2d_lastChild = e;
                }

                p = q;
            }

            g2d_lastChild.g2d_next = null;

            if (nmerges <= 1) return;

            insize *= 2;
        }
    }

    public function toString():String {
        return "[GNode "+name+"]";
    }

    /****************************************************************************************************
	 * 	TRANSFORM
	 ****************************************************************************************************/

    static private var g2d_cachedTransformMatrix:GMatrix;

    private var g2d_matrixDirty:Bool = true;
    private var g2d_transformDirty:Bool = false;

    private var g2d_colorDirty:Bool = false;

	@category("transform")
    @prototype
	public var useWorldSpace:Bool = false;

	@category("color")
    @prototype
	public var useWorldColor:Bool = false;

    public var visible:Bool = true;

    @:dox(hide)
    public var g2d_worldX:Float = 0;
    private var g2d_localX:Float = 0;
    #if swc @:extern #end
	@category("transform")
    @prototype
	public var x(get, set):Float;
    #if swc @:getter(x) #end
    inline private function get_x():Float {
        return g2d_localX;
    }
    #if swc @:setter(x) #end
    inline private function set_x(p_value:Float):Float {
        g2d_transformDirty = g2d_matrixDirty = true;
        return g2d_localX = g2d_worldX = p_value;
    }

    @:dox(hide)
    public var g2d_worldY:Float = 0;
    private var g2d_localY:Float = 0;
    #if swc @:extern #end
	@category("transform")
    @prototype
	public var y(get, set):Float;
    #if swc @:getter(y) #end
    inline private function get_y():Float {
        return g2d_localY;
    }
    #if swc @:setter(y) #end
    inline private function set_y(p_value:Float):Float {
        g2d_transformDirty = g2d_matrixDirty = true;
        return g2d_localY = g2d_worldY = p_value;
    }

    inline public function hasUniformRotation():Bool {
        return (g2d_localScaleX != g2d_localScaleY && g2d_localRotation != 0);
    }
    private var g2d_localUseMatrix:Int = 0;

    public var g2d_useMatrix(get, set):Int;
    inline private function get_g2d_useMatrix():Int {
        return g2d_localUseMatrix;
    }
    inline private function set_g2d_useMatrix(p_value:Int):Int {
        if (g2d_parent != null) g2d_parent.g2d_useMatrix += p_value-g2d_useMatrix;
        g2d_localUseMatrix = p_value;
        return g2d_useMatrix;
    }

    @:dox(hide)
    public var g2d_worldScaleX:Float = 1;
    private var g2d_localScaleX:Float = 1;
    #if swc @:extern #end
	@category("transform")
	@range(0,0,.01)
    @prototype
	public var scaleX(get, set):Float;
    #if swc @:getter(scaleX) #end
    inline private function get_scaleX():Float {
        return g2d_localScaleX;
    }
    #if swc @:setter(scaleX) #end
    inline private function set_scaleX(p_value:Float):Float {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleY && g2d_localRotation != 0 && g2d_childCount>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleY && g2d_localRotation != 0 && g2d_childCount>0) g2d_useMatrix--;

        g2d_transformDirty = g2d_matrixDirty = true;
        return g2d_localScaleX = g2d_worldScaleX = p_value;
    }

    @:dox(hide)
    public var g2d_worldScaleY:Float = 1;
    private var g2d_localScaleY:Float = 1;
    #if swc @:extern #end
	@category("transform")
	@range(0,0,.01)
    @prototype
	public var scaleY(get, set):Float;
    #if swc @:getter(scaleY) #end
    inline private function get_scaleY():Float {
        return g2d_localScaleY;
    }
    #if swc @:setter(scaleY) #end
    inline private function set_scaleY(p_value:Float):Float {
        if (g2d_localScaleX == g2d_localScaleY && p_value != g2d_localScaleX && g2d_localRotation != 0 && g2d_childCount>0) g2d_useMatrix++;
        if (g2d_localScaleX == g2d_localScaleY && p_value == g2d_localScaleX && g2d_localRotation != 0 && g2d_childCount>0) g2d_useMatrix--;

        g2d_transformDirty = g2d_matrixDirty = true;
        return g2d_localScaleY = g2d_worldScaleY = p_value;
    }

    @:dox(hide)
    public var g2d_worldRotation:Float = 0;
    private var g2d_localRotation:Float = 0;
    #if swc @:extern #end
	@category("transform")
	@range(0,0,.01)
    @prototype
	public var rotation(get, set):Float;
    #if swc @:getter(rotation) #end
    inline private function get_rotation():Float {
        return g2d_localRotation;
    }
    #if swc @:setter(rotation) #end
    inline private function set_rotation(p_value:Float):Float {
        if (g2d_localRotation == 0 && p_value != 0 && g2d_localScaleX != g2d_localScaleY && g2d_childCount>0) g2d_useMatrix++;
        if (g2d_localRotation != 0 && p_value == 0 && g2d_localScaleX != g2d_localScaleY && g2d_childCount>0) g2d_useMatrix--;

        g2d_transformDirty = g2d_matrixDirty = true;
        return g2d_localRotation = g2d_worldRotation = p_value;
    }

    @:dox(hide)
    public var g2d_worldRed:Float = 1;
    private var g2d_localRed:Float = 1;
    #if swc @:extern #end
	public var red(get, set):Float;
    #if swc @:getter(red) #end
    inline private function get_red():Float {
        return g2d_localRed;
    }
    #if swc @:setter(red) #end
    inline private function set_red(p_value:Float):Float {
        g2d_colorDirty = true;
        return g2d_localRed = g2d_worldRed = p_value;
    }

    @:dox(hide)
    public var g2d_worldGreen:Float = 1;
    private var g2d_localGreen:Float = 1;
    #if swc @:extern #end
	public var green(get, set):Float;
    #if swc @:getter(green) #end
    inline private function get_green():Float {
        return g2d_localGreen;
    }
    #if swc @:setter(green) #end
    inline private function set_green(p_value:Float):Float {
        g2d_colorDirty = true;
        return g2d_localGreen = g2d_worldGreen = p_value;
    }

    @:dox(hide)
    public var g2d_worldBlue:Float = 1;
    private var g2d_localBlue:Float = 1;
    #if swc @:extern #end
	public var blue(get, set):Float;
    #if swc @:getter(blue) #end
    inline private function get_blue():Float {
        return g2d_localBlue;
    }
    #if swc @:setter(blue) #end
    inline private function set_blue(p_value:Float):Float {
        g2d_colorDirty = true;
        return g2d_localBlue = g2d_worldBlue = p_value;
    }

    @:dox(hide)
    public var g2d_worldAlpha:Float = 1;
    private var g2d_localAlpha:Float = 1;
    #if swc @:extern #end
	@category("color")
	@range(0,1,.01)
    @prototype
	public var alpha(get, set):Float;
    #if swc @:getter(alpha) #end
    inline private function get_alpha():Float {
        return g2d_localAlpha;
    }
    #if swc @:setter(alpha) #end
    inline private function set_alpha(p_value:Float):Float {
        g2d_colorDirty = true;
        return g2d_localAlpha = g2d_worldAlpha = p_value;
    }

	@category("color")
	@type("color")
	@prototype
    #if swc @:extern #end
    public var color(get, set):Int;
	#if swc @:getter(color) #end
	inline private function get_color():Int {
		var red:Int = Std.int(red * 0xFF) << 16;
		var green:Int = Std.int(green * 0xFF) << 8;
		var blue:Int = Std.int(blue * 0xFF);
		return red+green+blue;
	}
    #if swc @:setter(color) #end
    inline private function set_color(p_value:Int):Int {
        red = (p_value >> 16 & 0xFF) / 0xFF;
        green = (p_value >> 8 & 0xFF) / 0xFF;
        blue = (p_value & 0xFF) / 0xFF;
        return p_value;
    }

    private var g2d_matrix:GMatrix;
    #if swc @:extern #end
    public var matrix(get, never):GMatrix;
    #if swc @:getter(matrix) #end
    inline private function get_matrix():GMatrix {
        if (g2d_matrixDirty) {
            if (g2d_matrix == null) g2d_matrix = new GMatrix();
            if (g2d_localRotation == 0.0) {
                g2d_matrix.setTo(g2d_localScaleX, 0.0, 0.0, g2d_localScaleY, g2d_localX, g2d_localY);
            } else {
                var cos:Float = Math.cos(g2d_localRotation);
                var sin:Float = Math.sin(g2d_localRotation);
                var a:Float = g2d_localScaleX * cos;
                var b:Float = g2d_localScaleX * sin;
                var c:Float = g2d_localScaleY * -sin;
                var d:Float = g2d_localScaleY * cos;
                var tx:Float = g2d_localX;
                var ty:Float = g2d_localY;

                g2d_matrix.setTo(a, b, c, d, tx, ty);
            }

            g2d_matrixDirty = false;
        }

        return g2d_matrix;
    }

    public function getTransformationMatrix(p_targetSpace:GNode, p_resultMatrix:GMatrix = null):GMatrix {
        if (p_resultMatrix == null) {
            p_resultMatrix = new GMatrix();
        } else {
            p_resultMatrix.identity();
        }

        if (p_targetSpace == g2d_parent) {
            p_resultMatrix.copyFrom(matrix);
        } else if (p_targetSpace != this) {
            var common:GNode = getCommonParent(p_targetSpace);
            if (common != null) {
                var current:GNode = this;
                while (common != current) {
                    p_resultMatrix.concat(current.matrix);
                    current = current.parent;
                }
                // If its not in parent hierarchy we need to continue down the target
                if (common != p_targetSpace) {
                    g2d_cachedTransformMatrix.identity();
                    while (p_targetSpace != common) {
                        g2d_cachedTransformMatrix.concat(p_targetSpace.matrix);
                        p_targetSpace = p_targetSpace.parent;
                    }
                    g2d_cachedTransformMatrix.invert();
                    p_resultMatrix.concat(g2d_cachedTransformMatrix);
                }
            }
        }

        return p_resultMatrix;
    }

    public function localToGlobal(p_local:GPoint, p_result:GPoint = null):GPoint {
        getTransformationMatrix(g2d_core.g2d_root, g2d_cachedTransformMatrix);
        if (p_result == null) p_result = new GPoint();
        p_result.x = g2d_cachedTransformMatrix.a * p_local.x + g2d_cachedTransformMatrix.c * p_local.y + g2d_cachedTransformMatrix.tx;
        p_result.y = g2d_cachedTransformMatrix.d * p_local.y + g2d_cachedTransformMatrix.b * p_local.x + g2d_cachedTransformMatrix.ty;
        return p_result;
    }

    public function globalToLocal(p_global:GPoint, p_result:GPoint = null):GPoint {
        getTransformationMatrix(g2d_core.g2d_root, g2d_cachedTransformMatrix);
        g2d_cachedTransformMatrix.invert();
        if (p_result == null) p_result = new GPoint();
        p_result.x = g2d_cachedTransformMatrix.a * p_global.x + g2d_cachedTransformMatrix.c * p_global.y + g2d_cachedTransformMatrix.tx;
        p_result.y = g2d_cachedTransformMatrix.d * p_global.y + g2d_cachedTransformMatrix.b * p_global.x + g2d_cachedTransformMatrix.ty;
        return p_result;
    }

    public function setPosition(p_x:Float, p_y:Float):Void {
        g2d_transformDirty = g2d_matrixDirty = true;
        g2d_localX = g2d_worldX = p_x;
        g2d_localY = g2d_worldY = p_y;
    }

    public function setScale(p_scaleX:Float, p_scaleY:Float):Void {
        g2d_transformDirty = g2d_matrixDirty = true;
        g2d_localScaleX = g2d_worldScaleX = p_scaleX;
        g2d_localScaleY = g2d_worldScaleY = p_scaleY;
    }

    inline private function invalidateTransform(p_invalidateParentTransform:Bool):Void {
        if (p_invalidateParentTransform && !useWorldSpace) {
            if (g2d_parent.g2d_worldRotation != 0) {
                var cos:Float = Math.cos(g2d_parent.g2d_worldRotation);
                var sin:Float = Math.sin(g2d_parent.g2d_worldRotation);

                g2d_worldX = (x * cos - y * sin) * g2d_parent.g2d_worldScaleX + g2d_parent.g2d_worldX;
                g2d_worldY = (y * cos + x * sin) * g2d_parent.g2d_worldScaleY + g2d_parent.g2d_worldY;
            } else {
                g2d_worldX = g2d_localX * g2d_parent.g2d_worldScaleX + g2d_parent.g2d_worldX;
                g2d_worldY = g2d_localY * g2d_parent.g2d_worldScaleY + g2d_parent.g2d_worldY;
            }

            g2d_worldScaleX = g2d_localScaleX * g2d_parent.g2d_worldScaleX;
            g2d_worldScaleY = g2d_localScaleY * g2d_parent.g2d_worldScaleY;
            g2d_worldRotation = g2d_localRotation + g2d_parent.g2d_worldRotation;

            g2d_transformDirty = false;
        }
	}

	inline private function invalidateColor(p_invalidateParentColor:Bool):Void {
        if (p_invalidateParentColor && !useWorldColor) {
            g2d_worldRed = g2d_localRed * g2d_parent.g2d_worldRed;
            g2d_worldGreen = g2d_localGreen * g2d_parent.g2d_worldGreen;
            g2d_worldBlue = g2d_localBlue * g2d_parent.g2d_worldBlue;
            g2d_worldAlpha = g2d_localAlpha * g2d_parent.g2d_worldAlpha;

            g2d_colorDirty = false;
        }
    }

    /****************************************************************************************************
	 * 	RENDER
	 ****************************************************************************************************/

    @:dox(hide)
    public function render(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GCamera, p_renderAsMask:Bool, p_useMatrix:Bool):Void {
        if (g2d_active) {
            // Transform invalidation
            var doInvalidateTransform:Bool = p_parentTransformUpdate || g2d_transformDirty;
            var doInvalidateColor:Bool = p_parentColorUpdate || g2d_colorDirty;

            if (doInvalidateTransform) {
				invalidateTransform(p_parentTransformUpdate);
			}

			if (doInvalidateColor) {
                invalidateColor(p_parentColorUpdate);
            }

            if (g2d_active && visible && ((cameraGroup & p_camera.group) != 0 || cameraGroup == 0) && (g2d_usedAsMask == 0 || p_renderAsMask)) {
				// Rectangle masking
				var hasMask:Bool = false;
				var previousMask:GRectangle = null;
				if (maskRect != null && ((maskRect != parent.maskRect) || (parent.maskRect != null && (maskRect.width != parent.maskRect.width || maskRect.height != parent.maskRect.height && maskRect.x != parent.maskRect.x || maskRect.y != parent.maskRect.y)))) {
					hasMask = true;
					previousMask = core.getContext().getMaskRect();
					var intersection:GRectangle = previousMask == null ? maskRect : maskRect.intersection(previousMask);
					//if (intersection.width <= 0 || intersection.height <= 0) return;
					core.getContext().setMaskRect(intersection);
				}

                // Node masking
                if (!p_renderAsMask && mask != null) {
                    core.getContext().renderToStencil(g2d_activeMasks.length);
                    mask.render(true, false, p_camera, true, false);
                    g2d_activeMasks.push(mask);
                    core.getContext().renderToColor(g2d_activeMasks.length);
                }

                // Matrix
                var useMatrix:Bool = p_useMatrix || g2d_useMatrix > 0;

                if (useMatrix) {
                    if (core.g2d_renderMatrixArray.length<=core.g2d_renderMatrixIndex) core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex] = new GMatrix();
                    core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex].copyFrom(core.g2d_renderMatrix);
                    GMatrixUtils.prependMatrix(core.g2d_renderMatrix, matrix);
                    core.g2d_renderMatrixIndex++;
                }

				// Render renderable component
                if (g2d_defaultRenderable != null) {
                    g2d_defaultRenderable.render(p_camera, useMatrix);
                } else if (g2d_renderable != null) {
                    g2d_renderable.render(p_camera, useMatrix);
                }

                // Render children
                var child:GNode = g2d_firstChild;
                while (child != null) {
                    var next:GNode = child.g2d_next;
                    if (child.postProcess != null) {
                        child.postProcess.renderNode(doInvalidateTransform, doInvalidateColor, p_camera, child);
                    } else {
                        child.render(doInvalidateTransform, doInvalidateColor, p_camera, p_renderAsMask, useMatrix);
                    }
                    child = next;
                }

                //  Rectangle Masking
                if (hasMask) {
                    core.getContext().setMaskRect(previousMask);
                }

				// Node masking
                if (!p_renderAsMask && mask != null) {
                    g2d_activeMasks.pop();
                    if (g2d_activeMasks.length==0) core.getContext().clearStencil();
                    core.getContext().renderToColor(g2d_activeMasks.length);
                }

                // Use matrix
                if (useMatrix) {
                    core.g2d_renderMatrixIndex--;
                    core.g2d_renderMatrix.copyFrom(core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex]);
                }
            }
        }
    }
}