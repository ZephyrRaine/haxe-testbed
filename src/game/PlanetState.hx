enum TILE_TYPE
{
    VIDE;
    CADAVRE;
    CREVASSE;

}

class PlanetState
{
    public var startPosX : Int;
    public var startPosY : Int;
    public var planetSize : Int;



    public function new(_planetSize:Int)
    {
        planetSize = _planetSize;
        //REMPLIR START POS X ET Y
    }

    public function digCase(cx:Int, cy:Int)
    {

    }
}