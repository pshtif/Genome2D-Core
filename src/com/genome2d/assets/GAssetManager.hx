/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.assets;

import com.genome2d.callbacks.GCallback;
import com.genome2d.textures.GTextureManager;

class GAssetManager {
    static public var PATH_REGEX:EReg = ~/([^\?\/\\]+?)(?:\.([\w\-]+))?(?:\?.*)?$/;

    static public var ignoreFailed:Bool = false;

    static private var g2d_references:Map<String,GAsset>;
    static public function getAssets():Map<String,GAsset> {
        return g2d_references;
    }

    static private var g2d_loadQueue:Array<GAsset>;

    static private var g2d_loading:Bool;
    static public function isLoading():Bool {
        return g2d_loading;
    }

    static private var g2d_onQueueLoaded:GCallback0;
    #if swc @:extern #end
    static public var onQueueLoaded(get,never):GCallback0;
    #if swc @:getter(onQueueLoaded) #end
    inline static private function get_onQueueLoaded():GCallback0 {
        return g2d_onQueueLoaded;
    }

    static private var g2d_onQueueFailed:GCallback1<GAsset>;
    #if swc @:extern #end
    static public var onQueueFailed(get,never):GCallback1<GAsset>;
    #if swc @:getter(onQueueFailed) #end
    inline static private function get_onQueueFailed():GCallback1<GAsset> {
        return g2d_onQueueFailed;
    }

    static public function init() {
        g2d_loadQueue = new Array<GAsset>();
        g2d_references = new Map<String,GAsset>();

        g2d_onQueueLoaded = new GCallback0();
        g2d_onQueueFailed = new GCallback1(GAsset);
    }

    static public function getAssetById(p_id:String):GAsset {
        return g2d_references.get(p_id);
    }

    static public function getXmlAssetById(p_id:String):GXmlAsset {
        return cast g2d_references.get(p_id);
    }

    static public function getImageAssetById(p_id:String):GImageAsset {
        return cast g2d_references.get(p_id);
    }

    static public function addFromUrl(p_url:String, p_id:String = ""):GAsset {
        switch (getFileExtension(p_url)) {
            case "jpg" | "jpeg" | "png" | "atf":
                return new GImageAsset(p_url, p_id);
            case "xml" | "fnt":
                return new GXmlAsset(p_url, p_id);
        }

        return null;
    }

    static public function loadQueue():Void {
        for (asset in g2d_references) {
            if (!asset.isLoaded()) g2d_loadQueue.push(asset);
        }
        if (!g2d_loading) g2d_loadQueueNext();
    }

    static private function g2d_loadQueueNext():Void {
        if (g2d_loadQueue.length==0) {
            g2d_loading = false;
            g2d_onQueueLoaded.dispatch();
        } else {
            g2d_loading = true;
            var asset:GAsset = g2d_loadQueue.shift();

            asset.onLoaded.addOnce(g2d_assetLoaded_handler);
            asset.onFailed.addOnce(g2d_assetFailed_handler);
            asset.load();
        }
    }

    inline static private function getFileName(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(1);
    }

    inline static private function getFileExtension(p_path:String):String {
        PATH_REGEX.match(p_path);
        return PATH_REGEX.matched(2);
    }

    static private function g2d_assetLoaded_handler(p_asset:GAsset):Void {
        g2d_loadQueueNext();
    }

    static private function g2d_assetFailed_handler(p_asset:GAsset):Void {
        g2d_onQueueFailed.dispatch(p_asset);
        if (ignoreFailed) g2d_loadQueueNext();
    }

    static public function generateTextures(p_scaleFactor:Float = 1):Void {
        for (asset in g2d_references) {
            if (!Std.is(asset,GImageAsset) || !asset.isLoaded()) continue;
            if (GTextureManager.getContextTextureById(asset.id) != null) continue;
            var idPart:String = asset.id.substring(0,asset.id.length-3);
            if (GAssetManager.getXmlAssetById(idPart+"xml") != null) {
                GTextureManager.createAtlasFromAssets(asset.id, cast asset, GAssetManager.getXmlAssetById(idPart+"xml"), p_scaleFactor);
            } else if (GAssetManager.getXmlAssetById(idPart+"fnt") != null) {
                GTextureManager.createFontAtlasFromAssets(asset.id, cast asset, GAssetManager.getXmlAssetById(idPart+"fnt"), p_scaleFactor);
            } else {
                GTextureManager.createTextureFromAsset(asset.id, cast asset, p_scaleFactor);
            }
        }
    }
}
