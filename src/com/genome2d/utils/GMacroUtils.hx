package com.genome2d.utils;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author qw01_01
 */

class GMacroUtils
{	
	private static function buildConstExpr(name,pos) {
		return { expr:EConst(CIdent(name)), pos:pos };
	}
	
	macro public static function createProps():Array<Field>{
		var res = Context.getBuildFields();
		var p = Context.currentPos();
		var isSwc = Context.defined('swc');
		
		for (e in res) {
			switch(e.kind) {
				case FVar(t, v):
					p = v.pos;
					for (o in e.meta)
						if (o.name == 'prop') {
							switch (v.expr) 
							{
								case EObjectDecl(fields):					
									var access = [AInline];
									if (e.access.indexOf(AStatic) > -1) {
										access.push(AStatic);
									}
									
									var hasSet = false, hasGet = false;
									for (field in fields) {
										var p = field.expr.pos;
										if (field.field == 'set') {
											var swcSetMeta = isSwc?[ { name:':setter', params:[buildConstExpr(e.name, p)], pos:p } ]:null;
											var setter =  { 
												kind : FFun( { 
													args : [ { name : 'value', type : t, opt : false, value : null } ], 
													expr : { expr : EBlock([field.expr, { expr:EReturn(buildConstExpr('value', p)), pos:p } ]), pos : p }, 
													params : [],
													ret : null
												} ),
												meta : swcSetMeta,
												name : 'set_'+e.name,
												doc : null, 
												pos : p, 
												access : access.copy()
											}
											res.push(setter);
											hasSet = true;
										}
										else if (field.field == 'get') {
											var swcGetMeta = isSwc?[ { name:':getter', params:[buildConstExpr(e.name, p)], pos:p } ]:null;
											var getter =  { 
												kind : FFun( { 
													args : [], 
													expr : field.expr,
													params : [],
													ret : null
												} ),
												meta : swcGetMeta,
												name : 'get_'+e.name,
												doc : null, 
												pos : p, 
												access : access.copy()
											}
											res.push(getter);
											hasGet = true;
										}
									}
									e.kind = FProp(hasGet?'get':'never', hasSet?'set':'never', t);
									access[0] = APublic;
									e.access = access.copy();
									e.meta = isSwc?[ { name:':extern', params:null, pos:p } ]:null;
								default:
									Context.error('error', p);
							}
							break;
						}
				default: 
					continue;
			}
		}
		return res;
	}
}