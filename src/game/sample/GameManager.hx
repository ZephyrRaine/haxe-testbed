package sample;

import ui.Window;


/**
	This small class just creates a SamplePlayer instance in current level
**/
class GameManager extends Game {
	public var maxAP:Int = 10;
	public var gold:Int = 0;
	public var villageHUD:Window;
	var variablesText : h2d.Text;

	public var scopeLevel = 0;

	public function new() {
		super();

		//switchToExploration();
		Console.ME.add("exploration",switchToExploration);
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);
		if(l.identifier == "PlanetExplorationLevel")
		{
			initExploration();
			return;
		}
		
		//ONLY IF IN VILLAGE

		for(b in l.l_Entities.all_Building)
		{
			new Building(b);
		}
		
		new SamplePlayer();

		villageHUD = new ui.Window();
		
        variablesText = new h2d.Text(Assets.fontPixel, root);
		variablesText.filter = new dn.heaps.filter.PixelOutline();
		updateHUD(0,0);
	}

	
    public function updateHUD(gold:Int, AP:Int)
    {
        variablesText.text = 'g:$gold - ap:$AP';
    }
    

	public function switchToExploration()
	{
		startLevel(Assets.worldData.all_levels.PlanetExplorationLevel);
	}

	public function switchToVillage()
	{
		startLevel(Assets.worldData.all_levels.FirstLevel);
	}

	function initExploration()
	{
		trace("salut");

		var state = new PlanetState(5);
		new PlanetExploration(state);
	}

	public function addPermanentGold(_gold:Int) {
		gold += _gold;
	}
}

