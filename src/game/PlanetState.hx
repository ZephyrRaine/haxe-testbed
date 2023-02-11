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

    public function digCase(cx:Int, cy:Int)
    {
        PlanetExploration.ME.addGold(interestPoints[planetGrid[cx][cy]].GetRandomEarn(rand));
        PlanetExploration.ME.addAP(interestPoints[planetGrid[cx][cy]].GetRandomAP(rand));
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
            interestPoints.push(new InterestPoint(50, 1, planetSize - 1, 50, 100, 0, 0, 0));
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
                var xDirection : Int = startPosX;
                var yDirection : Int = startPosY;

                var distance : Int = interestPoints[i].GetRandomDistance(rand);
                while(distance > 0)
                {
                    if(rand.irange(0, 1) == 1) //Horizontal Move
                    {
                        if(xDirection == startPosX)
                        {
                            xDirection += rand.irange(0,1)*2-1;
                        }
                        else
                        {
                            if(!TryMoveOnDirection(xDirection))
                                TryMoveOnDirection(yDirection);
                        }
                    }
                    else //Vertical Move
                    {
                        if(yDirection == startPosY)
                        {
                            yDirection += rand.irange(0,1)*2-1;
                        }
                        else
                        {
                            if(!TryMoveOnDirection(yDirection))
                                TryMoveOnDirection(xDirection);
                        }
                    }

                    distance--;
                }

                planetGrid[xDirection][yDirection] = i;
            }
        }
    }

    private function TryMoveOnDirection(_direction : Int) : Bool
    {
        var directionTarget = _direction + (_direction > 0 ? 1 : -1);

        if(directionTarget >= 0 && directionTarget < planetSize)
        {
            _direction = directionTarget;
            return true;
        }
        else
        {
            return false;
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
