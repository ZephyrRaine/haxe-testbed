package en;

import ui.ShipPopUp;
import sample.GameManager;
import h2d.Bitmap;
import ui.BuildingPopUp;
import h2d.Tile;
import h2d.TileGroup;

class Ship extends Entity 
{
	public static var Instance : Ship;

    var display_name : String;
    var description : String;

    public function new(b:Entity_Ship) 
    {
        super(b.cx,b.cy);

        Instance = this;

        set_wid(b.width);
        set_hei(b.height);
        display_name = b.f_DisplayName;
        description = 'Start your expedition #${cast(game, GameManager).NumExpedition+1}?';

        spr.useCustomTile(b.getTile());
    }

    override function dispose() {
		super.dispose();
		Instance = null;
	}

	public function displayPopUp() {

        new ShipPopUp(display_name, description, getYesAction());
    }

    public function getDisplayName() : String {
        return display_name;
    }

    public function getYesAction() : Void->Void
    {
        return ()->{cast(Game.ME, GameManager).switchToExploration();};
    }
}