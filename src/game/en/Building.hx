package en;

import sample.GameManager;
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
        spr.useCustomTile(b.getTile());
    }

    override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function displayPopUp() {
        new BuildingPopUp(name, getYesAction(), 
        ()->{
            hud.notify("Clicked no");
        });
    }

    public function getYesAction() : Void->Void
    {
        switch(name)
        {
            case "Ship":
                return ()->{cast(Game.ME, GameManager).switchToExploration();};
        }

        return ()->hud.notify("Clicked yes");
    }
}