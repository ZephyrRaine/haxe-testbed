import PlanetState.TILE_TYPE;
import sample.GameManager;
import h2d.Bitmap;
import h2d.Tile;
import ui.PlanetInspectorWindow;

enum TILE_STATUS
{
        HIDDEN;
        REVEALED;
        FOUILLED;
}

class PlanetExploration extends Entity{
	public static var ME : PlanetExploration;

    var _gold : Int;
	var _ap : Int;
	public var Gold(get, set):Int;

	function get_Gold() return _gold;
	function set_Gold(v) {
     if(v <= 0) v = 0;
	  _gold = v;
	  planetInspector.updateHUD(Gold,AP);
	  return _gold;
	}

	public var AP(get,set):Int;
	function get_AP() return _ap;
	function set_AP(v) {
        if(v <= 0)
        {
            v = 0;
            triggerEndRun(true);
        } 
        if(v > gm.maxAP)
    		_ap = v;
		planetInspector.updateHUD(Gold,AP);
		return _ap;
	}


	var ca : ControllerAccess<GameAction>;

    var playerEntity : Entity;
    var planetState : PlanetState;

    var tile_statuses : Array<Array<TILE_STATUS>>; 
    var mapTiles : Array<Array<Entity>>;

    var planetInspector : PlanetInspectorWindow;

    var gm : GameManager;

    public function addGold(value : Int)
    {
        Gold += value;
    }

    public function addAP(value : Int)
    {
        AP += value;
    }



    public function new(state:PlanetState)
    {
        super(0,0);

        gm = cast(Game.ME, GameManager);
        planetState = state;
		ME = this;


        hei = planetState.planetSize*16;
        wid = planetState.planetSize*16;

        AP = gm.maxAP;

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

        planetInspector = new PlanetInspectorWindow();

        planetInspector.updateTile(TILE_TYPE.SHIP, REVEALED);
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
        var canMove : Bool = isInBounds(ncx,ncy)&&(ncx!=playerEntity.cx||ncy!=playerEntity.cy);
        if(!canMove)
            return false;

        playerEntity.setPosCase(ncx,ncy);
        if(tile_statuses[ncx][ncy] == HIDDEN)
        {
            revealTile(ncx,ncy);
        }

        planetInspector.updateTile(planetState.getTileType(ncx,ncy), REVEALED);

        return true;
    }

    function revealTile(cx:Int,cy:Int)
    {
        if(!isInBounds(cx,cy))
            return;

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
            triggerEndRun(false);
            // gm.switchToVillage();
            return false;
        }

        tile_statuses[cx][cy] = FOUILLED;
        mapTiles[cx][cy].spr.set('map_fouilled_$caseType');
        planetState.digCase(cx,cy);
        planetInspector.updateTile(caseType, FOUILLED);

        return true;
    }

    inline function isInBounds(cx:Int,cy:Int):Bool
    {
        return cx>=0&&cx<planetState.planetSize&&cy>=0&&cy<planetState.planetSize;
    }

    
    override function dispose() {
		super.dispose();
        planetInspector.destroy();
	}

    function triggerEndRun(lost:Bool)
    {
        
    }

}