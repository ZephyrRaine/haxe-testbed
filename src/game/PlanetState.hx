import sample.SampleGame;

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
    public var startPosX : Int;
    public var startPosY : Int;
    public var planetSize : Int;

    public function getTileType(cx:Int,cy:Int) : TILE_TYPE
    {
        return VIDE;
    }

    public function new(_planetSize:Int)
    {
        planetSize = _planetSize;
        //REMPLIR START POS X ET Y
    }

    public function digCase(cx:Int, cy:Int)
    {
        cast(Game.ME, SampleGame).addGold(10);
    }
}