package sample;

import hxd.res.Sound;
import VillageManager.VillageHUD;
import ui.Window;


/**
	This small class just creates a SamplePlayer instance in current level
**/

enum abstract BUILDING_TYPES(String)
{
	var AP;
	var SCOPE;
	var EXTRACTOR;
	var RADAR;
	var ANALYZER;
}

class GameManager extends Game {
	public var MaxAP(get,never):Int;

	function get_MaxAP():Int {
		return Const.STARTING_AP + Std.int(buildingsLevel[AP]) * Const.INCREMENT_AP;
	  }

	var _gold : Int;
	public var Gold(get, set):Int;

	function get_Gold() return _gold;
	function set_Gold(v) {
	if(v <= 0) v = 0;

	_gold = v;
	updateHUD(Gold);
	return _gold;
	}

	var _numExpedition : Int;
	public var NumExpedition(get, never):Int;
	function get_NumExpedition() return _numExpedition;

	public var FirstCaseDigged : Bool;

	public var buildingsLevel = 
	[
		BUILDING_TYPES.AP => 0,
		BUILDING_TYPES.SCOPE => 0,
		BUILDING_TYPES.EXTRACTOR => 0,
		BUILDING_TYPES.RADAR => 0,
		BUILDING_TYPES.ANALYZER => 0,
	];

	var villageHUD:VillageHUD;
	var bgm:Sound;
	
	public function new() {
		super();

		//switchToExploration();
		Console.ME.add("exploration",switchToExploration);
		
		Console.ME.add("set_building_level", (name,value)->{
			buildingsLevel[name] = value;
		});

		Console.ME.add("give_gold", (value)->
		{
			Gold += value;
		});

		Console.ME.add("print_building_levels", ()->
		{
			Console.ME.clearAndLog('
			AP = $buildingsLevel[AP]\n
			Scope = $buildingsLevel[SCOPE]\n
			Extractor = $buildingsLevel[EXTRACTOR]\n
			Radar = $buildingsLevel[RADAR]\n
			Analyzer = $buildingsLevel[ANALYZER]');
		});

		bgm = hxd.Res.sounds.bgm.Village;
		bgm.play(true, 0.3);
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);
		if(l.identifier == "PlanetExplorationLevel")
		{
			initExploration();
			_numExpedition++;
			return;
		}
		
		//ONLY IF IN VILLAGE
		for(s in l.l_Entities.all_Ship)
		{
			new Ship(s);
		}
		for(b in l.l_Entities.all_Building)
		{
			new Building(b);
		}
		
		new SamplePlayer();

		villageHUD = new VillageHUD();
		updateHUD(Gold);
	}

	
    public function updateHUD(gold:Int)
    {
		if(villageHUD != null)
			villageHUD.updateGold(gold);
    }
    

	public function switchToExploration()
	{
		if(villageHUD != null)
			villageHUD.destroy();

		startLevel(Assets.worldData.all_levels.PlanetExplorationLevel);
        hxd.Res.sounds.sfx.Ship_Launch.play(false, 0.6);
		bgm.stop();
		bgm = hxd.Res.sounds.bgm.Exploration;
		bgm.play(true, 0.3);
	}

	public function switchToVillage()
	{
		startLevel(Assets.worldData.all_levels.FirstLevel);
		bgm.stop();
		bgm = hxd.Res.sounds.bgm.Village;
		bgm.play(true, 0.3);
	}

	function initExploration()
	{
		var state = new PlanetState();
		new PlanetExploration(state);
	}

	public function addPermanentGold(g:Int) {
		Gold += g;
	}
}

