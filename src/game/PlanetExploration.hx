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

    public function new(state:PlanetState)
    {
        planetState = state;

        super(0,0);

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;
        
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

        var mapTiles : Array<Array<Entity>> = [for (x in 0...5) [for (y in 0...5) null]];
        for(y in 0...5)
        {
            for(x in 0...5)
            {
                var e = new Entity(x,y);
                e.spr.set(AssetsDictionaries.tiles.map_placeholder);
                mapTiles[y][x] = e;
            }
        }
        
        playerEntity = new Entity(state.startPosX,state.startPosY);
        playerEntity.spr.set(AssetsDictionaries.tiles.map_player);
    }

    override function preUpdate() 
    {
        super.preUpdate();

        if(ca.isPressed(MoveUp))
            playerEntity.setPosCase(playerEntity.cx, playerEntity.cy-1);
        if(ca.isPressed(MoveDown))
            playerEntity.setPosCase(playerEntity.cx, playerEntity.cy+1);
        if(ca.isPressed(MoveLeft))
            playerEntity.setPosCase(playerEntity.cx-1, playerEntity.cy);
        if(ca.isPressed(MoveRight))
            playerEntity.setPosCase(playerEntity.cx+1, playerEntity.cy);

        if(ca.isPressed(Jump))
            planetState.digCase(playerEntity.cx, playerEntity.cy);
    }
}