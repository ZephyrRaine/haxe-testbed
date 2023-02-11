import sample.GameManager;
import dn.Rand;

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

    public function new(_planetSize:Int)
    {
        Init(_planetSize);
        GenerateBasicPoints();
        GenerateInterestPoints();
    }
        
    public inline function getTileType(cx:Int,cy:Int) : TILE_TYPE return planetGrid[cx][cy];

    public function digCase(cx:Int, cy:Int) : String
    {
        var goldEarn = interestPoints[planetGrid[cx][cy]].GetRandomEarn(rand);
        var apEarn = interestPoints[planetGrid[cx][cy]].GetRandomAP(rand);
        
        PlanetExploration.ME.addGold(goldEarn);
        PlanetExploration.ME.addAP(apEarn);
        
        switch(planetGrid[cx][cy])
        {
            // case VIDE:
            //     return
            // case SHIP:
                
            // case CREVASSE:
            // case WRECK:
            // case VILLAGE:
            // case ORE:
            // case PLANT:
            // case CORPSE:
                case _:
                    return 'You earn $goldEarn golds and $apEarn AP.';
        }
    }

    private function Init(_planetSize : Int)
    {
        rand = new Rand(0);
        rand.initSeed(Std.random(999999));

        planetSize = _planetSize < 5 ? 5 : _planetSize;
        if(planetSize % 2 == 0)
        {
            planetSize += 1;
        }
        planetGrid = [for (x in 0...planetSize) [for (y in 0...planetSize) TILE_TYPE.VIDE]];

        startPosX = Std.int(planetSize / 2);
        startPosY = startPosX;

        interestPoints = new Array<InterestPoint>();
        {
            interestPoints.push(new InterestPoint(0, 0, 0, 30, 10, 30, 0, 0));
            interestPoints.push(new InterestPoint(0, 0, 0, 0, 0, 0, 0, 0));
            interestPoints.push(new InterestPoint(100, 1, planetSize - 1, 70, 10, 30, 30, -1));
            interestPoints.push(new InterestPoint(25, planetSize - 2, planetSize - 1, 80, 100, 300, 20, -2));
            interestPoints.push(new InterestPoint(50, planetSize - 2, planetSize - 1, 0, 0, 0, 100, 5));
            interestPoints.push(new InterestPoint(50, 1, planetSize - 1, 100, 50, 100, 0, 0));
            interestPoints.push(new InterestPoint(50, 1, 1, 100, 30, 50, 0, 0));
            interestPoints.push(new InterestPoint(25, 1, planetSize - 1, 50, 10, 100, 0, 0));
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
            if(interestPoints[i].DoAppear(rand))
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
                    var randomTile = rand.irange(0, xPos.length);
    
                    planetGrid[xPos[randomTile]][yPos[randomTile]] = i;
                }
            }
        }
    }
}

private class InterestPoint
{
    private var chanceAppear : Int;
    public inline function DoAppear(r : Rand) return r.irange(0,100) <= chanceAppear;
    
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
}
