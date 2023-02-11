package ui;

import h2d.Tile;

class BuildingPopUp extends ui.win.Menu
{
    public function new(name:String, yes:Void->Void, no:Void->Void) {
        super(true);
        this.mask.backgroundTile = Tile.fromColor(0x0,1,1,0.6);
        addTitle('$name menu');
		addButton("Yes", yes, true);
        addButton("No", no, true);
    }
}