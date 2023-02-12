package ui;

import h2d.Tile;

class ShipPopUp extends ui.win.Menu
{
    public function new(name:String, description:String, yes:Void->Void) {
        super(true);
        this.mask.backgroundTile = Tile.fromColor(0x0,1,1,0.6);
        
        addTitle('$name menu');
        addTitle(description);
        addButton("Yes", yes, true);
        addButton("No", fuckIt, true);
		hxd.Res.sounds.sfx.Ship_Open.play(false, 0.9);
    }

    public function fuckIt()
    {

    }
}