package en;

import sample.GameManager;
import h2d.Bitmap;
import ui.BuildingPopUp;
import h2d.Tile;
import h2d.TileGroup;

class Building extends Entity {

	public static var ALL : Array<Building> = [];

    var display_name : String;
    var description : String;
    var building_level : Int;
    var building_costs : Array<Int>;
    var fuckingType : BUILDING_TYPES;

    public function new(b:Entity_Building) {
        super(b.cx,b.cy);

        ALL.push(this);

        set_wid(b.width);
        set_hei(b.height);
        display_name = b.f_DisplayName;
        fuckingType = ANALYZER;
        switch(b.f_BUILDING_TYPE)
        {
            case "AP" : fuckingType = AP;
            case "RADAR" : fuckingType = RADAR;
            case "EXTRACTOR" : fuckingType = EXTRACTOR;
            case "ANALYZER": fuckingType = ANALYZER;
            case "SCOPE" : fuckingType = SCOPE;
        }
        building_level = cast(game, GameManager).buildingsLevel[fuckingType];
        description = b.f_Description;

        building_costs = b.f_Cost; 
        spr.useCustomTile(b.getTile());
    }

    override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function displayPopUp() {

        var nextCost = building_level >= building_costs.length ? -1 : building_costs[building_level];
        var currentGold = cast(game, GameManager).Gold;

        new BuildingPopUp(display_name, description, building_level, building_costs.length, building_costs[building_level], nextCost != -1 && currentGold >= nextCost ? upgrade : null);
    }

    public function getDisplayName() : String {
        return display_name + " - lvl. " + building_level;
    }

    public function upgrade()
    {
        if(building_level >= building_costs.length)
            return;

        var nextCost = building_costs[building_level];
        cast(game,GameManager).addPermanentGold(-nextCost);
        building_level++;
        cast(game,GameManager).buildingsLevel[fuckingType] = building_level;
        hxd.Res.sounds.sfx.Building_Upgrade.play(false, 1.0);
    }
}