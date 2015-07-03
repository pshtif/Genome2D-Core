/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.element;
import com.genome2d.context.GCamera;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.ui.skin.GUISkin;

@:access(com.genome2d.ui.skin.GUISkin)
@prototypeName("list")
class GUIElementList extends GUIElement
{
	public var listItemPrototype:Xml;
		
	override public function setModel(p_value:Dynamic):Void {
		disposeChildren();
		if (listItemPrototype != null) {
			if (Std.is(p_value, Xml)) {
				var xml:Xml = cast (p_value, Xml);
				var it:Iterator<Xml> = xml.elements();
				while (it.hasNext()) {
					var child:GUIElement = cast GPrototypeFactory.createPrototype(listItemPrototype);
					child.setModel(it.next());
					addChild(child);
				}
				/**/
			} else if (Std.is(p_value,Array) && listItemPrototype != null) {
				disposeChildren();
				var it:Iterator<Dynamic> = cast (p_value,Array<Dynamic>).iterator();
				while (it.hasNext()) {
					var child:GUIElement = cast GPrototypeFactory.createPrototype(listItemPrototype);
					child.setModel(it.next());
					addChild(child);
				}
			}
		}
		
        onModelChanged.dispatch(this);
    }
	
	override public function render(p_red:Float = 1, p_green:Float = 1, p_blue:Float = 1, p_alpha:Float = 1):Void {
        if (visible) {
			var context:IGContext = Genome2D.getInstance().getContext();
			var previousMask:GRectangle = context.getMaskRect();
			var camera:GCamera = context.getActiveCamera();
			
			var worldRed:Float = p_red * red;
			var worldGreen:Float = p_green * green;
			var worldBlue:Float = p_blue * blue;
			var worldAlpha:Float = p_alpha * alpha;
			
            if (flushBatch || !expand) GUISkin.flushBatch();
			if (!expand) {
				context.setMaskRect(new GRectangle(g2d_worldLeft*camera.scaleX, g2d_worldTop*camera.scaleY, (g2d_worldRight - g2d_worldLeft)*camera.scaleX, (g2d_worldBottom - g2d_worldTop)*camera.scaleY));
			}
			
            if (g2d_activeSkin != null) g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom, worldRed, worldGreen, worldBlue, worldAlpha);

            for (i in 0...g2d_numChildren) {
				var child:GUIElement = g2d_children[i];
				if (child.g2d_worldLeft<parent.g2d_worldRight && child.g2d_worldRight>parent.g2d_worldLeft) {// && child.g2d_worldTop<g2d_worldBottom && child.g2d_worldBottom>g2d_worldTop) {
					child.render(worldRed, worldGreen, worldBlue, worldAlpha);
				}
            }
			
			if (!expand) context.setMaskRect(previousMask);
        }
    }
	
	override public function getPrototype(p_prototypeXml:Xml = null):Xml {
		if (p_prototypeXml == null) p_prototypeXml = Xml.createElement(PROTOTYPE_NAME);
		
        super.getPrototype(p_prototypeXml);
		
		if (listItemPrototype != null) {
			var xml:Xml = Xml.createElement("prototype");
			xml.addChild(listItemPrototype);
			p_prototypeXml.addChild(xml);
		}

        return p_prototypeXml;
    }

    override public function bindPrototype(p_prototypeXml:Xml):Void {
		super.bindPrototype(p_prototypeXml);
		
		var prototype:Xml = p_prototypeXml.elementsNamed("prototype").next();
		if (prototype != null && prototype.elements().hasNext()) {
			listItemPrototype = prototype.elements().next();
		}
    }
}