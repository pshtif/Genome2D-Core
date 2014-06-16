/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.geom;

class GMatrixUtils {
    inline static public function prependMatrix(p_matrix:GMatrix, p_by:GMatrix):Void {
        p_matrix.setTo(p_matrix.a * p_by.a + p_matrix.c * p_by.b,
                       p_matrix.b * p_by.a + p_matrix.d * p_by.b,
                       p_matrix.a * p_by.c + p_matrix.c * p_by.d,
                       p_matrix.b * p_by.c + p_matrix.d * p_by.d,
                       p_matrix.tx + p_matrix.a * p_by.tx + p_matrix.c * p_by.ty,
                       p_matrix.ty + p_matrix.b * p_by.tx + p_matrix.d * p_by.ty);
    }
}
