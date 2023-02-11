import sample.SampleGame;
import h2d.Bitmap;
import h2d.Tile;

enum TILE_STATUS
{
        HIDDEN;
        REVEALED;
        FOUILLED;
}

class PlanetExplorationMap extends Entity{
	var ca : ControllerAccess<GameAction>;

    var playerEntity : Entity;
    var planetState : PlanetState;

    var tile_statuses : Array<Array<TILE_STATUS>>; 
    var mapTiles : Array<Array<Entity>>;

    public function new(state:PlanetState)
    {
        planetState = state;

        super(0,0);

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;
        
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

        tile_statuses = [for (x in 0...planetState.planetSize) [for (y in 0...planetState.planetSize) HIDDEN]]; 
        mapTiles = [for (x in 0...planetState.planetSize) [for (y in 0...planetState.planetSize) null]];
        for(y in 0...5)
        {
            for(x in 0...5)
            {
                var e = new Entity(x,y);
                e.spr.set(AssetsDictionaries.tiles.map_hidden);
                mapTiles[x][y] = e;
            }
        }

        revealTile(state.startPosX,state.startPosY);
        
        playerEntity = new Entity(state.startPosX,state.startPosY);
        playerEntity.spr.set(AssetsDictionaries.tiles.map_player);

        
    }

    override function preUpdate() 
    {
        super.preUpdate();
        
        var wantedX:Int = 0;
        var wantedY:Int = 0;

        if(ca.isPressed(MoveUp))
            wantedY = -1;
            // playerEntity.setPosCase(playerEntity.cx, playerEntity.cy-1);
        else if(ca.isPressed(MoveDown))
            wantedY = 1;
            // playerEntity.setPosCase(playerEntity.cx, playerEntity.cy+1);
        else if(ca.isPressed(MoveLeft))
            wantedX = -1;
            // playerEntity.setPosCase(playerEntity.cx-1, playerEntity.cy);
        else if(ca.isPressed(MoveRight))
            wantedX = 1;
            // playerEntity.setPosCase(playerEntity.cx+1, playerEntity.cy);
        else if(ca.isPressed(Jump))
            tryDigTile(playerEntity.cx, playerEntity.cy);

        if((wantedX != 0 || wantedY != 0) && tryMove(playerEntity.cx+wantedX, playerEntity.cy+wantedY))
        {

        }
    }

    function tryMove(ncx:Int, ncy:Int):Bool
    {
        var canMove : Bool = ncx>=0&&ncx<planetState.planetSize&&ncy>=0&&ncy<planetState.planetSize&&(ncx!=playerEntity.cx||ncy!=playerEntity.cy);
        if(!canMove)
            return false;

        playerEntity.setPosCase(ncx,ncy);
        if(tile_statuses[ncx][ncy] == HIDDEN)
        {
            revealTile(ncx,ncy);
        }

        return true;
    }

    function revealTile(cx:Int,cy:Int)
    {
        //GET MAP CASE ENUM AND DISPLAY ACCORDINGLY 
        var caseType = planetState.getTileType(cx,cy);

        tile_statuses[cx][cy] = REVEALED;
        mapTiles[cx][cy].spr.set('map_revealed_$caseType');

    }

    function tryDigTile(cx:Int, cy:Int):Bool
    {
        if(tile_statuses[cx][cy] == FOUILLED)
            return false;

        var caseType = planetState.getTileType(cx,cy);

        if(caseType == PlanetState.TILE_TYPE.SHIP)
        {
            cast(Game.ME, SampleGame).switchToVillage();
            return false;
        }

        tile_statuses[cx][cy] = FOUILLED;
        mapTiles[cx][cy].spr.set('map_fouilled_$caseType');
        planetState.digCase(cx,cy);

        return true;
    }

}