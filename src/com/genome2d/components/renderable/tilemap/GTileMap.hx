package com.genome2d.components.renderable.tilemap;

import com.genome2d.tilemap.GTile;
import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.context.GBlendMode;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.debug.GDebug;
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

    public function setTiles(p_mapWidth:Int, p_mapHeight:Int, p_tileWidth:Int, p_tileHeight:Int, p_tiles:Array<GTile> = null,  p_iso:Bool = false):Void {
        if (p_tiles != null && p_mapWidth*p_mapHeight != p_tiles.length) GDebug.error("Incorrect number of tiles provided for that map size.");

        g2d_width = p_mapWidth;
        g2d_height = p_mapHeight;
        g2d_tileWidth = p_tileWidth;
        g2d_tileHeight = p_tileHeight;
        if (p_tiles != null) {
            g2d_tiles = p_tiles;
        } else {
            g2d_tiles = new Array<GTile>();
            for (i in 0...g2d_width*g2d_height) g2d_tiles.push(null);
        }
        g2d_iso = p_iso;
    }
	
	public function getTile(p_tileIndex:Int):GTile {
		if (p_tileIndex < 0 || p_tileIndex >= g2d_tiles.length) GDebug.error("Tile index out of bounds.");
		return g2d_tiles[p_tileIndex];
	}

    public function setTile(p_tileIndex:Int, p_tile:GTile):Void {
        if (p_tileIndex<0 || p_tileIndex>= g2d_tiles.length) GDebug.error("Tile index out of bounds.");
        if (p_tile != null && (p_tile.mapX!=-1 || p_tile.mapY!=-1) && (p_tile.mapX+p_tile.mapY*g2d_width != p_tileIndex)) GDebug.error("Tile map position doesn't match its index.");

        if (p_tile != null) {
            for (i in 0...p_tile.sizeX) {
                for (j in 0...p_tile.sizeY) {
                    if (g2d_tiles[p_tileIndex+i+j*g2d_width] != null) removeTile(p_tileIndex+i+j*g2d_width);
                    g2d_tiles[p_tileIndex+i+j*g2d_width] = p_tile;
                }
            }
        } else {
            removeTile(p_tileIndex);
        }
    }

    public function removeTile(p_tileIndex:Int):Void {
        if (p_tileIndex<0 || p_tileIndex>= g2d_tiles.length) GDebug.error("Tile index out of bounds.");
        var tile:GTile = g2d_tiles[p_tileIndex];
        if (tile != null) {
            if (tile.mapX != -1 && tile.mapY != -1) {
                for (i in 0...tile.sizeX) {
                    for (j in 0...tile.sizeY) {
                        if (g2d_tiles[tile.mapX+i+(tile.mapY+j)*g2d_width] == tile) g2d_tiles[tile.mapX+i+(tile.mapY+j)*g2d_width] = null;
                    }
                }
            } else {
                g2d_tiles[p_tileIndex] = null;
            }
        }
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        if (g2d_tiles == null) return;

        var mapHalfWidth:Float = g2d_tileWidth * g2d_width * .5;
        var mapHalfHeight:Float = g2d_tileHeight * g2d_height * (g2d_iso ? .25 : .5);

        // Position of top left visible tile from 0,0
        var viewRect:GRectangle = node.core.getContext().getStageViewRect();
        var cameraWidth:Float = viewRect.width*p_camera.normalizedViewWidth / p_camera.scaleX;
        var cameraHeight:Float = viewRect.height*p_camera.normalizedViewHeight / p_camera.scaleY;
        var startX:Float =	p_camera.x - g2d_node.g2d_worldX - cameraWidth *.5 - horizontalMargin;
        var startY:Float = p_camera.y - g2d_node.g2d_worldY - cameraHeight *.5 - verticalMargin;
        // Position of top left tile from map center
        var firstX:Float = -mapHalfWidth + (g2d_iso ? g2d_tileWidth/2 : 0);
        var firstY:Float = -mapHalfHeight + (g2d_iso ? g2d_tileHeight/2 : 0);

        // Index of top left visible tile
        var indexX:Int = Std.int((startX - firstX) / g2d_tileWidth);
        if (indexX<0) indexX = 0;
        var indexY:Int = Std.int((startY - firstY) / (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight));
        if (indexY<0) indexY = 0;

        // Position of bottom right tile from map center
        var endX:Float = p_camera.x - g2d_node.g2d_worldX + cameraWidth * .5 - (g2d_iso ? g2d_tileWidth/2 : g2d_tileWidth) + horizontalMargin;
        var endY:Float = p_camera.y - g2d_node.g2d_worldY + cameraHeight * .5 - (g2d_iso ? 0 : g2d_tileHeight) + verticalMargin;

        var indexWidth:Int = Std.int((endX - firstX) / g2d_tileWidth - indexX+2);
        if (indexWidth>g2d_width-indexX) indexWidth = g2d_width - indexX;

        var indexHeight:Int = Std.int((endY - firstY) / (g2d_iso ? g2d_tileHeight / 2 : g2d_tileHeight) - indexY + 2);
        if (indexHeight > g2d_height - indexY) indexHeight = g2d_height - indexY;
		
        var tileCount:Int = indexWidth*indexHeight;
        for (i in 0...tileCount) {
            var row:Int = Std.int(i / indexWidth);
            var x:Float = g2d_node.g2d_worldX + (indexX + (i % indexWidth)) * g2d_tileWidth - mapHalfWidth + (g2d_iso && (indexY+row)%2 == 1 ? g2d_tileWidth : g2d_tileWidth/2);
            var y:Float = g2d_node.g2d_worldY + (indexY + row) * (g2d_iso ? g2d_tileHeight/2 : g2d_tileHeight) - mapHalfHeight + g2d_tileHeight/2;

            var index:Int = indexY * g2d_width + indexX + Std.int(i / indexWidth) * g2d_width + i % indexWidth;
            var tile:GTile = g2d_tiles[index];
            // TODO: All transforms
            if (tile != null && tile.texture != null) {
                var frameId:Int = node.core.getCurrentFrameId();
                var time:Float = node.core.getRunTime();
                if (tile.sizeX != 1 || tile.sizeY != 1) {
                    if (tile.lastFrameRendered != frameId) {
                        x -= (indexX +  i % indexWidth - tile.mapX) * g2d_tileWidth;// - (tile.sizeX - 1) * g2d_tileWidth / 2;
                        y -= (indexY + row - tile.mapY) * g2d_tileHeight;// - (tile.sizeY - 1) * g2d_tileHeight / 2;
                        tile.render(node.core.getContext(), x, y, frameId, time, blendMode);
                    }
                } else {
                    tile.render(node.core.getContext(), x, y, frameId, time, blendMode);
                }
            }
        }
    }

    public function getTileAt(p_x:Float, p_y:Float, p_camera:GCamera = null):GTile {
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

        var tx:Float = p_camera.x - g2d_node.g2d_worldX + p_x;
        var ty:Float = p_camera.y - g2d_node.g2d_worldY + p_y;

        var indexX:Int = Math.floor((tx - firstX) / (g2d_tileWidth * p_camera.scaleX));
        var indexY:Int = Math.floor((ty - firstY) / (g2d_tileHeight * p_camera.scaleY));

        if (indexX<0 || indexX>=g2d_width || indexY<0 || indexY>=g2d_height) return null;
        return g2d_tiles[indexY*g2d_width+indexX];
    }

    public function captureMouseInput(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextInput:GMouseInput):Bool {
        if (p_captured && p_contextInput.type == GMouseInputType.MOUSE_UP) node.g2d_mouseDownNode = null;

        if (p_captured || node.g2d_worldScaleX == 0 || node.g2d_worldScaleY == 0) {
            if (node.g2d_mouseOverNode == node) node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, 0, 0, p_contextInput);
            return false;
        }

        // Invert translations
        var tx:Float = p_cameraX - node.g2d_worldX;
        var ty:Float = p_cameraY - node.g2d_worldY;

        if (node.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.g2d_worldRotation);
            var sin:Float = Math.sin(-node.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.g2d_worldScaleX*g2d_width*g2d_tileWidth;
        ty /= node.g2d_worldScaleY*g2d_height*g2d_tileHeight;
        tx += .5;
        ty += .5;

        if (tx >= 0 && tx <= 1 && ty >= 0 && ty <= 1) {
            node.dispatchMouseCallback(p_contextInput.type, node, tx*g2d_width*g2d_tileWidth, ty*g2d_height*g2d_tileHeight, p_contextInput);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OVER, node, tx*g2d_width*g2d_tileWidth, ty*g2d_height*g2d_tileHeight, p_contextInput);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, tx*g2d_width*g2d_tileWidth, ty*g2d_height*g2d_tileHeight, p_contextInput);
            }
        }

        return false;
    }

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        return null;
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
		p_x /= g2d_width*g2d_tileWidth;
        p_y /= g2d_height*g2d_tileHeight;
		
        p_x += .5;
        p_y += .5;        

        return (p_x >= 0 && p_x <= 1 && p_y >= 0 && p_y <= 1);
    }
}