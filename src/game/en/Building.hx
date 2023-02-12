package en;

import ui.ShipPopUp;
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


    var label : h2d.Text;

    var fuckingType : BUILDING_TYPES;
    var icon : Tile;

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
        if(b.f_BUILDING_TYPE != "")
            icon = Assets.tiles.getTile('building_icon_${b.f_BUILDING_TYPE}');
        building_level = cast(game, GameManager).buildingsLevel[fuckingType];
        description = b.f_Description;

        building_costs = b.f_Cost; 
        spr.useCustomTile(b.getTile());

        var bg = new h2d.Bitmap(Assets.tiles.getTile("ui_border_3"));

        label = new h2d.Text(Assets.fontPixel, bg);
        label.filter = new dn.heaps.filter.PixelOutline();
        label.text = getDisplayName();
        label.textColor = White;
        bg.setPosition( Std.int((cx+xr)*Const.GRID -label.textWidth*0.5), Std.int((cy-1+yr)*Const.GRID -label.textHeight-3));
        bg.width = label.textWidth +10;
        bg.height = 5;
        label.setPosition(5, -label.textHeight-2);
        
        bg.visible = false;

        game.scroller.add(bg, Const.DP_UI);
    }

    override function postUpdate()
    {
        super.postUpdate();
        label.parent.setPosition( Std.int((cx+xr)*Const.GRID -label.textWidth*0.5), ((cy-1+yr)*Const.GRID -label.textHeight-3 - 2*Math.sin(game.stime*3))); 
    }

    public function showLabel(show:Bool)
    {
        label.parent.visible = show;
        label.text = getDisplayName();
    }

    override function dispose() {
		super.dispose();
        label.parent.remove();
		ALL.remove(this);
	}

	public function displayPopUp() 
    {
        if(display_name == "Ship")
        {
            new ShipPopUp(display_name, description, cast(Game.ME, GameManager).switchToExploration);
            return;
        }

        var nextCost = building_level >= building_costs.length ? -1 : building_costs[building_level];
        var currentGold = cast(game, GameManager).Gold;

        new BuildingPopUp(display_name, description, building_level, building_costs.length, building_costs[building_level], icon, nextCost != -1 && currentGold >= nextCost ? upgrade : null);
    }

    public function getDisplayName() : String {
        return display_name == "Ship" ? "Ship" : display_name + " - lvl. " + building_level;
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