package ui;

import h2d.Tile;

class BuildingPopUp extends ui.win.Menu
{
    public function new(name:String, description:String, currentLevel:Int, maxLevel:Int, nextUpgradeCost:Int, tile:Tile, yes:Void->Void) {
        super(true);
        this.mask.backgroundTile = Tile.fromColor(0x0,1,1,0.6);
        
        addTileTitled(currentLevel == 0 ? '$name' : '$name - lvl.$currentLevel', tile);
        addSpacer();

        addTitle(description);
        // addTitle('Level : ($currentLevel/$maxLevel)');
        addSpacer();
        addSpacer();

		if(yes != null) addButton('${currentLevel==0?"Unlock":"Upgrade"} ($nextUpgradeCost G)', yes, true);
        else addTitle(nextUpgradeCost > 0 ? '${currentLevel==0?"Unlock Cost":"Next Upgrade"} : $nextUpgradeCost G' : 'Maxed Out!');
        addButton("Close", fuckIt, true);
		hxd.Res.sounds.sfx.Building_Open.play(false, 0.5);
    }

    public function fuckIt()
    {

    }
}