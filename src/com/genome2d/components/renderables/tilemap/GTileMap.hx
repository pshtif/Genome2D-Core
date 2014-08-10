package com.genome2d.components.renderables.tilemap;

import com.genome2d.context.GBlendMode;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;
import com.genome2d.error.GError;
import com.genome2d.node.GNode;

class GTileMap extends GComponent implements IRenderable
{
    public var blendMode:Int = GBlendMode.NORMAL;

    private var g2d_width:Int;
    private var g2d_height:Int;
    private var g2d_tiles:Array<GTile>;
    public function getTiles():Array<GTile> {
        return g2d_tiles;
    }

    private var mustRenderTiles:Array<GTile>;

    private var g2d_tileWidth:Int = 0;
    private var g2d_tileHeight:Int = 0;
    private var g2d_iso:Bool = false;

    public var horizontalMargin:Float = 0;
    public var verticalMargin:Float = 0;

    public function setTiles(p_tiles:Array<GTile>, p_mapWidth:Int, p_mapHeight:Int, p_tileWidth:Int, p_tileHeight:Int,  p_iso:Bool = false):Void {
        if (p_mapWidth*p_mapHeight != p_tiles.length) new GError("Not enough tiles provided for that map size.");
    
        g2d_tiles = p_tiles;
        g2d_width = p_mapWidth;
        g2d_height = p_mapHeight;
        g2d_iso = p_iso;

        g2d_tileWidth = p_tileWidth;
        g2d_tileHeight = p_tileHeight;
    }

    public function setTile(p_tileIndex:Int, p_tile:GTile):Void {
        if (p_tileIndex<0 || p_tileIndex>= g2d_tiles.length) return;
        g2d_tiles[p_tileIndex] = p_tile;
    }

    public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
        if (g2d_tiles == null) return;

        var mapHalfWidth:Float = g2d_tileWidth * g2d_width * .5;
        var mapHalfHeight:Float = g2d_tileHeight * g2d_height * (g2d_iso ? .25 : .5);

        // Position of top left visible tile from 0,0
        var viewRect:GRectangle = node.core.getContext().getStageViewRect();
        var cameraWidth:Float = viewRect.width*p_camera.normalizedViewWidth / p_camera.scaleX;
        var cameraHeight:Float = viewRect.height*p_camera.normalizedViewHeight / p_camera.scaleY;
        var startX:Float =	p_camera.x - g2d_node.transform.g2d_worldX - cameraWidth *.5 - horizontalMargin;
        var startY:Float = p_camera.y - g2d_node.transform.g2d_worldY - cameraHeight *.5 - verticalMargin;
        // Position of top left tile from map center
        var firstX:Float = -mapHalfWidth + (g2d_iso ? g2d_tileWidth/2 : 0);
        var firstY:Float = -mapHalfHeight + (g2d_iso ? g2d_tileHeight/2 : 0);

        // Index of top left visible tile
        var indexX:Int = Std.int((startX - firstX) / g2d_tileWidth);
        if (indexX<0) indexX = 0;
        var indexY:Int = Std.int((startY - firstY) / (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight));
        if (indexY<0) indexY = 0;

        // Position of bottom right tile from map center
        var endX:Float = p_camera.x - g2d_node.transform.g2d_worldX + cameraWidth * .5 - (g2d_iso ? g2d_tileWidth/2 : g2d_tileWidth) + horizontalMargin;
        var endY:Float = p_camera.y - g2d_node.transform.g2d_worldY + cameraHeight * .5 - (g2d_iso ? 0 : g2d_tileHeight) + verticalMargin;

        var indexWidth:Int = Std.int((endX - firstX) / g2d_tileWidth - indexX+2);
        if (indexWidth>g2d_width-indexX) indexWidth = g2d_width - indexX;

        var indexHeight:Int = Std.int((endY - firstY) / (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight) - indexY+2);
        if (indexHeight>g2d_height-indexY) indexHeight = g2d_height - indexY;
        //trace(indexX, indexY, indexWidth, indexHeight);
        var tileCount:Int = indexWidth*indexHeight;
        for (i in 0...tileCount) {
            var row:Int = Std.int(i / indexWidth);
            var x:Float = g2d_node.transform.g2d_worldX + (indexX + (i % indexWidth)) * g2d_tileWidth - mapHalfWidth + (g2d_iso && (indexY+row)%2 == 1 ? g2d_tileWidth : g2d_tileWidth/2);
            var y:Float = g2d_node.transform.g2d_worldY + (indexY + row) * (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight) - mapHalfHeight + g2d_tileHeight/2;

            var index:Int = indexY * g2d_width + indexX + Std.int(i / indexWidth) * g2d_width + i % indexWidth;
            var tile:GTile = g2d_tiles[index];
            // TODO: All transforms
            if (tile != null && tile.texture != null) {
                var frameId:Int = node.core.getCurrentFrameId();
                var time:Float = node.core.getRunTime();
                if (tile.rows != 1 || tile.cols != 1) {
                    if (tile.g2d_lastFrameRendered != frameId) {
                        x -= (indexX +  i % indexWidth - tile.mapX) * g2d_tileWidth;
                        y -= (indexY+row-tile.mapY) * g2d_tileHeight;
                        tile.render(node.core.getContext(), x, y, frameId, time, blendMode);
                    }
                } else {
                    tile.render(node.core.getContext(), x, y, frameId, time, blendMode);
                }
            }
        }
    }

    public function getTileAt(p_x:Float, p_y:Float, p_camera:GContextCamera = null):GTile {
        if (p_camera == null) p_camera = node.core.getContext().getDefaultCamera();

        var viewRect:GRectangle = node.core.getContext().getStageViewRect();
        var cameraX:Float = viewRect.width*p_camera.normalizedViewX;
        var cameraY:Float = viewRect.height*p_camera.normalizedViewY;
        var cameraWidth:Float = viewRect.width*p_camera.normalizedViewWidth;
        var cameraHeight:Float = viewRect.height*p_camera.normalizedViewHeight;
        p_x -= cameraX + cameraWidth*.5;
        p_y -= cameraY + cameraHeight*.5;

        var mapHalfWidth:Float = (g2d_tileWidth * p_camera.scaleX) * g2d_width * .5;
        var mapHalfHeight:Float = (g2d_tileHeight * p_camera.scaleY) * g2d_height * (g2d_iso ? .25 : .5);

        var firstX:Float = -mapHalfWidth + (g2d_iso ? (g2d_tileWidth * p_camera.scaleX) / 2 : 0);
        var firstY:Float = -mapHalfHeight + (g2d_iso ? (g2d_tileHeight * p_camera.scaleY) / 2 : 0);

        var tx:Float = p_camera.x - g2d_node.transform.g2d_worldX + p_x;
        var ty:Float = p_camera.y - g2d_node.transform.g2d_worldY + p_y;

        var indexX:Int = Math.floor((tx - firstX) / (g2d_tileWidth * p_camera.scaleX));
        var indexY:Int = Math.floor((ty - firstY) / (g2d_tileHeight * p_camera.scaleY));

        if (indexX<0 || indexX>=g2d_width || indexY<0 || indexY>=g2d_height) return null;
        return g2d_tiles[indexY*g2d_width+indexX];
    }

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        return null;
    }
}