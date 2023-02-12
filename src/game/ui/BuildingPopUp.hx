package ui;

import h2d.Tile;

class BuildingPopUp extends ui.win.Menu
{
    public function new(name:String, description:String, currentLevel:Int, maxLevel:Int, nextUpgradeCost:Int, yes:Void->Void) {
        super(true);
        this.mask.backgroundTile = Tile.fromColor(0x0,1,1,0.6);
        
        addTitle('$name menu');
        addTitle(description);
        addTitle('Level : ($currentLevel/$maxLevel)');
		if(yes != null) addButton('Upgrade ($nextUpgradeCost gold)', yes, true);
        else addTitle(nextUpgradeCost > 0 ? 'Next Upgrade : $nextUpgradeCost gold' : 'Maxed Out!');
        addButton("Close", fuckIt, true);
    }

    public function fuckIt()
    {

    }
}