package en;

import h2d.Bitmap;
import ui.BuildingPopUp;
import h2d.Tile;
import h2d.TileGroup;

class Building extends Entity {

	public static var ALL : Array<Building> = [];

    public var name : String;


    public function new(b:Entity_Building) {
        super(b.cx,b.cy);

        ALL.push(this);

        set_wid(b.width);
        set_hei(b.height);
        name = b.f_Name;
        var bitmap = new h2d.Bitmap(b.getTile(), spr);
        bitmap.tile.setCenterRatio(0.5,1);
        

    }

    override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function displayPopUp() {
        new BuildingPopUp(name, ()->{
            hud.notify("Clicked yes");
        }, 
        ()->{
            hud.notify("Clicked no");
        });
    }
}