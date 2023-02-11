package sample;

/**
	This small class just creates a SamplePlayer instance in current level
**/
class GameManager extends Game {
	public var maxAP:Int = 10;

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

	
}

