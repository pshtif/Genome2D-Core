/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.element;

import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.IGContext;
import com.genome2d.Genome2D;
import com.genome2d.callbacks.GCallback.GCallback0;
import com.genome2d.callbacks.GCallback.GCallback1;
import com.genome2d.context.GCamera;
import com.genome2d.geom.GRectangle;
import com.genome2d.input.GFocusManager;
import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.input.IGFocusable;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.layout.GUILayout;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.skin.GUISkinManager;

@:access(com.genome2d.ui.layout.GUILayout)
@:access(com.genome2d.ui.skin.GUISkin)
@prototypeName("element")
@prototypeDefaultChildGroup("element")
@:build(com.genome2d.macros.MGMouseCallbackBuild.build())
class GUIElement implements IGPrototypable implements IGFocusable {
	public var red:Float = 1;
	public var green:Float = 1;
	public var blue:Float = 1;
	@prototype
	public var alpha:Float = 1;

    @prototype
    public var useMask:Bool = false;
	
	static public var setModelHook:Dynamic->Dynamic;
	
	#if swc @:extern #end
    @prototype
	public var color(get, set):Int;
	#if swc @:getter(color) #end
    inline private function get_color():Int {
        var color:Int = 0;
		color += Std.int(red * 0xFF) << 16;
		color += Std.int(green * 0xFF) << 8;
		color += Std.int(blue * 0xFF);
		return color;
    }
	#if swc @:setter(color) #end
	inline public function set_color(p_value:Int):Int {
		red = Std.int(p_value >> 16 & 0xFF) / 0xFF;
        green = Std.int(p_value >> 8 & 0xFF) / 0xFF;
        blue = Std.int(p_value & 0xFF) / 0xFF;
		return p_value;
	}
	
    @prototype 
	public var mouseEnabled:Bool = true;
    @prototype 
	public var mouseChildren:Bool = true;
    @prototype
    public var mouseCapture:Bool = true;

    private var g2d_onStateChanged:GCallback1<String>;
    #if swc @:extern #end
    public var onStateChanged(get,never):GCallback1<String>;
    #if swc @:getter(onStateChanged) #end
    inline private function get_onStateChanged():GCallback1<String> {
        if (g2d_onStateChanged == null) g2d_onStateChanged = new GCallback1<String>(String);
        return g2d_onStateChanged;
    }

    private var g2d_visible:Bool = true;
    #if swc @:extern #end
	@prototype
    public var visible(get,set):Bool;
    #if swc @:getter(visible) #end
    inline private function get_visible():Bool {
        return g2d_visible;
    }
    #if swc @:setter(visible) #end
    inline private function set_visible(p_value:Bool):Bool {
        g2d_visible = p_value;
        //dispatchHidden();
        return g2d_visible;
    }

    inline public function isRoot():Bool {
        return g2d_root == this;
    }

    public function isInHierarchy():Bool {
        if (parent != null) return parent.isInHierarchy();
        return g2d_root == this;
    }

    public function isVisible():Bool {
        if (parent != null) return visible && parent.isVisible();
        return g2d_root == this && visible;
    }

    @prototype 
	public var flushBatch:Bool = false;

    @prototype 
	public var name:String = "";

    private var g2d_root:GUIElement;
    #if swc @:extern #end
    @prototype
    public var root(get,never):GUIElement;
    #if swc @:getter(root) #end
    inline private function get_root():GUIElement {
        return g2d_root;
    }
	
	static public var dragSensitivity:Float = 0;
	
	public var userData:Dynamic;

	private var g2d_dragging:Bool = false;
	private var g2d_previousMouseX:Float;
	private var g2d_previousMouseY:Float;
	private var g2d_movedMouseX:Float;
	private var g2d_movedMouseY:Float;

    private var g2d_currentController:Dynamic;
    private var g2d_controller:Dynamic;
    public function getController():Dynamic {
        return (g2d_controller != null) ? g2d_controller : (parent != null) ? parent.getController() : null;
    }
    public function setController(p_value:Dynamic):Void {
        g2d_controller = p_value;

        invalidateController();
    }

    private function invalidateController():Void {
        var newController:Dynamic = getController();
        if (newController != g2d_currentController) {
            if (g2d_mouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseDown);
                if (mdf != null) onMouseDown.remove(mdf);
            }
            if (g2d_rightMouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseDown);
                if (mdf != null) onRightMouseDown.remove(mdf);
            }
			if (g2d_mouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
                if (mdf != null) onMouseUp.remove(mdf);
            }
            if (g2d_rightMouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseUp);
                if (mdf != null) onRightMouseUp.remove(mdf);
            }
			if (g2d_mouseOver != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
                if (mdf != null) onMouseOver.remove(mdf);
            }
			if (g2d_mouseOut != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
                if (mdf != null) onMouseOut.remove(mdf);
            }
			if (g2d_mouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
                if (mdf != null) onMouseClick.remove(mdf);
            }
            if (g2d_rightMouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseClick);
                if (mdf != null) onRightMouseClick.remove(mdf);
            }
			if (g2d_mouseMove != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
                if (mdf != null) onMouseMove.remove(mdf);
            }
			// Change the controller
            g2d_currentController = newController;
            if (g2d_mouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseDown);
                if (mdf != null) onMouseDown.add(mdf);
            }
            if (g2d_rightMouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseDown);
                if (mdf != null) onRightMouseDown.add(mdf);
            }
			if (g2d_mouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
                if (mdf != null) onMouseUp.add(mdf);
            }
            if (g2d_rightMouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseUp);
                if (mdf != null) onRightMouseUp.add(mdf);
            }
			if (g2d_mouseOver != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
                if (mdf != null) onMouseOver.add(mdf);
            }
			if (g2d_mouseOut != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
                if (mdf != null) onMouseOut.add(mdf);
            }
			if (g2d_mouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
                if (mdf != null) onMouseClick.add(mdf);
            }
            if (g2d_rightMouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseClick);
                if (mdf != null) onRightMouseClick.add(mdf);
            }
			if (g2d_mouseMove != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
                if (mdf != null) onMouseMove.add(mdf);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateController();
            }
        }
    }

	@prototype
    public function setAlign(p_align:Int):Void {
		g2d_anchorLeft = g2d_anchorRight = ((p_align - 1) % 3) * 0.5;
		g2d_anchorTop = g2d_anchorBottom = Std.int((p_align - 1) / 3) * 0.5;
		g2d_pivotX = ((p_align - 1) % 3) * 0.5;		
		g2d_pivotY = Std.int((p_align - 1) / 3) * 0.5;		
        setDirty();
    }
	
	@prototype
    public function setAnchorAlign(p_align:Int):Void {
		g2d_anchorLeft = g2d_anchorRight = ((p_align - 1) % 3) * 0.5;
		g2d_anchorTop = g2d_anchorBottom = Std.int((p_align - 1) / 3) * 0.5;
        setDirty();
    }
	
	@prototype
    public function setPivotAlign(p_align:Int):Void {
		g2d_pivotX = ((p_align - 1) % 3) * 0.5;		
		g2d_pivotY = Std.int((p_align - 1) / 3) * 0.5;
        setDirty();
    }


    private var g2d_mouseDown:String = "";
    #if swc @:extern #end
    @prototype public var mouseDown(get,set):String;
    #if swc @:getter(mouseDown) #end
    inline private function get_mouseDown():String {
        return g2d_mouseDown;
    }
    #if swc @:setter(mouseDown) #end
    inline private function set_mouseDown(p_value:String):String {
		if (g2d_mouseDown != p_value) {
			if (g2d_mouseDown != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_mouseDown);
				if (mdf != null) onMouseDown.remove(mdf);
			}
			g2d_mouseDown = p_value;
			if (g2d_mouseDown != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_mouseDown);
				if (mdf != null) onMouseDown.add(mdf);
			}
		}
        return g2d_mouseDown;
    }

    private var g2d_rightMouseDown:String = "";
    #if swc @:extern #end
    @prototype public var rightMouseDown(get,set):String;
        #if swc @:getter(rightMouseDown) #end
    inline private function get_rightMouseDown():String {
        return g2d_rightMouseDown;
    }
        #if swc @:setter(rightMouseDown) #end
    inline private function set_rightMouseDown(p_value:String):String {
        if (g2d_rightMouseDown != p_value) {
            if (g2d_rightMouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_rightMouseDown);
                if (mdf != null) onRightMouseDown.remove(mdf);
            }
            g2d_rightMouseDown = p_value;
            if (g2d_rightMouseDown != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController,g2d_rightMouseDown);
                if (mdf != null) onRightMouseDown.add(mdf);
            }
        }
        return g2d_rightMouseDown;
    }

    private var g2d_mouseUp:String = "";
    #if swc @:extern #end
    @prototype public var mouseUp(get,set):String;
    #if swc @:getter(mouseUp) #end
    inline private function get_mouseUp():String {
        return g2d_mouseUp;
    }
    #if swc @:setter(mouseUp) #end
    inline private function set_mouseUp(p_value:String):String {
		if (g2d_mouseUp != p_value) {
			if (g2d_mouseUp != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
				if (mdf != null) onMouseUp.remove(mdf);
			}
			g2d_mouseUp = p_value;
			if (g2d_mouseUp != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseUp);
				if (mdf != null) onMouseUp.add(mdf);
			}
		}
        return g2d_mouseUp;
    }

    private var g2d_rightMouseUp:String = "";
    #if swc @:extern #end
    @prototype public var rightMouseUp(get,set):String;
        #if swc @:getter(rightMouseUp) #end
    inline private function get_rightMouseUp():String {
        return g2d_rightMouseUp;
    }
        #if swc @:setter(rightMouseUp) #end
    inline private function set_rightMouseUp(p_value:String):String {
        if (g2d_rightMouseUp != p_value) {
            if (g2d_rightMouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseUp);
                if (mdf != null) onRightMouseUp.remove(mdf);
            }
            g2d_rightMouseUp = p_value;
            if (g2d_rightMouseUp != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseUp);
                if (mdf != null) onRightMouseUp.add(mdf);
            }
        }
        return g2d_rightMouseUp;
    }

    private var g2d_mouseWheel:String = "";
    #if swc @:extern #end
    @prototype public var mouseWheel(get,set):String;
        #if swc @:getter(mouseWheel) #end
    inline private function get_mouseWheel():String {
        return g2d_mouseWheel;
    }
        #if swc @:setter(mouseWheel) #end
    inline private function set_mouseWheel(p_value:String):String {
        if (g2d_mouseWheel != p_value) {
            if (g2d_mouseWheel != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseWheel);
                if (mdf != null) onMouseWheel.remove(mdf);
            }
            g2d_mouseWheel = p_value;
            if (g2d_mouseWheel != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseWheel);
                if (mdf != null) onMouseWheel.add(mdf);
            }
        }
        return g2d_mouseWheel;
    }

    private var g2d_mouseClick:String = "";
    #if swc @:extern #end
    @prototype public var mouseClick(get,set):String;
    #if swc @:getter(mouseClick) #end
    inline private function get_mouseClick():String {
        return g2d_mouseClick;
    }
    #if swc @:setter(mouseClick) #end
    inline private function set_mouseClick(p_value:String):String {
		if (g2d_mouseClick != p_value) {
			if (g2d_mouseClick != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
				if (mdf != null) onMouseClick.remove(mdf);
			}
			g2d_mouseClick = p_value;
			if (g2d_mouseClick != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseClick);
				if (mdf != null) onMouseClick.add(mdf);
			}
		}
        return g2d_mouseClick;
    }

    private var g2d_rightMouseClick:String = "";
    #if swc @:extern #end
    @prototype public var rightMouseClick(get,set):String;
        #if swc @:getter(rightMouseClick) #end
    inline private function get_rightMouseClick():String {
        return g2d_rightMouseClick;
    }
        #if swc @:setter(rightMouseClick) #end
    inline private function set_rightMouseClick(p_value:String):String {
        if (g2d_rightMouseClick != p_value) {
            if (g2d_rightMouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseClick);
                if (mdf != null) onRightMouseClick.remove(mdf);
            }
            g2d_rightMouseClick = p_value;
            if (g2d_rightMouseClick != "" && g2d_currentController != null) {
                var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_rightMouseClick);
                if (mdf != null) onRightMouseClick.add(mdf);
            }
        }
        return g2d_rightMouseClick;
    }

    private var g2d_mouseOver:String = "";
    #if swc @:extern #end
    @prototype public var mouseOver(get,set):String;
    #if swc @:getter(mouseOver) #end
    inline private function get_mouseOver():String {
        return g2d_mouseOver;
    }
    #if swc @:setter(mouseOver) #end
    inline private function set_mouseOver(p_value:String):String {
		if (g2d_mouseOver != p_value) {
			if (g2d_mouseOver != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
				if (mdf != null) onMouseOver.remove(mdf);
			}
			g2d_mouseOver = p_value;
			if (g2d_mouseOver != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOver);
				if (mdf != null) onMouseOver.add(mdf);
			}
		}
        return g2d_mouseOver;
    }

    private var g2d_mouseOut:String = "";
    #if swc @:extern #end
    @prototype public var mouseOut(get,set):String;
    #if swc @:getter(mouseOut) #end
    inline private function get_mouseOut():String {
        return g2d_mouseOut;
    }
    #if swc @:setter(mouseOut) #end
    inline private function set_mouseOut(p_value:String):String {
		if (g2d_mouseOut != p_value) {
			if (g2d_mouseOut != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
				if (mdf != null) onMouseOut.remove(mdf);
			}
			g2d_mouseOut = p_value;
			if (g2d_mouseOut != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseOut);
				if (mdf != null) onMouseOut.add(mdf);
			}
		}
        return g2d_mouseOut;
    }

    private var g2d_mouseMove:String = "";
    #if swc @:extern #end
    @prototype public var mouseMove(get,set):String;
    #if swc @:getter(mouseMove) #end
    inline private function get_mouseMove():String {
        return g2d_mouseMove;
    }
    #if swc @:setter(mouseMove) #end
    inline private function set_mouseMove(p_value:String):String {
		if (g2d_mouseMove != p_value) {
			if (g2d_mouseMove != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
				if (mdf != null) onMouseMove.remove(mdf);
			}
			g2d_mouseMove = p_value;
			if (g2d_mouseMove != "" && g2d_currentController != null) {
				var mdf:GMouseInput->Void = Reflect.field(g2d_currentController, g2d_mouseMove);
				if (mdf != null) onMouseMove.add(mdf);
			}
		}
        return g2d_mouseMove;
    }

    private var g2d_model:String = "";
    public function getModel():String {
        return g2d_model;
    }
	@prototype
    public function setModel(p_value:Dynamic):Void {
		if (setModelHook != null) p_value = setModelHook(p_value);
		
		// Xml assignment
        if (Std.is(p_value, Xml)) {
            var xml:Xml = cast (p_value, Xml);
            var it:Iterator<Xml> = xml.elements();
            if (!it.hasNext()) {
                if (xml.firstChild() != null && xml.firstChild().nodeType == Xml.PCData) {
                    g2d_model = xml.firstChild().nodeValue;
                } else {
                    g2d_model = "";
                }
            } else {
                while (it.hasNext()) {
                    var childXml:Xml = it.next();
                    var child:GUIElement = getChildByName(childXml.nodeName,true);
                    if (child != null) {
                        child.setModel(childXml);
                    }
                }
            }
		// Just direct string assignment
        } else if (Std.is(p_value,String)) {
            g2d_model = p_value;
		// Dynamic object lookup for public fields
        } else {
            for (it in Reflect.fields(p_value)) {
                var child:GUIElement = getChildByName(it);
                if (child != null) child.setModel(Reflect.field(p_value, it));
            }
        }
        onModelChanged.dispatch(this);
    }
	
    private var g2d_onModelChanged:GCallback1<GUIElement>;
    #if swc @:extern #end
    public var onModelChanged(get, never):GCallback1<GUIElement>;
    #if swc @:getter(onModelChanged) #end
    inline private function get_onModelChanged():GCallback1<GUIElement> {
        return g2d_onModelChanged;
    }

    private var g2d_layout:GUILayout;
    #if swc @:extern #end
    @prototype public var layout(get, set):GUILayout;
    #if swc @:getter(layout) #end
    inline private function get_layout():GUILayout {
        return g2d_layout;
    }
    #if swc @:setter(layout) #end
    inline private function set_layout(p_value:GUILayout):GUILayout {
        g2d_layout = p_value;
        setDirty();
        return g2d_layout;
    }

    private var g2d_activeSkin:GUISkin;

    private var g2d_skin:GUISkin;
    #if swc @:extern #end
    @prototype("getReference") public var skin(get, set):GUISkin;
    #if swc @:getter(skin) #end
    inline private function get_skin():GUISkin {
        return g2d_skin;
    }
    #if swc @:setter(skin) #end
    inline private function set_skin(p_value:GUISkin):GUISkin {
		if (p_value == null || g2d_skin == null || p_value != g2d_skin) {
			if (g2d_skin != null) g2d_skin.remove();
			g2d_skin = (p_value != null) ? p_value.attach(this) : p_value;
			g2d_activeSkin = g2d_skin;

			setDirty();
		}

        return g2d_skin;
    }

    private var g2d_dirty:Bool = true;
    private function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    private var g2d_anchorX:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorX(get, set):Float;
    #if swc @:getter(anchorX) #end
    inline private function get_anchorX():Float {
        return g2d_anchorX;
    }
    #if swc @:setter(anchorX) #end
    inline private function set_anchorX(p_value:Float):Float {
        g2d_anchorX = p_value;
        setDirty();
        return g2d_anchorX;
    }

    private var g2d_anchorY:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorY(get, set):Float;
    #if swc @:getter(anchorY) #end
    inline private function get_anchorY():Float {
        return g2d_anchorY;
    }
    #if swc @:setter(anchorY) #end
    inline private function set_anchorY(p_value:Float):Float {
        g2d_anchorY = p_value;
        setDirty();
        return g2d_anchorY;
    }

    private var g2d_anchorLeft:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorLeft(get, set):Float;
    #if swc @:getter(anchorLeft) #end
    inline private function get_anchorLeft():Float {
        return g2d_anchorLeft;
    }
    #if swc @:setter(anchorLeft) #end
    inline private function set_anchorLeft(p_value:Float):Float {
        g2d_anchorLeft = p_value;
        setDirty();
        return g2d_anchorLeft;
    }

    private var g2d_anchorTop:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorTop(get, set):Float;
    #if swc @:getter(anchorTop) #end
    inline private function get_anchorTop():Float {
        return g2d_anchorTop;
    }
    #if swc @:setter(anchorTop) #end
    inline private function set_anchorTop(p_value:Float):Float {
        g2d_anchorTop = p_value;
        setDirty();
        return g2d_anchorTop;
    }

    private var g2d_anchorRight:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorRight(get, set):Float;
    #if swc @:getter(anchorRight) #end
    inline private function get_anchorRight():Float {
        return g2d_anchorRight;
    }
    #if swc @:setter(anchorRight) #end
    inline private function set_anchorRight(p_value:Float):Float {
        g2d_anchorRight = p_value;
        setDirty();
        return g2d_anchorRight;
    }

    private var g2d_anchorBottom:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorBottom(get, set):Float;
    #if swc @:getter(anchorBottom) #end
    inline private function get_anchorBottom():Float {
        return g2d_anchorBottom;
    }
    #if swc @:setter(anchorBottom) #end
    inline private function set_anchorBottom(p_value:Float):Float {
        g2d_anchorBottom = p_value;
        setDirty();
        return g2d_anchorBottom;
    }

    private var g2d_left:Float = 0;
    #if swc @:extern #end
    @prototype public var left(get, set):Float;
    #if swc @:getter(left) #end
    inline private function get_left():Float {
        return g2d_left;
    }
    #if swc @:setter(left) #end
    inline private function set_left(p_value:Float):Float {
        g2d_left = p_value;
        setDirty();
        return g2d_left;
    }

    private var g2d_top:Float = 0;
    #if swc @:extern #end
    @prototype public var top(get, set):Float;
    #if swc @:getter(top) #end
    inline private function get_top():Float {
        return g2d_top;
    }
    #if swc @:setter(top) #end
    inline private function set_top(p_value:Float):Float {
        g2d_top = p_value;
        setDirty();
        return g2d_top;
    }

    private var g2d_right:Float = 0;
    #if swc @:extern #end
    @prototype public var right(get, set):Float;
    #if swc @:getter(right) #end
    inline private function get_right():Float {
        return g2d_right;
    }
    #if swc @:setter(right) #end
    inline private function set_right(p_value:Float):Float {
        g2d_right = p_value;
        setDirty();
        return g2d_right;
    }

    public var g2d_bottom:Float = 0;
    #if swc @:extern #end
    @prototype public var bottom(get, set):Float;
    #if swc @:getter(bottom) #end
    inline private function get_bottom():Float {
        return g2d_bottom;
    }
    #if swc @:setter(bottom) #end
    inline private function set_bottom(p_value:Float):Float {
        g2d_bottom = p_value;
        setDirty();
        return g2d_bottom;
    }

    public var g2d_pivotX:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotX(get, set):Float;
    #if swc @:getter(pivotX) #end
    inline private function get_pivotX():Float {
        return g2d_pivotX;
    }
    #if swc @:setter(pivotX) #end
    inline private function set_pivotX(p_value:Float):Float {
        g2d_pivotX = p_value;
        setDirty();
        return g2d_pivotX;
    }

    public var g2d_pivotY:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotY(get, set):Float;
    #if swc @:getter(pivotY) #end
    inline private function get_pivotY():Float {
        return g2d_pivotY;
    }
    #if swc @:setter(pivotY) #end
    inline private function set_pivotY(p_value:Float):Float {
        g2d_pivotY = p_value;
        setDirty();
        return g2d_pivotY;
    }

    public var g2d_worldLeft:Float;
    public var g2d_worldTop:Float;
    public var g2d_worldRight:Float;
    public var g2d_worldBottom:Float;
	
	@prototype
	public var expand:Bool = true;

    private var g2d_minWidth:Float = 0;
    public var g2d_finalWidth:Float = 0;

    private var g2d_preferredWidth:Float = 0;
    #if swc @:extern #end
    @prototype 
	public var preferredWidth(get, set):Float;
    #if swc @:getter(preferredWidth) #end
    inline private function get_preferredWidth():Float {
        return g2d_preferredWidth;
    }
    #if swc @:setter(preferredWidth) #end
    inline private function set_preferredWidth(p_value:Float):Float {
        g2d_preferredWidth = p_value;
        setDirty();
        return g2d_preferredWidth;
    }

    private var g2d_minHeight:Float = 0;
    public var g2d_finalHeight:Float = 0;

    private var g2d_preferredHeight:Float = 0;
    #if swc @:extern #end
    @prototype public var preferredHeight(get, set):Float;
    #if swc @:getter(preferredHeight) #end
    inline private function get_preferredHeight():Float {
        return g2d_preferredHeight;
    }
    #if swc @:setter(preferredHeight) #end
    inline private function set_preferredHeight(p_value:Float):Float {
        g2d_preferredHeight = p_value;
        setDirty();
        return g2d_preferredHeight;
    }

    private var g2d_parent:GUIElement;
    #if swc @:extern #end
    public var parent(get, never):GUIElement;
    #if swc @:getter(parent) #end
    inline private function get_parent():GUIElement {
        return g2d_parent;
    }

    private var g2d_numChildren:Int = 0;
    #if swc @:extern #end
    public var numChildren(get, never):Int;
    #if swc @:getter(numChildren) #end
    inline private function get_numChildren():Int {
        return g2d_numChildren;
    }

    private var g2d_children:Array<GUIElement>;
    #if swc @:extern #end
    public var children(get, never):Array<GUIElement>;
    #if swc @:getter(children) #end
    inline private function get_children():Array<GUIElement> {
        return g2d_children;
    }


    public function new(p_skin:GUISkin = null) {
		GUISkinManager.onSkinChanged.add(skinChanged_handler);
        g2d_onModelChanged = new GCallback1<GUIElement>();

        if (p_skin != null) skin = p_skin;
    }

    public function isParent(p_element:GUIElement):Bool {
        if (p_element == g2d_parent) return true;
        if (g2d_parent == null) return false;
        return g2d_parent.isParent(p_element);
    }

	/*
    public function setRect(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        var w:Float = p_right-p_left;
        var h:Float = p_bottom-p_top;

        if (g2d_parent != null) {
            var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
            var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
            var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
            var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;

            if (g2d_anchorLeft != g2d_anchorRight) {
                g2d_left = p_left - worldAnchorLeft;
                g2d_right = worldAnchorRight - p_right;
            } else {
                g2d_anchorX = p_left - worldAnchorLeft + w*g2d_pivotX;
            }

            if (g2d_anchorTop != g2d_anchorBottom) {
                g2d_top = p_top - worldAnchorTop;
                g2d_bottom = worldAnchorBottom - p_bottom;
            } else {
                g2d_anchorY = p_top - worldAnchorTop + h*g2d_pivotY;
            }
        } else {
            g2d_worldLeft = p_left;
            g2d_worldTop = p_top;
            g2d_worldRight = p_right;
            g2d_worldBottom = p_bottom;
            g2d_finalWidth = w;
            g2d_finalHeight = h;
        }

        g2d_preferredWidth = w;
        g2d_preferredHeight = h;

        setDirty();
    }
	/**/
    public function addChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent == this) return;
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.push(p_child);
        g2d_numChildren++;
        p_child.g2d_root = g2d_root;
        p_child.g2d_parent = this;
        p_child.invalidateController();
        setDirty();
    }

    public function addChildAt(p_child:GUIElement, p_index:Int):Void {
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.insert(p_index,p_child);
        g2d_numChildren++;
        p_child.g2d_root = g2d_root;
        p_child.g2d_parent = this;
        p_child.invalidateController();
        setDirty();
    }

    public function removeChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent != this) return;
        g2d_children.remove(p_child);
        g2d_numChildren--;
        p_child.g2d_root = null;
        p_child.g2d_parent = null;
        p_child.invalidateController();
        setDirty();
    }

    public function getChildAt(p_index:Int):GUIElement {
        return (p_index>=0 && p_index<g2d_numChildren) ? g2d_children[p_index] : null;
    }

    public function getChildByName(p_name:String, p_recursive:Bool = false):GUIElement {
		var split:Array<String> = null;
		if (p_name.indexOf("->") != -1) split = p_name.split("->");
		
        for (i in 0...g2d_numChildren) {
			if (g2d_children[i].name == (split == null?p_name:split[0])) {
				if (split == null) {
					return g2d_children[i];
				} else {
					split.shift();
					return g2d_children[i].getChildByName(split.join("->"), p_recursive);
				}
			}
			if (p_recursive) {
				var childByName:GUIElement = g2d_children[i].getChildByName(p_name, true);
				if (childByName != null) {
					if (split == null) {
						return childByName;
					} else {
						split.shift();
						return childByName.getChildByName(split.join("->"), true);
					}
				}
			}
		}
        return null;
    }

    public function getChildIndex(p_child:GUIElement):Int {
        return g2d_children.indexOf(p_child);
    }

    public function setChildIndex(p_child:GUIElement, p_index:Int):Void {
        if (p_child.parent == this) {
            g2d_children.remove(p_child);
            g2d_children.insert(p_index, p_child);
        }
    }
	
    private function calculateWidth():Void {
        if (g2d_dirty) {
            if (g2d_layout != null && g2d_layout.isCalculatingWidth()) {
                g2d_layout.calculateWidth(this);
            } else {
                g2d_minWidth = g2d_activeSkin != null ? g2d_activeSkin.getMinWidth() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateWidth();
					//if (g2d_minWidth < g2d_children[i].g2d_minWidth) g2d_minWidth = g2d_children[i].g2d_minWidth;
                }
            }
        }
    }
	
	private function invalidateWidth():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null) {
                    var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
                    var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
                    var w:Float = (g2d_preferredWidth > g2d_minWidth || !expand) ? g2d_preferredWidth : g2d_minWidth;
                    if (g2d_anchorLeft != g2d_anchorRight) {
                        g2d_worldLeft = worldAnchorLeft + g2d_left;
                        g2d_worldRight = worldAnchorRight - g2d_right;
                    } else {
                        g2d_worldLeft = worldAnchorLeft + g2d_anchorX - w * g2d_pivotX;
                        g2d_worldRight = worldAnchorLeft + g2d_anchorX + w * (1 - g2d_pivotX);
                    }

                    g2d_finalWidth = g2d_worldRight - g2d_worldLeft;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateWidth(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateWidth();
                    }
                }
            } else {
				g2d_finalWidth = g2d_worldRight - g2d_worldLeft;
				
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateWidth();
                }
            }
        }
    }

    private function calculateHeight():Void {
        if (g2d_dirty) {
            if (g2d_layout != null) {
                g2d_layout.calculateHeight(this);
            } else {
                g2d_minHeight = g2d_activeSkin != null ? g2d_activeSkin.getMinHeight() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateHeight();
                }
            }
        }
    }

    private function invalidateHeight():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null || !g2d_parent.g2d_layout.isVerticalLayout()) {
                    var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
                    var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;
                    var h:Float = (g2d_preferredHeight > g2d_minHeight || !expand) ? g2d_preferredHeight : g2d_minHeight;
                    if (g2d_anchorTop != g2d_anchorBottom) {
                        g2d_worldTop = worldAnchorTop + g2d_top;
                        g2d_worldBottom = worldAnchorBottom - g2d_bottom;
                    } else {
                        g2d_worldTop = worldAnchorTop + g2d_anchorY - h * g2d_pivotY;
                        g2d_worldBottom = worldAnchorTop + g2d_anchorY + h * (1 - g2d_pivotY);
                    }
                    g2d_finalHeight = g2d_worldBottom - g2d_worldTop;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateHeight(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateHeight();
                    }
                }
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateHeight();
                }
            }
        }

        if (g2d_onInvalidate != null) g2d_onInvalidate.dispatch();
    }

    public function render(p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1):Void {
        if (visible) {
			var worldRed:Float = p_red * red;
			var worldGreen:Float = p_green * green;
			var worldBlue:Float = p_blue * blue;
			var worldAlpha:Float = p_alpha * alpha;

			var context:IGContext = Genome2D.getInstance().getContext();
			var previousMask:GRectangle = context.getMaskRect();
			var camera:GCamera = context.getActiveCamera();

            if (flushBatch || useMask) GUISkin.flushBatch();
			if (useMask) {
                var w:Float = (g2d_worldRight - g2d_worldLeft) * camera.scaleX;
                var h:Float = (g2d_worldBottom - g2d_worldTop) * camera.scaleY;

                var maskRect:GRectangle = new GRectangle(g2d_worldLeft*camera.scaleX, g2d_worldTop*camera.scaleY, w, h);
                var intersection:GRectangle = (previousMask == null) ? maskRect : previousMask.intersection(maskRect);
                if (intersection.width <= 0 || intersection.height <= 0) return;
				context.setMaskRect(intersection);
			}

            if (g2d_activeSkin != null) {
                g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom, worldRed, worldGreen, worldBlue, worldAlpha);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].render(worldRed, worldGreen, worldBlue, worldAlpha);
            }
			
			if (useMask) {
				GUISkin.flushBatch();
				context.setMaskRect(previousMask);
			}
        }
    }

    public function getPrototype(p_prototype:GPrototype = null):GPrototype {		
		p_prototype = getPrototypeDefault(p_prototype);
		
        for (i in 0...g2d_numChildren) {
            p_prototype.addChild(g2d_children[i].getPrototype(), PROTOTYPE_DEFAULT_CHILD_GROUP);
        }

        return p_prototype;
    }
/**/
    private var g2d_useCustomChildPrototypeBinding:Bool = false;
    public function bindPrototype(p_prototype:GPrototype):Void {
        GPrototypeFactory.g2d_bindPrototype(this, p_prototype, PROTOTYPE_NAME);

        if (!g2d_useCustomChildPrototypeBinding) {
            var group:Array<GPrototype> = p_prototype.getGroup(PROTOTYPE_DEFAULT_CHILD_GROUP);
            if (group != null) {
                for (prototype in group) {
                    var prototype:IGPrototypable = GPrototypeFactory.createInstance(prototype);
                    if (Std.is(prototype,GUIElement)) addChild(cast prototype);
                }
            }
        }
    }

    public function disposeChildren():Void {
        while (g2d_numChildren>0) {
            g2d_children[g2d_numChildren-1].dispose();
        }
    }

    public function dispose():Void {
		visible = mouseEnabled = mouseChildren = false;
		
		GUISkinManager.onSkinChanged.remove(skinChanged_handler);
	
		if (g2d_skin != null) g2d_skin.remove();
		g2d_skin = null;
		g2d_activeSkin = null;
		
        setDirty();
        if (g2d_parent != null) g2d_parent.removeChild(this);
    }

    /*******************************************************************************************************************
    *   MOUSE CODE
    *******************************************************************************************************************/
    private var g2d_onInvalidate:GCallback0;
    #if swc @:extern #end
    public var onInvalidate(get, never):GCallback0;
    #if swc @:getter(onInvalidate) #end
    inline private function get_onInvalidate():GCallback0 {
        if (g2d_onInvalidate == null) g2d_onInvalidate = new GCallback0();
        return g2d_onInvalidate;
    }

    private var g2d_rightMouseDownElement:GUIElement;

    static private var g2d_foundMouseDisabled:Bool = true;
    static private var g2d_lastMouseEnabled:GUIElement;
    private function getLastMouseEnabled():GUIElement {
        if (g2d_foundMouseDisabled && mouseEnabled) {
            g2d_foundMouseDisabled = false;
            g2d_lastMouseEnabled = this;
        }
        if (!mouseEnabled) g2d_foundMouseDisabled = true;

        if (parent != null) return parent.getLastMouseEnabled();
        g2d_foundMouseDisabled = true;
        return g2d_lastMouseEnabled;
    }

    private var g2d_mouseOverFound:Bool = false;
    private var g2d_mouseOverElement2:GUIElement;
    private var g2d_previousOverElement:GUIElement;
    private function isMouseOverElement(p_element:GUIElement):Bool {
        return g2d_root.g2d_mouseOverElement2 == p_element;
    }
    private function setMouseOverElement(p_element:GUIElement, p_input:GMouseInput):Void {
        g2d_root.g2d_mouseOverFound = true;
        if (p_element != null) {
            p_element = p_element.getLastMouseEnabled();
        }
        g2d_root.g2d_mouseOverElement2 = p_element;
    }

    private var g2d_mouseDownElement2:GUIElement;
    private function isMouseDownElement(p_element:GUIElement):Bool {
        return g2d_root.g2d_mouseDownElement2 == p_element;
    }
    private function setMouseDownElement(p_element:GUIElement, p_input:GMouseInput):Void {
        if (p_element != null) p_element = p_element.getLastMouseEnabled();

        if (g2d_root.g2d_mouseDownElement2 != p_element) {
            g2d_root.g2d_mouseDownElement2 = p_element;
        }
    }

    private var g2d_mouseUpElement:GUIElement;
    private function setMouseUpElement(p_element:GUIElement, p_input:GMouseInput):Void {
        if (p_element != null) p_element = p_element.getLastMouseEnabled();

        g2d_root.g2d_mouseUpElement = p_element;
        /*
        if (g2d_root.g2d_mouseDownElement2 != null) {
            if (g2d_root.g2d_mouseDownElement2 == p_element) {
                g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_UP, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
                g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.CLICK, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
            } else {
                g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_UP, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
            }
        }

        g2d_root.g2d_mouseDownElement2 = null;
        /**/
    }

    public function captureMouseInput(p_input:GMouseInput):Bool {
        var captured:Bool = false;
        if (isRoot()) {
            switch (p_input.type) {
                case GMouseInputType.MOUSE_MOVE | GMouseInputType.MOUSE_STILL:
                    g2d_mouseOverFound = false;
            }
        }

		if (visible) {
			if (mouseChildren) {
                if (!useMask || (p_input.worldX > g2d_worldLeft && p_input.worldX < g2d_worldRight && p_input.worldY > g2d_worldTop && p_input.worldY < g2d_worldBottom)) {
                    var i:Int = g2d_numChildren;
                    while (i>0) {
                        i--;
                        if (i<g2d_numChildren) captured = captured || g2d_children[i].captureMouseInput(p_input);
                        if (mouseEnabled && captured) p_input.captured = captured;
                    }
                }
			}

            p_input.localX = p_input.worldX - g2d_worldLeft;
            p_input.localY = p_input.worldY - g2d_worldTop;

            if (!p_input.captured && p_input.worldX > g2d_worldLeft && p_input.worldX < g2d_worldRight && p_input.worldY > g2d_worldTop && p_input.worldY < g2d_worldBottom) {
                if (g2d_activeSkin != null) {
                    // TODO add capture info in the actual skin
                    g2d_activeSkin.captureMouseInput(p_input);

                    p_input.captured = mouseEnabled;
                    captured = true;
                    if (p_input.type == GMouseInputType.MOUSE_MOVE || p_input.type == GMouseInputType.MOUSE_STILL) setMouseOverElement(this, p_input);

                    else if (p_input.type == GMouseInputType.MOUSE_DOWN) setMouseDownElement(this, p_input);

                    else if (p_input.type == GMouseInputType.MOUSE_UP) setMouseUpElement(this, p_input);

                    else g2d_dispatchMouseCallback(p_input.type, this, this, p_input, false);
                }
            }

            if (isRoot()) {
                switch (p_input.type) {
                    case GMouseInputType.MOUSE_MOVE | GMouseInputType.MOUSE_STILL:
                        if (g2d_root.g2d_mouseOverElement2 != g2d_root.g2d_previousOverElement) {
                            if (g2d_root.g2d_previousOverElement != null) {
                                g2d_root.g2d_previousOverElement.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OUT, g2d_root.g2d_previousOverElement, g2d_root.g2d_previousOverElement, p_input, false);
                            }
                            g2d_root.g2d_previousOverElement = g2d_root.g2d_mouseOverElement2;
                            if (g2d_root.g2d_mouseOverElement2 != null) {
                                g2d_root.g2d_mouseOverElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OVER, g2d_root.g2d_mouseOverElement2, g2d_root.g2d_mouseOverElement2, p_input, false);
                            }
                        } else if (g2d_root.g2d_previousOverElement != null && g2d_mouseOverFound == false) {
                            g2d_root.g2d_mouseOverElement2 = null;
                            g2d_root.g2d_previousOverElement.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_OUT, g2d_root.g2d_previousOverElement, g2d_root.g2d_previousOverElement, p_input, false);
                            g2d_root.g2d_previousOverElement = null;
                        }
                    case GMouseInputType.MOUSE_DOWN:
                        if (g2d_root.g2d_mouseDownElement2 != null) {
                            g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_DOWN, g2d_root.g2d_mouseOverElement2, g2d_root.g2d_mouseOverElement2, p_input, false);
                            g2d_root.g2d_mouseDownElement2 == null;
                        }
                    case GMouseInputType.MOUSE_UP:
                        if (g2d_root.g2d_mouseUpElement == null && g2d_root.g2d_mouseDownElement2 != null) {
                            g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_UP, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
                        } else if (g2d_root.g2d_mouseUpElement != null && g2d_root.g2d_mouseDownElement2 == g2d_root.g2d_mouseUpElement) {
                            g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_UP, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
                            g2d_root.g2d_mouseDownElement2.g2d_dispatchMouseCallback(GMouseInputType.CLICK, g2d_root.g2d_mouseDownElement2, g2d_root.g2d_mouseDownElement2, p_input, false);
                        } else if (g2d_root.g2d_mouseUpElement != null) {
                            g2d_root.g2d_mouseUpElement.g2d_dispatchMouseCallback(GMouseInputType.MOUSE_UP, g2d_root.g2d_mouseUpElement, g2d_root.g2d_mouseUpElement, p_input, false);
                        }
                        g2d_root.g2d_mouseUpElement = g2d_root.g2d_mouseDownElement2 = null;
                }
            }
		}

        return captured;
    }

    private var g2d_lastClickTime:Float = -1;
    private function g2d_dispatchMouseCallback(p_type:String, p_target:GUIElement, p_dispatcher:GUIElement, p_input:GMouseInput, p_bubbling:Bool):Void {
        if (isVisible() || p_type == GMouseInputType.MOUSE_OUT) {
            var mouseInput:GMouseInput = p_input.clone(this, p_target, p_type);

            switch (p_type) {

                // MOVEMENT
                case GMouseInputType.MOUSE_MOVE:
                    if (mouseEnabled && g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseInput);
                case GMouseInputType.MOUSE_OVER:
                    if (mouseEnabled) {
                        if (hasState("mouseOver")) setState("mouseOver");
                        if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseInput);
                    }
                case GMouseInputType.MOUSE_OUT:
                    if (mouseEnabled) {
                        if (hasState("mouseOut")) setState("mouseOut");
                        if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseInput);
                    }

                // BUTTON
                case GMouseInputType.MOUSE_DOWN:
                    if (mouseEnabled && g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseInput);
                case GMouseInputType.MOUSE_UP:
                    if (mouseEnabled && g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseInput);
                case GMouseInputType.CLICK:
                    if (g2d_onMouseClick != null || g2d_onDoubleMouseClick != null) {
                        if (g2d_onMouseClick != null) g2d_onMouseClick.dispatch(mouseInput);
                        if (g2d_lastClickTime>0 && p_input.time-g2d_lastClickTime<GMouseInput.DOUBLE_CLICK_TIME) {
                            if (g2d_onDoubleMouseClick != null) g2d_onDoubleMouseClick.dispatch(mouseInput);
                            g2d_lastClickTime = -1;
                        } else {
                            g2d_lastClickTime = p_input.time;
                        }
                    }

                // RIGHT BUTTON
                /*
                case GMouseInputType.RIGHT_MOUSE_DOWN:
                    if (mouseEnabled) {
                        g2d_rightMouseDownElement = p_dispatcher;
                        if (g2d_onRightMouseDown != null) g2d_onRightMouseDown.dispatch(mouseInput);
                    }
                case GMouseInputType.RIGHT_MOUSE_UP:
                    if (g2d_rightMouseDownElement == this) {
                        if (g2d_rightMouseDownElement == p_element && g2d_onRightMouseClick != null) {
                            var mouseClickInput:GMouseInput = p_input.clone(this, p_target, GMouseInputType.RIGHT_MOUSE_UP);
                            if (g2d_onRightMouseClick != null) g2d_onRightMouseClick.dispatch(mouseClickInput);
                        }
                        g2d_rightMouseDownElement = null;
                        if (g2d_onRightMouseUp != null) g2d_onRightMouseUp.dispatch(mouseInput);
                    }
                /**/
                // WHEEL
                case GMouseInputType.MOUSE_WHEEL:
                    if (mouseEnabled && g2d_onMouseWheel != null) g2d_onMouseWheel.dispatch(mouseInput);
            }
        }

        if (parent != null) {
            parent.g2d_dispatchMouseCallback(p_type, mouseEnabled?p_target:parent, p_dispatcher, p_input, true);
        }
    }
	
	public function setState(p_stateName:String):Void {
		setPrototypeState(p_stateName);
		if (g2d_children != null) {
			for (child in g2d_children) {
				child.setState(p_stateName);
			}
		}
        if (g2d_onStateChanged != null) g2d_onStateChanged.dispatch(p_stateName);
	}
	
	public function getState():String {
		return g2d_currentState;
	}

    public function hasState(p_stateName:String):Bool {
        if (g2d_prototypeStates == null) return false;
        return g2d_prototypeStates.hasState(p_stateName);
    }

    private function gotFocus():Void {

    }

    private function lostFocus():Void {

    }
	
	private function skinChanged_handler(p_skinId:String):Void {
		if (g2d_skin != null && g2d_skin.id == p_skinId) {
			var t = GUISkinManager.getSkin(p_skinId);
			skin = GUISkinManager.getSkin(p_skinId);
		}
	}
}
