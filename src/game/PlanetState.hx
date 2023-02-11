import sample.SampleGame;
import dn.Rand;

enum abstract TILE_TYPE(Int) 
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

    public function new(_planetSize:Int)
    {
        rand = new Rand(0);
        rand.initSeed(Std.random(999999));

        planetSize = _planetSize;
        //REMPLIR START POS X ET Y
    }
        
    public inline function getTileType(cx:Int,cy:Int) : TILE_TYPE return VIDE;

    public function digCase(cx:Int, cy:Int)
    {
        cast(Game.ME, SampleGame).addGold(10);
    }
}

private class InterestPoint
{
    private var chanceAppear : Int;
    public inline function DoAppear(r : Rand) return r.irange(0,100) <= chanceAppear;
    
    private var distanceMin : Int;
    private var distanceMax : Int;
    public inline function GetRandomDistance(r : Rand) return r.irange(distanceMin, distanceMax);

    public var chanceEarn : Float;
    private var minEarn : Int;
    private var maxEarn : Int;
    public inline function GetRandomEarn(r : Rand) return r.irange(minEarn, maxEarn); 

    public var chanceLostPA : Float;
    public var losePA : Int;

    public function new(chanceAppear : Int, distanceMin : Int, distanceMax : Int, chanceEarn : Float, minEarn : Int, maxEarn : Int, chanceLostPA : Float, losePA : Int)
    {
        this.chanceAppear = chanceAppear;
        this.distanceMin = distanceMin;
        this.distanceMax = distanceMax;
        this.chanceEarn = chanceEarn;
        this.minEarn = minEarn;
        this.maxEarn = maxEarn;
        this.chanceLostPA = chanceLostPA;
        this.losePA = losePA;
    }
}
