package com.genome2d;
import com.genome2d.assets.GAsset;
import com.genome2d.context.GContextConfig;
class GProject {
    private var g2d_genome:Genome2D;
    private var g2d_assets:Array<GAsset>;

    public function new() {
        initGenome();
    }

    /**
        Initialize Genome2D
     **/
    private function initGenome():Void {
        g2d_genome = Genome2D.getInstance();

        g2d_genome.onFailed.addOnce(genomeFailed_handler);
        g2d_genome.onInitialized.addOnce(genomeInitialized_handler);
        //g2d_genome.init(new GContextConfig());
    }

    private function genomeFailed_handler(p_msg:String):Void {

    }

    private function genomeInitialized_handler():Void {
        initAssets();
    }

    private function initAssets():Void {

    }
}
