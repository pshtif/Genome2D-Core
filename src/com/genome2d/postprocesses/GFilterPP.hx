/*
 * 	Genome2D - GPU 2D framework utilizing Molehill API
 *
 *	Copyright 2012 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.postprocesses;

import com.genome2d.context.filters.GFilter;

class GFilterPP extends GPostProcess
{
    public function new(p_filters:Array<GFilter>) {
        super(p_filters.length);

        g2d_passFilters = p_filters;
    }
}