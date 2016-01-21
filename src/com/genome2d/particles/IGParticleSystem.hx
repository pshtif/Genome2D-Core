package com.genome2d.particles;
import com.genome2d.context.IGContext;

/**
 * @author Peter @sHTiF Stefcek
 */

interface IGParticleSystem 
{
	function update(p_deltaTime:Float):Void;
	function render(p_context:IGContext):Void;
}