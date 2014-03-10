package com.genome2d.assets;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
import msignal.Signal.Signal0;

class GAssetManager {
    private var g2d_assetsQueue:Array<GAsset>;
    private var g2d_loading:Bool;
    private var g2d_assets:Array<GAsset>;

    public var onLoaded:Signal0;

    public function new() {
        g2d_assetsQueue = new Array<GAsset>();
        g2d_assets = new Array<GAsset>();

        onLoaded = new Signal0();
    }

    public function getAssetById(p_id:String):GAsset {
        for (i in 0...g2d_assets.length) {
            var asset:GAsset = g2d_assets[i];
            if (asset.id == p_id) return asset;
        }
        return null;
    }

    public function getXmlAssetById(p_id:String):GXmlAsset {
        var asset:GAsset = getAssetById(p_id);
        if (Std.is(asset, GXmlAsset)) return cast asset;
        return null;
    }

    public function getImageAssetById(p_id:String):GImageAsset {
        var asset:GAsset = getAssetById(p_id);
        if (Std.is(asset, GImageAsset)) return cast asset;
        return null;
    }

    public function add(p_asset:GAsset):Void {
        g2d_assetsQueue.push(p_asset);
    }

    public function load():Void {
        if (g2d_loading) return;
        g2d_loadNext();
    }

    private function g2d_loadNext():Void {
        if (g2d_assetsQueue.length==0) {
            g2d_loading = false;
            onLoaded.dispatch();
        } else {
            g2d_loading = true;
            var asset:GAsset = g2d_assetsQueue.shift();
            asset.onLoaded.addOnce(g2d_hasAssetLoaded);
            asset.load();
        }
    }

    private function g2d_hasAssetLoaded(p_asset:GAsset):Void {
        g2d_assets.push(p_asset);
        g2d_loadNext();
    }
}
