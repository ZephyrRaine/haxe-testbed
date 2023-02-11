package sample;

import PlanetExploration.PlanetExplorationMap;

/**
	This small class just creates a SamplePlayer instance in current level
**/
class SampleGame extends Game {

	var gold : Int = 0;
	var AP : Int = 0;


	public function new() {
		super();

		Console.ME.add("switchExploration",switchToExploration);

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
		
	}

	public function switchToExploration()
	{
		startLevel(Assets.worldData.all_levels.PlanetExplorationLevel);
	}

	function initExploration()
	{
		trace("salut");

		var state = new PlanetState(5);
		new PlanetExplorationMap(state);
	}

	public function addGold(value : Int)
	{
		gold += value;
	}

	public function removeGold(value : Int)
	{
		gold -= value;
	}

	public function addAP(value : Int)
	{
		AP += value;
	}

	public function removeAP(value : Int)
	{
		AP -= value;
	}
}

