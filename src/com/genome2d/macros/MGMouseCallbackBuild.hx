/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

class MGMouseCallbackBuild {
    macro public static function build():Array<Field> {
        var fields = Context.getBuildFields();

        var pos = Context.currentPos();
        var fieldNames = ["onMouseWheel", "onDoubleMouseClick", "onMouseDown", "onMouseUp", "onMouseMove", "onMouseOver", "onMouseOut", "onRightMouseDown", "onRightMouseUp", "onMouseClick", "onRightMouseClick"];

        for (fieldName in fieldNames) {

            var getterFunc:Function = {
                expr: macro return {
                    if ($i{"g2d_"+fieldName} == null) $i{"g2d_"+fieldName} = new GCallback1(GMouseInput);
                    return $i{"g2d_"+fieldName};
                },  // actual value
                ret: (macro:GCallback1<GMouseInput>), // return type
                args:[]
            }

            var privateField:Field = {
                name:  "g2d_"+fieldName,
                access:  [Access.APrivate],
                kind: FieldType.FVar(macro:GCallback1<GMouseInput>),
                pos: pos
            };

            var propertyField:Field = {
                name:  fieldName,
                access: [Access.APublic],
                kind: FieldType.FProp("get", "never", getterFunc.ret),
                #if swc
                meta: [{name:":extern", pos: pos}],
                #end
                pos: pos
            };

            var getterField:Field = {
                name: "get_" + fieldName,
                access: [Access.APrivate, Access.AInline],
                kind: FieldType.FFun(getterFunc),
                #if swc
                meta: [{name:":getter", params : [ { expr:EConst(CIdent(fieldName)), pos:Context.currentPos() } ], pos: pos}],
                #end
                pos: pos
            };

            fields.push(privateField);
            fields.push(propertyField);
            fields.push(getterField);
        }

        return fields;
    }
}
#end