/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.element;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.element.GUIElement;

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