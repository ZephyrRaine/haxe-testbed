package sample;

import h2d.Tile;
import h2d.TileGroup;

class Building extends Entity {
    public function new(b:Entity_Building) {
        super(b.cx,b.cy);
        
        var bitmap = new h2d.Bitmap(b.getTile(), spr);
        bitmap.tile.setCenterRatio(0.5,1);
    }
}