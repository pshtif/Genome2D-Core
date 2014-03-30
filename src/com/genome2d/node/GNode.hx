/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.node;

import com.genome2d.context.GContextFeature;
import com.genome2d.context.IContext;
import com.genome2d.context.stats.GStats;
import com.genome2d.Genome2D;
import com.genome2d.geom.GRectangle;
import com.genome2d.postprocesses.GPostProcess;
import com.genome2d.geom.GMatrix;
import com.genome2d.geom.GMatrixUtils;
import com.genome2d.geom.GMatrix;
import com.genome2d.components.GTransform;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.signals.GNodeMouseSignal;
import com.genome2d.physics.GBody;
import com.genome2d.utils.GMap.GMap;
import com.genome2d.utils.IGProps;
import msignal.Signal;
import com.genome2d.components.GComponent;
import com.genome2d.components.GTransform;
import com.genome2d.error.GError;
import com.genome2d.signals.GMouseSignal;

class GNode implements IGProps
{
    static private var g2d_cachedArray:Array<GNode>;
    static private var g2d_cachedMatrix:GMatrix;
    static private var g2d_activeMasks:Array<GNode>;

    static private var g2d_core:Genome2D;

	@prop var core:Genome2D = {
		get: {  
			if (g2d_core == null) g2d_core = Genome2D.getInstance();
			return g2d_core;
		}
	}
	
	/**
	 * 	Camera group this node belongs to, a node is rendered through this camera if camera.mask&node.cameraGroup != 0
	 */
	public var cameraGroup:Int = 0;

	public var g2d_pool:GNodePool;
	public var g2d_poolNext:GNode;
	public var g2d_poolPrevious:GNode;


    public var maskRect:GRectangle;

    private var g2d_usedAsMask:Int = 0;
    private var g2d_mask:GNode;
	@prop var mask:GNode = {
		get: return g2d_mask,
		set: {
			if (!core.getContext().hasFeature(GContextFeature.STENCIL_MASKING)) new GError("Stencil masking feature not supported.");
			if (g2d_mask != null) g2d_mask.g2d_usedAsMask--;
			g2d_mask = p_value;
			g2d_mask.g2d_usedAsMask++;
		}
    }
	
	/**
	 * 	Abstract reference to user defined data, if you want keep some custom data binded to G2DNode instance use it.
	 */
	private var g2d_userData:GMap<String, Dynamic>;
	@prop var userData:GMap<String, Dynamic> = {
		get: { 
			if (g2d_userData == null) g2d_userData = new GMap<String,Dynamic>();
			return g2d_userData;
		}
	}

	private var g2d_active:Bool = true;

	inline public function isActive():Bool {
        return g2d_active;
	}

	public function setActive(p_value:Bool):Void {
		if (p_value != g2d_active) {
			if (g2d_disposed) throw new GError();
			
			g2d_active = p_value;
			g2d_transform.setActive(g2d_active);
			
			if (g2d_pool != null) {
				if (p_value) {
                    g2d_pool.g2d_putToBack(this);
                } else {
                    g2d_pool.g2d_putToFront(this);
                }
			}
			
			//if (g2d_body != null) g2d_body.setActive(g2d_active);

            for (i in 0...g2d_numComponents) {
                g2d_components[i].setActive(p_value);
            }

            var child:GNode = g2d_firstChild;
            while (child != null) {
                var next:GNode = child.g2d_nextNode;
                child.setActive(p_value);
                child = next;
            }
		}
	}
    /**/

    /**
     *  Internal node id
     **/
	private var g2d_id:Int;
    @prop var id:Int = {
		get: return g2d_id
    }

	/**
	 * 	Node name
	 */
	public var name:String;

    // Node transform
	private var g2d_transform:GTransform;
	@prop var transform:GTransform = {
		get: return g2d_transform
	}

    public var postProcess:GPostProcess;

    // Node parent
	private var g2d_parent:GNode;
	@prop var parent:GNode = {
		get: return g2d_parent
	}

    // Physics body
	public var g2d_body:GBody;

	private var g2d_disposed:Bool = false;

    // Internal node count
	static private var g2d_nodeCount:Int = 0;
	/**
	 * 	Constructor
	 */
	public function new(p_name:String = "") {
		g2d_id = g2d_nodeCount++;
		name = (p_name == "") ? "GNode#"+g2d_id : p_name;
        // Create cached instances
        if (g2d_cachedMatrix == null)  {
            g2d_cachedMatrix = new GMatrix();
            g2d_activeMasks = new Array<GNode>();
        }

        g2d_transform = new GTransform(this);
        g2d_transform.g2d_lookupClass = GTransform;
	}
	/**
	 * 	@private
	 */
	public function render(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GContextCamera, p_renderAsMask:Bool, p_useMatrix:Bool):Void {
		if (g2d_active) {
            var context:IContext = core.getContext();
            var previousMaskRect:GRectangle = null;
            var hasMask:Bool = false;
            if (maskRect != null && maskRect != parent.maskRect) {
                hasMask = true;
                previousMaskRect = (context.getMaskRect() == null) ? null : context.getMaskRect().clone();
                if (parent.maskRect!=null) {
                    var intersection:GRectangle = parent.maskRect.intersection(maskRect);
                    context.setMaskRect(intersection);
                } else {
                    context.setMaskRect(maskRect);
                }
            }

            var invalidateTransform:Bool = p_parentTransformUpdate || transform.g2d_transformDirty;
            var invalidateColor:Bool = p_parentColorUpdate || transform.g2d_colorDirty;

            if (invalidateTransform || invalidateColor || (g2d_body != null && g2d_body.isDynamic())) {
                transform.invalidate(p_parentTransformUpdate, p_parentColorUpdate);
            }

            //if (g2d_body != null) g2d_body.update(p_deltaTime, invalidateTransform, invalidateColor);

            if (!g2d_active || !transform.visible || ((cameraGroup&p_camera.mask) == 0 && cameraGroup != 0) || (g2d_usedAsMask>0 && !p_renderAsMask)) return;

            if (!p_renderAsMask) {
                if (mask != null) {
                    context.renderToStencil(g2d_activeMasks.length);
                    mask.render(true, false, p_camera, true, false);
                    g2d_activeMasks.push(mask);
                    context.renderToColor(g2d_activeMasks.length);
                }
            }

            // Use matrix
            var useMatrix:Bool = p_useMatrix || transform.g2d_useMatrix > 0;
            if (useMatrix) {
                if (core.g2d_renderMatrixArray.length<=core.g2d_renderMatrixIndex) core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex] = new GMatrix();
                core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex].copyFrom(core.g2d_renderMatrix);
                GMatrixUtils.prependMatrix(core.g2d_renderMatrix, transform.matrix);
                core.g2d_renderMatrixIndex++;
            }

            if (g2d_renderable != null) {
                g2d_renderable.render(p_camera, useMatrix);
            }

            var child:GNode = g2d_firstChild;
            while (child != null) {
                var next:GNode = child.g2d_nextNode;
                if (child.postProcess != null) {
                    child.postProcess.render(invalidateTransform, invalidateColor, p_camera, child);
                } else {
                    child.render(invalidateTransform, invalidateColor, p_camera, p_renderAsMask, useMatrix);
                }
                child = next;
            }

            if (hasMask) {
                context.setMaskRect(previousMaskRect);
            }

            if (!p_renderAsMask) {
                if (mask != null) {
                    g2d_activeMasks.pop();
                    if (g2d_activeMasks.length==0) context.clearStencil();
                    context.renderToColor(g2d_activeMasks.length);
                }
            }

            // Use matrix
            if (useMatrix) {
                core.g2d_renderMatrixIndex--;
                core.g2d_renderMatrix.copyFrom(core.g2d_renderMatrixArray[core.g2d_renderMatrixIndex]);
            }
        }
	}
	
	/**
	 * 	This method disposes this node, this will also dispose all of its children, components and signals
	 */
	public function dispose():Void {
		if (g2d_disposed) return;
		
		disposeChildren();

        while (g2d_numComponents>0) {
            g2d_components.pop().dispose();
            g2d_numComponents--;
        }
		
		g2d_body = null;
		g2d_transform = null;
		
		if (parent != null) {
			parent.removeChild(this);
		}
		
		g2d_disposed = true;
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/
	
	public function getPrototype():Xml {
		if (g2d_disposed) new GError("Node already disposed.");

		var prototypeXml:Xml = Xml.parse("<node/>").firstElement();
		prototypeXml.set("name", name);
		prototypeXml.set("mouseEnabled", Std.string(mouseEnabled));
		prototypeXml.set("mouseChildren", Std.string(mouseChildren));
		
		var componentsXml:Xml = Xml.parse("<components/>").firstElement();
		componentsXml.addChild(transform.getPrototype());

		if (g2d_body != null) componentsXml.addChild(g2d_body.getPrototype());

		for (i in 0...g2d_numComponents) {
			componentsXml.addChild(g2d_components[i].getPrototype());
		}
		prototypeXml.addChild(componentsXml);

		var childrenXml:Xml = Xml.parse("<children/>").firstElement();

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
			childrenXml.addChild(child.getPrototype());
            child = next;
		}
		
		prototypeXml.addChild(childrenXml);
		
		return prototypeXml;
	}

	/****************************************************************************************************
	 * 	MOUSE CODE
	 ****************************************************************************************************/
	public var mouseChildren:Bool = true;
	public var mouseEnabled:Bool = false;
	
	// Mouse signals
	private var g2d_onMouseDown:Signal1<GNodeMouseSignal>;
    @prop var onMouseDown:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseDown == null) g2d_onMouseDown = new Signal1(GMouseSignal);
			return g2d_onMouseDown;
		}
	}
	private var g2d_onMouseMove:Signal1<GNodeMouseSignal>;
    @prop var onMouseMove:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseMove == null) g2d_onMouseMove = new Signal1(GMouseSignal);
			return g2d_onMouseMove;
		}
	}
	private var g2d_onMouseClick:Signal1<GNodeMouseSignal>;
    @prop var onMouseClick:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseClick == null) g2d_onMouseClick = new Signal1(GMouseSignal);
			return g2d_onMouseClick;
		}
	}
	private var g2d_onMouseUp:Signal1<GNodeMouseSignal>;
	@prop var onMouseUp:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseUp == null) g2d_onMouseUp = new Signal1(GMouseSignal);
			return g2d_onMouseUp;
		}
	}
	private var g2d_onMouseOver:Signal1<GNodeMouseSignal>;
    @prop var onMouseOver:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseOver == null) g2d_onMouseOver = new Signal1(GMouseSignal);
			return g2d_onMouseOver;
		}
	}
	private var g2d_onMouseOut:Signal1<GNodeMouseSignal>;
    @prop var onMouseOut:Signal1<GNodeMouseSignal> = {
		get: {
			if (g2d_onMouseOut == null) g2d_onMouseOut = new Signal1(GMouseSignal);
			return g2d_onMouseOut;
		}
	}

	private var g2d_onRightMouseDown:Signal1<GNodeMouseSignal>;
	public var onRightMouseDown:Signal1<GNodeMouseSignal>;
	private var g2d_onRightMouseUp:Signal1<GNodeMouseSignal>;
	public var onRightMouseUp:Signal1<GNodeMouseSignal>;
	private var g2d_onRightMouseClick:Signal1<GNodeMouseSignal>;
	public var onRightMouseClick:Signal1<GNodeMouseSignal>;

	public var g2d_mouseDownNode:GNode;
	public var g2d_mouseOverNode:GNode;
	public var g2d_rightMouseDownNode:GNode;

	/**
     *  Process context mouse signal
     **/
	public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_signal:GMouseSignal, p_camera:GContextCamera):Bool {
		if (!isActive() || !transform.visible || (p_camera != null && (cameraGroup&p_camera.mask) == 0 && cameraGroup != 0)) return false;

		if (mouseChildren) {
            var child:GNode = g2d_lastChild;
            while (child != null) {
                var previous:GNode = child.g2d_previousNode;
				p_captured = child.processContextMouseSignal(p_captured, p_cameraX, p_cameraY, p_signal, p_camera) || p_captured;
                child = previous;
			}
		}
		
		if (mouseEnabled) {
            for (i in 0...g2d_numComponents) {
				p_captured = g2d_components[i].processContextMouseSignal(p_captured, p_cameraX, p_cameraY, p_signal) || p_captured;
			}
		}
		
		return p_captured;
	}

	/**
     *  Dispatch node mouse signal
     **/
	public function dispatchNodeMouseSignal(p_type:String, p_object:GNode, p_localX:Float, p_localY:Float, p_contextSignal:GMouseSignal):Void {
		if (mouseEnabled) { 
			var mouseSignal:GNodeMouseSignal = new GNodeMouseSignal(p_type, this, p_object, p_localX, p_localY, p_contextSignal);

            switch (p_type) {
                case GMouseSignalType.MOUSE_DOWN:
                    g2d_mouseDownNode = p_object;
                    if (g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_UP:
                    if (g2d_mouseDownNode == p_object && g2d_onMouseClick != null) {
                        var mouseClickSignal:GNodeMouseSignal = new GNodeMouseSignal(GMouseSignalType.MOUSE_UP, this, p_object, p_localX, p_localY, p_contextSignal);
                        g2d_onMouseClick.dispatch(mouseClickSignal);
                    }
                    g2d_mouseDownNode = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OVER:
                    g2d_mouseOverNode = p_object;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OUT:
                    g2d_mouseOverNode = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseSignal);
            }
		}
		
		if (parent != null) parent.dispatchNodeMouseSignal(p_type, p_object, p_localX, p_localY, p_contextSignal);
	}
	
	/****************************************************************************************************
	 * 	COMPONENT CODE
	 ****************************************************************************************************/
    private var g2d_renderable:IRenderable;
	private var g2d_components:Array<GComponent>;
	private var g2d_numComponents:Int = 0;
	
	/**
	 * 	Get a component of specified type attached to this node
	 * 
	 * 	@param p_componentClass Component type that should be retrieved
	 */
	public function getComponent(p_componentLookupClass:Class<GComponent>):GComponent {
        // TODO use Lambda
		if (g2d_disposed) throw new GError();
        for (i in 0...g2d_numComponents) {
            var component:GComponent = g2d_components[i];
            if (component.g2d_lookupClass == p_componentLookupClass) return component;
        }
		return null;
	}

	/**
     *  Has component
     **/
	public function hasComponent(p_componentLookupClass:Class<GComponent>):Bool {
		if (g2d_disposed) throw new GError();
        return getComponent(p_componentLookupClass) != null;
	}
	
	/**
	 * 	Add a component of specified type to this node, node can always have only a single component of a specific class to avoid redundancy
	 * 
	 *	@param p_componentClass Component type that should be instanced and attached to this node
	 */
	public function addComponent(p_componentClass:Class<GComponent>, p_componentLookupClass:Class<GComponent> = null):GComponent {
		if (g2d_disposed) throw new GError();
		if (p_componentLookupClass == null) p_componentLookupClass = p_componentClass;
        var lookup:GComponent = getComponent(p_componentLookupClass);
		if (lookup != null) return lookup;

		var component:GComponent = Type.createInstance(p_componentClass, [this]);

		if (component == null) throw new GError();
		component.g2d_lookupClass = p_componentLookupClass;

        if (Std.is(component, IRenderable)) {
            g2d_renderable = cast component;
        }

		/*
		if (Std.is(component, GBody)) {
			g2d_body = cast component;
			return component;
		}
		/**/

        if (g2d_components == null)g2d_components = new Array<GComponent>();
		g2d_components.push(component);
		g2d_numComponents++;
		
		return component;
	}
	
	/**
	 * 	Remove component of specified type from this node
	 * 
	 * 	@param p_componentClass Component type that should be removed
	 */
	public function removeComponent(p_componentLookupClass:Class<GComponent>):Void {
		if (g2d_disposed) throw new GError();
		var component:GComponent = getComponent(p_componentLookupClass);

		if (component == null || component == transform) return;

        g2d_components.remove(component);
		
		component.dispose();
	}
	
	/****************************************************************************************************
	 * 	CONTAINER CODE
	 ****************************************************************************************************/
	private var g2d_firstChild:GNode;
    private var g2d_lastChild:GNode;
    private var g2d_nextNode:GNode;
    private var g2d_previousNode:GNode;

    private var g2d_numChildren:Int = 0;
    @prop var numChildren:Int = {
		get: return g2d_numChildren
    }

    private var g2d_onAddedToStage:Signal0;
    @prop var onAddedToStage:Signal0 = {
		get: {
			if (g2d_onAddedToStage == null) g2d_onAddedToStage = new Signal0();
			return g2d_onAddedToStage;
		}
    }

    private var g2d_onRemovedFromStage:Signal0;
    @prop var onRemovedFromStage:Signal0 = {
		get: {
			if (g2d_onRemovedFromStage == null) g2d_onRemovedFromStage = new Signal0();
			return g2d_onRemovedFromStage;
		}
    }
	
	/**
	 * 	Add a child node to this node
	 * 
	 * 	@param p_child node that should be added
	 */
	public function addChild(p_child:GNode, p_before:GNode = null):Void {
		if (g2d_disposed) new GError("Node already disposed.");
		if (p_child == this) new GError("Can't add child to itself.");
		if (p_child.parent != null) p_child.parent.removeChild(p_child);

		p_child.g2d_parent = this;

        if (g2d_firstChild == null) {
            g2d_firstChild = p_child;
            g2d_lastChild = p_child;
        } else {
            if (p_before == null) {
                g2d_lastChild.g2d_nextNode = p_child;
                p_child.g2d_previousNode = g2d_lastChild;
                g2d_lastChild = p_child;
            } else {
                if (p_before != g2d_firstChild) {
                    p_before.g2d_previousNode.g2d_nextNode = p_child;
                } else {
                    g2d_firstChild = p_child;
                }
                p_child.g2d_previousNode = p_before.g2d_previousNode;
                p_child.g2d_nextNode = p_before;
                p_before.g2d_previousNode = p_child;
            }
        }

		g2d_numChildren++;
        if (g2d_numChildren == 1 && transform.hasUniformRotation()) transform.g2d_useMatrix++;
		
		if (isOnStage()) p_child.g2d_addedToStage();
	}

    public function addChildAt(p_child:GNode, p_index:Int):Void {
        if (g2d_disposed) new GError("Node already disposed.");
        if (p_child == this) new GError("Can't add child to itself.");
        if (p_child.parent != null) p_child.parent.removeChild(p_child);

        p_child.g2d_parent = this;

        var i:Int = 0;
        var after:GNode = g2d_firstChild;
        while (i<p_index && after != null) {
            after = after.g2d_nextNode;
            i++;
        }
        addChild(p_child, (after == null) ? null : after.g2d_nextNode);
    }
	
	public function getChildAt(p_index:Int):GNode {
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");
        var child:GNode = g2d_firstChild;
        for (i in 0...p_index) {
            child = child.g2d_nextNode;
        }
		return child;
	}

    public function getChildIndex(p_child:GNode):Int {
        if (p_child.parent != this) return -1;
        var child:GNode = g2d_firstChild;
        for (i in 0...g2d_numChildren) {
            if (child == p_child) return i;
            child = child.g2d_nextNode;
        }
        return -1;
    }

    public function setChildIndex(p_child:GNode, p_index:Int):Void {
        if (p_child.parent != this) new GError("Not a child of this node.");
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");

        var index:Int = 0;
        var child:GNode = g2d_firstChild;
        while (child!=null && index<p_index) {
            child = child.g2d_nextNode;
            index++;
        }
        if (index == p_index && child != p_child) {
            // Remove child from current index
            if (p_child != g2d_lastChild) {
                p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
            } else {
                g2d_lastChild = p_child.g2d_previousNode;
            }
            if (p_child != g2d_firstChild) {
                p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
            } else {
                g2d_firstChild = p_child.g2d_nextNode;
            }
            // Insert it before the found one
            if (child != g2d_firstChild) {
                child.g2d_previousNode.g2d_nextNode = p_child;
            } else {
                g2d_firstChild = p_child;
            }
            p_child.g2d_previousNode = child.g2d_previousNode;
            p_child.g2d_nextNode = child;
            child.g2d_previousNode = p_child;
        }
    }

    public function swapChildrenAt(p_index1:Int, p_index2:Int):Void {
        swapChildren(getChildAt(p_index1), getChildAt(p_index2));
    }

    public function swapChildren(p_child1:GNode, p_child2:GNode):Void {
        if (p_child1.parent != this || p_child2.parent != this) return;

        var temp:GNode = p_child1.g2d_nextNode;
        if (p_child2.g2d_nextNode == p_child1) {
            p_child1.g2d_nextNode = p_child2;
        } else {
            p_child1.g2d_nextNode = p_child2.g2d_nextNode;
            if (p_child1.g2d_nextNode != null) p_child1.g2d_nextNode.g2d_previousNode = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_nextNode = p_child1;
        } else {
            p_child2.g2d_nextNode = temp;
            if (p_child2.g2d_nextNode != null)  p_child2.g2d_nextNode.g2d_previousNode = p_child2;
        }

        temp = p_child1.g2d_previousNode;
        if (p_child2.g2d_previousNode == p_child1) {
            p_child1.g2d_previousNode = p_child2;
        } else {
            p_child1.g2d_previousNode = p_child2.g2d_previousNode;
            if (p_child1.g2d_previousNode != null)  p_child1.g2d_previousNode.g2d_nextNode = p_child1;
        }
        if (temp == p_child2) {
            p_child2.g2d_previousNode = p_child1;
        } else {
            p_child2.g2d_previousNode = temp;
            if (p_child2.g2d_previousNode != null) p_child2.g2d_previousNode.g2d_nextNode = p_child2;
        }

        if (p_child1 == g2d_firstChild) g2d_firstChild = p_child2;
        else if (p_child2 == g2d_firstChild) g2d_firstChild = p_child1;
        if (p_child1 == g2d_lastChild) g2d_lastChild = p_child2;
        else if (p_child2 == g2d_lastChild) g2d_lastChild = p_child1;
    }

    public function putChildToFront(p_child:GNode):Void {
        if (p_child.parent != this || p_child == g2d_lastChild) return;

        if (p_child.g2d_nextNode != null) p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        if (p_child.g2d_previousNode != null) p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        if (p_child == g2d_firstChild) g2d_firstChild = g2d_firstChild.g2d_nextNode;

        if (g2d_lastChild != null) g2d_lastChild.g2d_nextNode = p_child;
        p_child.g2d_previousNode = g2d_lastChild;
        p_child.g2d_nextNode = null;
        g2d_lastChild = p_child;
    }

    public function putChildToBack(p_child:GNode):Void {
        if (p_child.parent != this || p_child == g2d_firstChild) return;

        if (p_child.g2d_nextNode != null) p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        if (p_child.g2d_previousNode != null) p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        if (p_child == g2d_lastChild) g2d_lastChild = g2d_lastChild.g2d_previousNode;

        if (g2d_firstChild != null) g2d_firstChild.g2d_previousNode = p_child;
        p_child.g2d_previousNode = null;
        p_child.g2d_nextNode = g2d_firstChild;
        g2d_firstChild = p_child;
    }

	/**
	 * 	Remove a child node from this node
	 * 
	 * 	@param p_child node that should be removed
	 */
	public function removeChild(p_child:GNode):Void {
		if (g2d_disposed) new GError("Node already disposed.");
		if (p_child.parent != this) return;
		
		if (p_child.g2d_previousNode != null) {
            p_child.g2d_previousNode.g2d_nextNode = p_child.g2d_nextNode;
        } else {
            g2d_firstChild = g2d_firstChild.g2d_nextNode;
        }
        if (p_child.g2d_nextNode != null) {
            p_child.g2d_nextNode.g2d_previousNode = p_child.g2d_previousNode;
        } else {
            g2d_lastChild = g2d_lastChild.g2d_previousNode;
        }

        p_child.g2d_nextNode = p_child.g2d_previousNode = p_child.g2d_parent = null;
		
		g2d_numChildren--;
        if (g2d_numChildren == 0 && transform.hasUniformRotation()) transform.g2d_useMatrix--;

		if (isOnStage()) p_child.g2d_removedFromStage();
	}

	public function removeChildAt(p_index:Int):Void {
        if (p_index>=g2d_numChildren) new GError("Index out of bounds.");
        var index:Int = 0;
        var child:GNode = g2d_firstChild;
		while (child != null && index<p_index) {
            child = child.g2d_nextNode;
            index++;
        }
        removeChild(child);
	}

    /**
	 * 	This method will call dispose on all children of this node which will remove them
	 */
    public function disposeChildren():Void {
        while (g2d_firstChild != null) {
            g2d_firstChild.dispose();
        }
    }

	inline private function g2d_addedToStage():Void {
		if (g2d_onAddedToStage != null) g2d_onAddedToStage.dispatch();
        GStats.nodeCount++;
		
		//if (g2d_body != null) g2d_body.addToSpace();

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
			child.g2d_addedToStage();
            child = next;
		}
	}

	inline private function g2d_removedFromStage():Void {
		if (g2d_onRemovedFromStage != null) g2d_onRemovedFromStage.dispatch();
        GStats.nodeCount--;
		
		//if (g2d_body != null) g2d_body.removeFromSpace();

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
			child.g2d_removedFromStage();
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

    public function getBounds(p_targetSpace:GNode, p_bounds:GRectangle = null):GRectangle {
        if (p_bounds == null) p_bounds = new GRectangle();
        var found:Bool = false;
        var minX:Float = 10000000;
        var maxX:Float = -10000000;
        var minY:Float = 10000000;
        var maxY:Float = -10000000;
        var aabb:GRectangle = new GRectangle(0,0,0,0);

        if (g2d_renderable != null) {
            g2d_renderable.getBounds(aabb);
            if (aabb.width != 0 && aabb.height != 0) {
                var m:GMatrix = transform.getTransformationMatrix(p_targetSpace, g2d_cachedMatrix);

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
        }

        var child:GNode = g2d_firstChild;
        while (child != null) {
            var next:GNode = child.g2d_nextNode;
            child.getBounds(p_targetSpace, aabb);
            if (aabb.width == 0 || aabb.height == 0) continue;
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

    public function sortChildrenOnUserData(p_property:String, p_ascending:Bool = true):Void {
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
                    q = q.g2d_nextNode;
                    if (q == null) break;
                }

                qsize = insize;

                while (psize > 0 || (qsize > 0 && q != null)) {
                    if (psize == 0) {
                        e = q;
                        q = q.g2d_nextNode;
                        qsize--;
                    } else if (qsize == 0 || q == null) {
                        e = p;
                        p = p.g2d_nextNode;
                        psize--;
                    } else if (p_ascending) {
                        if (p.userData[p_property] >= q.userData[p_property]) {
                            e = p;
                            p = p.g2d_nextNode;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_nextNode;
                            qsize--;
                        }
                    } else {
                        if (p.userData[p_property] <= q.userData[p_property]) {
                            e = p;
                            p = p.g2d_nextNode;
                            psize--;
                        } else {
                            e = q;
                            q = q.g2d_nextNode;
                            qsize--;
                        }
                    }

                    if (g2d_lastChild != null) {
                        g2d_lastChild.g2d_nextNode = e;
                    } else {
                        g2d_firstChild = e;
                    }

                    e.g2d_previousNode = g2d_lastChild;

                    g2d_lastChild = e;
                }

                p = q;
            }

            g2d_lastChild.g2d_nextNode = null;

            if (nmerges <= 1) return;

            insize *= 2;
        }
    }

    public function toString():String {
        return "[GNode "+name+"]";
    }
}