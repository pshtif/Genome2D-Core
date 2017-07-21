package com.genome2d.ui.skin;
import com.genome2d.particles.GParticleSystem;

class GUIParticleSkin extends GUISkin {
    @prototype
    public var particleSystem:GParticleSystem;

    override public function getMinWidth():Float {
        return 0;
    }

    override public function getMinHeight():Float {
        return 0;
    }

    public function new(p_id:String = "", p_particleSystem:GParticleSystem = null, p_origin:GUIParticleSkin = null) {
        super(p_id, p_origin);

        particleSystem = p_particleSystem;
        if (g2d_origin == null) Genome2D.getInstance().onUpdate.add(update_handler);
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Bool {
        particleSystem.x = p_left + (p_right - p_left)/2;
        particleSystem.y = p_top + (p_bottom - p_top)/2;

        var rendered:Bool = false;
        if (super.render(p_left, p_top, p_right, p_bottom, p_red, p_green, p_blue, p_alpha)) {
            particleSystem.render(Genome2D.getInstance().getContext());
            rendered = true;
        }
        return rendered;
    }

    private function update_handler(p_deltaTime:Float):Void {
        particleSystem.update(p_deltaTime);
    }

    override public function clone():GUISkin {
        var clone:GUIParticleSkin = new GUIParticleSkin("", particleSystem, (g2d_origin == null)?this:cast g2d_origin);
        clone.red = red;
        clone.green = green;
        clone.blue = blue;
        clone.alpha = alpha;
        return clone;
    }

    override public function dispose():Void {
        if (g2d_origin == null) Genome2D.getInstance().onUpdate.remove(update_handler);

        super.dispose();
    }
}
