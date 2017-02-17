package com.genome2d.project;

import com.genome2d.macros.MGDebug;
import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GContextConfig;
import com.genome2d.assets.GAsset;

class GProject {
    private var g2d_genome:Genome2D;
    public function getGenome():Genome2D {
        return g2d_genome;
    }

    private var g2d_config:GProjectConfig;

    private var g2d_assetManager:GAssetManager;

    public function new(p_config:GProjectConfig) {
        MGDebug.INFO();
        g2d_config = p_config;

        g2d_genome = Genome2D.getInstance();
        if (g2d_config.initGenome) {
            initGenome();
        } else {
            init();
        }
    }

    /**
     *  Initialize Genome2D
     **/
    private function initGenome():Void {
        MGDebug.INFO();

        g2d_genome.onFailed.addOnce(genomeFailed_handler);
        g2d_genome.onInitialized.addOnce(genomeInitialized_handler);
        g2d_genome.init(g2d_config.contextConfig);
    }

    private function init():Void {

    }

    /**
     *  Handlers
     **/
    private function genomeInitialized_handler():Void {
        g2d_assetManager = new GAssetManager();

        init();
    }

    private function genomeFailed_handler(p_msg:String):Void {

    }
}
