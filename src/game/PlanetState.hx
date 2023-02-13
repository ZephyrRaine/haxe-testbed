import sample.GameManager;
import dn.Rand;

typedef InspectorPayload = { title : String, description : String, action : String, analyzer : String }

enum abstract TILE_TYPE(Int) from Int to Int
{
    var VIDE;
    var SHIP; //player entry point

    var CREVASSE;
    var WRECK; //"épave"
    var VILLAGE;
    var ORE;
    var PLANT;
    var CORPSE;
}

class PlanetState
{
    public var rand :Rand;

    public var startPosX : Int;
    public var startPosY : Int;
    public var planetSize : Int;

    public var planetGrid : Array<Array<TILE_TYPE>>;
    public var interestPoints : Array<InterestPoint>;

    public function new()
    {
        var gm = cast(Game.ME, GameManager);
        Init(gm.MaxAP, Std.int(gm.buildingsLevel[AP]));

        GenerateBasicPoints();
        GenerateInterestPoints();
    }
        
    public inline function getTileType(cx:Int,cy:Int) : TILE_TYPE return planetGrid[cx][cy];

    public function digCase(cx:Int, cy:Int, extractorLevel:Int) : String
    {
        var goldEarn = interestPoints[planetGrid[cx][cy]].GetRandomEarn(rand);
        if(goldEarn > 0){
            goldEarn = Std.int(goldEarn*(1.0+extractorLevel*0.4));
        }
        var apEarn = interestPoints[planetGrid[cx][cy]].GetRandomAP(rand);
        
        if(!cast(Game.ME, GameManager).FirstCaseDigged && goldEarn < 64)
        {
            goldEarn = 64;
            cast(Game.ME, GameManager).FirstCaseDigged = true;
        }

        PlanetExploration.ME.addGold(goldEarn);
        PlanetExploration.ME.addAP(apEarn);
        
        var log : String;
        switch(planetGrid[cx][cy])
        {
            case VIDE:
                log = goldEarn > 0 ? 'You find buried trinkets worth $goldEarn golds.' : 'You find nothing.';
            case SHIP:
                log = '';

            case CREVASSE:
                log = goldEarn > 0 ? 'The exploration is successful!\nYou come back with minerals worth $goldEarn golds.' : 'This crack was empty.';
                log += apEarn < 0 ? '\nAnd it took you a long time: $apEarn AP.' : '';
            case WRECK:
                log = goldEarn > 0 ? 'Jackpot!\nYou find the equivalent of $goldEarn golds in valuable objects!' : 'Sadly, there is nothing of value left.';
                log += apEarn < 0 ? '\nUnfortunately, this wreck was a real labyrinth: $apEarn APs.' : '';
            case VILLAGE:
                log = apEarn > 0 ? 'You meet inhabitants who welcome you nicely.\nYou recover all your APs.' : 'The inhabitants of this planet are hostile, you flee.';
            case ORE:
                log = goldEarn > 0 ? 'Woaw! You have extracted ores for a total of $goldEarn golds!' : 'They are mere pebbles of no value.';
            case PLANT:
                log = goldEarn > 0 ? 'Nice catch.\nYou carefully harvest this rare plant, it is worth $goldEarn golds.' : 'Just weeds, leave them here.';
            case CORPSE:
                log = goldEarn > 0 ? 'This old corpse had $goldEarn gold coins in his pockets.\n"They would have been useless to him anyway."' : 'There are only bones left.';
                
            case _:
                log = 'You earn $goldEarn golds and $apEarn AP.';
        }
        return log;
    }

    public function inspectCase(cx:Int, cy:Int, analyzerLevel:Int, extractorLevel:Int) : InspectorPayload
    {
        var ip :InspectorPayload = {title:"",description:"",action: "",analyzer: ""};
        var caseType = planetGrid[cx][cy];
        ip.action = "Act: Dig (1AP)";

        switch(caseType)
        {
            case VIDE:
                ip.title = "Empty";
                ip.description = "Nothing to see here";
            case SHIP:
                ip.title = "Ship";
                ip.description = "Your beloved ship";
                ip.action = "Act: Return Home (0AP)"; 
            case CREVASSE:
                ip.title = "Crevasse";
                ip.description = "A bottomless pit";
            case WRECK:
                ip.title = "Wreck";
                ip.description = "Someone was less lucky than you";
            case VILLAGE:
                ip.title = "Village";
                ip.description = "People used to live here?!";
            case ORE:
                ip.title = "Ore";
                ip.description = "A shiny rock";
            case PLANT:
                ip.title = "Plant";
                ip.description = "You can't eat this";
            case CORPSE:
                ip.title = "Corpsed";
                ip.description = "Kinda horrible";
        }
        ip.analyzer = interestPoints[caseType].GetAnalyzerInfos(analyzerLevel, extractorLevel);

        return ip;
    }

    private function Init(maxAP : Int, buildingAPLevel : Int)
    {
        rand = new Rand(0);
        rand.initSeed(Std.random(999999));

        planetSize = rand.irange(4, 4 + buildingAPLevel);
        if(planetSize % 2 == 0)
        {
            planetSize += 1;
        }
        planetGrid = [for (x in 0...planetSize) [for (y in 0...planetSize) TILE_TYPE.VIDE]];

        startPosX = Std.int(planetSize / 2);
        startPosY = startPosX;

        
        interestPoints = new Array<InterestPoint>();
        {
            var d = Const.db;
            interestPoints.push(new InterestPoint(
                d.vide_chanceAppear,
                d.vide_distanceMin >= 0 ? d.vide_distanceMin : planetSize + d.vide_distanceMin,
                d.vide_distanceMax >= 0 ? d.vide_distanceMax : planetSize + d.vide_distanceMax,
                d.vide_chanceEarn,
                d.vide_minEarn,
                d.vide_maxEarn,
                d.vide_chancePA,
                d.vide_numPA >= 999 ? maxAP : d.vide_numPA));

            interestPoints.push(new InterestPoint(
                d.ship_chanceAppear,
                d.ship_distanceMin >= 0 ? d.ship_distanceMin : planetSize + d.ship_distanceMin,
                d.ship_distanceMax >= 0 ? d.ship_distanceMax : planetSize + d.ship_distanceMax,
                d.ship_chanceEarn,
                d.ship_minEarn,
                d.ship_maxEarn,
                d.ship_chancePA,
                d.ship_numPA >= 999 ? maxAP : d.ship_numPA));

            interestPoints.push(new InterestPoint(
                d.crevasse_chanceAppear,
                d.crevasse_distanceMin >= 0 ? d.crevasse_distanceMin : planetSize + d.crevasse_distanceMin,
                d.crevasse_distanceMax >= 0 ? d.crevasse_distanceMax : planetSize + d.crevasse_distanceMax,
                d.crevasse_chanceEarn,
                d.crevasse_minEarn,
                d.crevasse_maxEarn,
                d.crevasse_chancePA,
                d.crevasse_numPA >= 999 ? maxAP : d.crevasse_numPA));
             
            interestPoints.push(new InterestPoint(
                d.wreck_chanceAppear,
                d.wreck_distanceMin >= 0 ? d.wreck_distanceMin : planetSize + d.wreck_distanceMin,
                d.wreck_distanceMax >= 0 ? d.wreck_distanceMax : planetSize + d.wreck_distanceMax,
                d.wreck_chanceEarn,
                d.wreck_minEarn,
                d.wreck_maxEarn,
                d.wreck_chancePA,
                d.wreck_numPA >= 999 ? maxAP : d.wreck_numPA));

            interestPoints.push(new InterestPoint(
                d.village_chanceAppear,
                d.village_distanceMin >= 0 ? d.village_distanceMin : planetSize + d.village_distanceMin,
                d.village_distanceMax >= 0 ? d.village_distanceMax : planetSize + d.village_distanceMax,
                d.village_chanceEarn,
                d.village_minEarn,
                d.village_maxEarn,
                d.village_chancePA,
                d.village_numPA >= 999 ? maxAP : d.village_numPA));

            interestPoints.push(new InterestPoint(
                d.ore_chanceAppear,
                d.ore_distanceMin >= 0 ? d.ore_distanceMin : planetSize + d.ore_distanceMin,
                d.ore_distanceMax >= 0 ? d.ore_distanceMax : planetSize + d.ore_distanceMax,
                d.ore_chanceEarn,
                d.ore_minEarn,
                d.ore_maxEarn,
                d.ore_chancePA,
                d.ore_numPA >= 999 ? maxAP : d.ore_numPA));
    
            interestPoints.push(new InterestPoint(
                d.plant_chanceAppear,
                d.plant_distanceMin >= 0 ? d.plant_distanceMin : planetSize + d.plant_distanceMin,
                d.plant_distanceMax >= 0 ? d.plant_distanceMax : planetSize + d.plant_distanceMax,
                d.plant_chanceEarn,
                d.plant_minEarn,
                d.plant_maxEarn,
                d.plant_chancePA,
                d.plant_numPA >= 999 ? maxAP : d.plant_numPA));

                                            
            interestPoints.push(new InterestPoint(
                d.corpse_chanceAppear,
                d.corpse_distanceMin >= 0 ? d.corpse_distanceMin : planetSize + d.corpse_distanceMin,
                d.corpse_distanceMax >= 0 ? d.corpse_distanceMax : planetSize + d.corpse_distanceMax,
                d.corpse_chanceEarn,
                d.corpse_minEarn,
                d.corpse_maxEarn,
                d.corpse_chancePA,
                d.corpse_numPA >= 999 ? maxAP : d.corpse_numPA));

            // interestPoints.push(new InterestPoint(0, 0, 0, 30, 10, 30, 0, 0));
            // interestPoints.push(new InterestPoint(0, 0, 0, 0, 0, 0, 0, 0));
            // interestPoints.push(new InterestPoint(100, 1, planetSize - 1, 70, 10, 30, 30, -1));
            // interestPoints.push(new InterestPoint(25, planetSize - 2, planetSize - 1, 80, 100, 300, 20, -2));
            // interestPoints.push(new InterestPoint(50, planetSize - 2, planetSize - 1, 0, 0, 0, 100, maxAP));
            // interestPoints.push(new InterestPoint(50, 1, planetSize - 1, 100, 50, 100, 0, 0));
            // interestPoints.push(new InterestPoint(50, 1, 1, 100, 30, 50, 0, 0));
            // interestPoints.push(new InterestPoint(25, 1, planetSize - 1, 50, 10, 100, 0, 0));
        }
    }

    private function GenerateBasicPoints()
    {
        planetGrid[startPosX][startPosY] = TILE_TYPE.SHIP;
    }
    private function GenerateInterestPoints()
    {
        for(i in 0...interestPoints.length)
        {
            if(interestPoints[i].DoAppear(rand, planetSize))
            {
                var distance : Int = interestPoints[i].GetRandomDistance(rand);
                
                var xPos = new Array<Int>();
                var yPos = new Array<Int>();
                for(y in 0...planetSize)
                {
                    for(x in 0...planetSize)
                    {
                        if(distance == Math.abs(x - startPosX) + Math.abs(y - startPosY))
                        {
                            if(planetGrid[x][y] == 0)
                            {
                                xPos.push(x);
                                yPos.push(y);
                            }
                        }
                    }
                }
                
                if(xPos.length > 0)
                {
                    var randomTile = rand.irange(0, xPos.length - 1);
    
                    planetGrid[xPos[randomTile]][yPos[randomTile]] = i;
                }
            }
        }
    }
}

private class InterestPoint
{
    private var chanceAppear : Int;
    public function DoAppear(r : Rand, planetSize : Int)
    {
        if(planetSize > 7)
            return r.irange(0,100) <= Math.min(chanceAppear * 1.6, 100);
        else if(planetSize > 5)
            return r.irange(0,100) <= Math.min(chanceAppear * 1.2, 100);
        else
            return r.irange(0,100) <= chanceAppear;
    }
    
    private var distanceMin : Int;
    private var distanceMax : Int;
    public inline function GetRandomDistance(r : Rand) return r.irange(distanceMin, distanceMax);

    private var chanceEarn : Float;
    private var minEarn : Int;
    private var maxEarn : Int;
    public inline function GetRandomEarn(r : Rand) return r.irange(0, 100) <= chanceEarn ? r.irange(minEarn, maxEarn) : 0; 

    private var chancePA : Float;
    private var numPA : Int;
    public inline function GetRandomAP(r : Rand) return r.irange(0, 100) <= chancePA ? numPA : 0; 

    public function new(chanceAppear : Int, distanceMin : Int, distanceMax : Int, chanceEarn : Float, minEarn : Int, maxEarn : Int, chancePA : Float, numPA : Int)
    {
        this.chanceAppear = chanceAppear;
        this.distanceMin = distanceMin;
        this.distanceMax = distanceMax;
        this.chanceEarn = chanceEarn;
        this.minEarn = minEarn;
        this.maxEarn = maxEarn;
        this.chancePA = chancePA;
        this.numPA = numPA;
    }

    public function GetAnalyzerInfos(analyzerLevel : Int, extractorLevel : Int) : String
    {
        var analyzerInfos = "";
        if(analyzerLevel <= 0)
            return analyzerInfos;
        
        var goldChance = analyzerLevel >= 1 ? '$chanceEarn%' : "???";
        var goldRange = analyzerLevel >= 3 ? '${Std.int(minEarn*(1.0+extractorLevel*0.4))}g- ${Std.int(maxEarn*(1.0+extractorLevel*0.4))}g' : "??g - ??g";
        var apChance = analyzerLevel >= 2 ? '$chancePA%' : "???";
        var apRange = analyzerLevel >= 4 ? '$numPA AP' : "?? AP";

        analyzerInfos = 'Chance of gold : ${goldChance}\n(${goldRange})\nChance of AP : ${apChance}\n(${apRange})';
        return analyzerInfos;
    }
}
