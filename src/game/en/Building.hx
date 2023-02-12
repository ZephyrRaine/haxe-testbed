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

    var fontBuilding : h2d.Font = hxd.Res.fonts.FutilePro.toFont();
    var bg : Bitmap;

    function isMaxLevel() : Bool
    {
        return building_level == building_costs.length;
    }

    var merchantAI : en.Merchant;

    public function new(b:Entity_Building) {
        super(b.cx,b.cy);

        ALL.push(this);

        set_wid(b.width);
        set_hei(b.height);
        display_name = b.f_DisplayName;
        fuckingType = ANALYZER;
        switch(b.f_BUILDING_TYPE)
        {
            case "AP" : fuckingType = AP; merchantAI = new en.Merchant(Assets.merchant, 0.4, cx, cy, 3);
            case "RADAR" : fuckingType = RADAR; merchantAI = new en.Merchant(Assets.smallDroid, 0.53, cx, cy, 3);
            case "EXTRACTOR" : fuckingType = EXTRACTOR; merchantAI = new en.Merchant(Assets.mudGuard, 0.39, cx, cy, 3);
            case "ANALYZER": fuckingType = ANALYZER; merchantAI = new en.Merchant(Assets.redDude, 0.475, cx, cy, 2);
            case "SCOPE" : fuckingType = SCOPE; merchantAI = new en.Merchant(Assets.totemDude, 0.53, cx, cy, 3);
        }
        if(b.f_BUILDING_TYPE != "")
            icon = Assets.tiles.getTile('building_icon_${b.f_BUILDING_TYPE}');
        building_level = cast(game, GameManager).buildingsLevel[fuckingType];
        description = b.f_Description;

        building_costs = b.f_Cost; 
        spr.useCustomTile(b.getTile());

        bg = new h2d.Bitmap(Assets.tiles.getTile("ui_border_3"));

        label = new h2d.Text(fontBuilding, bg);
        label.filter = new dn.heaps.filter.PixelOutline();
        label.text = getDisplayName();
        label.textColor = White;
        bg.setPosition( Std.int((cx+xr)*Const.GRID -label.textWidth*0.5), Std.int((cy-1+yr)*Const.GRID -label.textHeight-3));
        bg.width = label.textWidth +10;
        bg.height = 5;
        label.setPosition(5, -label.textHeight-2);
        
        bg.visible = false;

        updateLevelInfo();

        game.scroller.add(bg, Const.DP_UI);
    }

    public function updateLevelInfo()
    {      
        if(display_name == "Ship")
            return;

        
        label.text = getDisplayName();
        label.textColor = White;
        bg.setPosition( Std.int((cx+xr)*Const.GRID -label.textWidth*0.5), Std.int((cy-1+yr)*Const.GRID -label.textHeight-3));
        bg.width = label.textWidth +10;
        bg.height = 5;
        label.setPosition(5, -label.textHeight-2);

        this.spr.colorize(building_level==0 ? Col.coldGray(0.05) : Col.white());
        this.spr.alpha = building_level==0 ? 0.9 : 1.0;
        merchantAI.entityVisible = building_level == building_costs.length;        
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
        if(building_level == 0)
        {
            new BuildingPopUp("???", "A strange building", 0, building_costs.length, building_costs[building_level], Assets.tiles.getTile('locked_building'), nextCost != -1 && currentGold >= nextCost ? upgrade : null);
        }
        else
        {
            new BuildingPopUp(display_name, description, building_level, building_costs.length, building_costs[building_level], icon, nextCost != -1 && currentGold >= nextCost ? upgrade : null);
        }
    }

    public function getDisplayName() : String {
        return display_name == "Ship" ? "Ship" : (building_level==0?"???":display_name + " - lvl. " + (isMaxLevel()?"max":Std.string(building_level)));
    }

    public function upgrade()
    {
        if(building_level >= building_costs.length)
            return;

        var nextCost = building_costs[building_level];
        cast(game,GameManager).addPermanentGold(-nextCost);
        building_level++;
        
        cast(game,GameManager).buildingsLevel[fuckingType] = building_level;

        updateLevelInfo();

        hxd.Res.sounds.sfx.Building_Upgrade.play(false, 1.0);
        fx.dotsExplosionCustom(centerX, centerY, 0xffcc00);
    }
}