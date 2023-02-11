package sample;

import PlanetExploration.PlanetExplorationMap;

/**
	This small class just creates a SamplePlayer instance in current level
**/
class SampleGame extends Game {

	var _gold : Int;
	var _ap : Int;
	public var Gold(get, set):Int;

	function get_Gold() return _gold;
	function set_Gold(v) {
	  _gold = v;
	  hud.updateHUD(Gold,AP);
	  return _gold;
	}

	public var AP(get,set):Int;
	function get_AP() return _ap;
	function set_AP(v) {
		_ap = v;
		hud.updateHUD(Gold,AP);
		return _ap;
	}


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
		new PlanetExplorationMap(state);
	}

	public function addGold(value : Int)
	{
		Gold += value;
	}

	public function removeGold(value : Int)
	{
		Gold -= value;
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

