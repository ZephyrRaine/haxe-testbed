import ui.PlanetProcess;
import ui.win.Menu;
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

    var moveSound = hxd.Res.sounds.sfx.Explore_Move;

	var notifTw : dn.Tweenie;
    var _gold : Int = 0;
	var _ap : Int;
	public var Gold(get, set):Int;

	function get_Gold() return _gold;
	function set_Gold(v) {
     if(v <= 0) v = 0;

	  _gold = v;
	  planetInspector.updateHUD(Gold,AP,gm.MaxAP);
	  return _gold;
	}

	public var AP(get,set):Int;
	function get_AP() return _ap;
	function set_AP(v) {
        if(v < 0)
        {
            v = 0;
        } 
        if(v > gm.MaxAP)
    		v = gm.MaxAP;

        _ap = v;
		planetInspector.updateHUD(Gold,AP,gm.MaxAP);
		return _ap;
	}


	var ca : ControllerAccess<GameAction>;

    var playerEntity : Entity;
    var planetState : PlanetState;

    var tile_statuses : Array<Array<TILE_STATUS>>; 
    var mapTiles : Array<Array<Entity>>;

    var planetInspector : PlanetInspectorWindow;
    var planetProcess : PlanetProcess;
    var gm : GameManager;

    public function addGold(value : Int)
    {
        Gold += value;

        if(value > 0)
            hxd.Res.sounds.sfx.Gold_Earn.play(false, 0.6);
        else
            hxd.Res.sounds.sfx.Gold_Nothing.play(false, 1.0);
    }

    public function addAP(value : Int)
    {
        AP += value;

        if(value != 0)
        {
            if(value > 0)
                hxd.Res.sounds.sfx.AP_Earn.play(false, 0.6);
            else if(value < 0)
                hxd.Res.sounds.sfx.AP_Lost.play(false, 0.5);
        }
    }
    public function new(state:PlanetState)
    {
        super(0,0);
        planetInspector = new PlanetInspectorWindow();

        gm = cast(Game.ME, GameManager);
        planetState = state;
		ME = this;

		notifTw = new Tweenie(Const.FPS);


        hei = planetState.planetSize*16;
        wid = planetState.planetSize*16;
        

        spr.setTexture(h3d.mat.Texture.fromColor(White));
        
        // spr.set(Tile.fromColor(White,Std.int(wid+8),Std.int(hei+8)));
        spr.setCenterRatio(0,0);
        spr.fitToBox(wid+8,hei+8);
        spr.setPosition(-4,-4);

        planetProcess = new PlanetProcess();
        // spr.setScale(planetState.planetSize/3);
        AP = gm.MaxAP;


		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

        tile_statuses = [for (x in 0...planetState.planetSize) [for (y in 0...planetState.planetSize) HIDDEN]]; 
        mapTiles = [for (x in 0...planetState.planetSize) [for (y in 0...planetState.planetSize) null]];
        for(y in 0...planetState.planetSize)
        {
            for(x in 0...planetState.planetSize)
            {
                var e = new Entity(x,y);
                if(gm.buildingsLevel[RADAR] > 0 && planetState.getTileType(x,y) != VIDE)
                    e.spr.set(AssetsDictionaries.tiles.map_hidden_spotted);
                else
                    e.spr.set(AssetsDictionaries.tiles.map_hidden);
                mapTiles[x][y] = e;
            }
        }

       

        revealTiles(state.startPosX, state.startPosY, gm.buildingsLevel[SCOPE]);
        
        playerEntity = new Entity(state.startPosX,state.startPosY);
        playerEntity.spr.set(AssetsDictionaries.tiles.map_player);

        nf_cx = state.startPosX;
        nf_cy = state.startPosY;



        updateTileInspector(state.startPosX, state.startPosY);

         
		// Camera tracks this
		// camera.trackEntity(mapTiles[state.startPosX][state.startPosY], true,0.5);
		camera.trackEntity(mapTiles[planetState.startPosX][planetState.startPosY], true,0.5);
		camera.clampToLevelBounds = false;
        camera.targetOffX = wid/2;
    //    camera.targetOffY = -hei/2;
        camera.targetZoom = 2-((-5+planetState.planetSize)*0.15);
        camera.centerOnTarget();

        Console.ME.add("reveal", ()->
        {
            for(y in 0...planetState.planetSize)
                {
                    for(x in 0...planetState.planetSize)
                    {
                        revealTile(x,y);
                    }
                }
        });

        
    }

    var wantedX:Int = 0;
    var wantedY:Int = 0;

    var canMove:Bool = true;

    var nf_cx:Int =0;
    var nf_cy:Int = 0;

    override function preUpdate() 
    {
        super.preUpdate();

        wantedX = 0;
        wantedY = 0;

        if(!canMove)
            return;

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
        else if(ca.isPressed(Interact))
            tryDigTile(playerEntity.cx, playerEntity.cy);
    }

    override function postUpdate()
    {
        if((wantedX != 0 || wantedY != 0) && tryMove(playerEntity.cx+wantedX, playerEntity.cy+wantedY))
        {
            moveSound.stop();
            moveSound.play(false, 0.4);
        }
        playerEntity.spr.alpha = (Math.sin(game.stime*10)+1)*0.5*0.5+0.25;
        checkEndRun(nf_cx, nf_cy);
    }

    function updateTileInspector(cx:Int, cy:Int)
    {
        var payload = planetState.inspectCase(cx, cy, gm.buildingsLevel[ANALYZER]);
        payload.action = (tile_statuses[cx][cy] == FOUILLED) ? 'Nothing left to do here' : payload.action;

        planetInspector.updateTile(payload);
    }

    function tryMove(ncx:Int, ncy:Int):Bool
    {
        var canMove : Bool = isInBounds(ncx,ncy)&&(ncx!=playerEntity.cx||ncy!=playerEntity.cy);
        if(!canMove)
            return false;

        playerEntity.setPosCase(ncx,ncy);
        AP--;
        revealTiles(ncx, ncy, gm.buildingsLevel[SCOPE]);

        updateTileInspector(ncx, ncy);
        
        //PRE-SHOT FUCKING FRAME BULLSHIT
        nf_cx=ncx;
        nf_cy=ncy;

        return true;
    }

    function revealTiles(ncx:Int, ncy:Int, scopeLevel:Int)
    {
        if(scopeLevel <= 0)
        {
            if(isInBounds(ncx, ncy))
                revealTile(ncx, ncy);
        }
        else
        {
            var iScopeLevel = Math.ceil(scopeLevel / 2.0);
            for(y in (ncy - iScopeLevel)...(ncy + iScopeLevel + 1))
            {
                for(x in (ncx - iScopeLevel)...(ncx + iScopeLevel + 1))
                {
                    if(!isInBounds(x, y))
                        continue;
                    
                    if(scopeLevel % 2 == 0 || // If even, use "Chebyshev"
                        Math.abs(x - ncx) + Math.abs(y - ncy) <= iScopeLevel) // If odd, use "Manhattan"
                    {
                        if(tile_statuses[x][y] == HIDDEN)
                        {
                            revealTile(x, y);
                        }
                    }
                }
            }
        }
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
                return false;
            }

        canMove = false;
        hxd.Res.sounds.sfx.Explore_Digging.play(false, 0.5);
        planetInspector.DigNow(

            ()->
            {
                    canMove = true;
                    AP--;
                    var str = planetState.digCase(cx,cy);
                    rewardModal(str, ()->{
                        tile_statuses[cx][cy] = FOUILLED;
                        mapTiles[cx][cy].spr.set('map_fouilled_$caseType');
                        updateTileInspector(cx,cy);
                    });
            
            }
        );



        return true;
    }

    inline function isInBounds(cx:Int,cy:Int):Bool
    {
        return cx>=0&&cx<planetState.planetSize&&cy>=0&&cy<planetState.planetSize;
    }

    
    override function dispose() {
		super.dispose();
        planetInspector.destroy();
        planetProcess.destroy();
	}

    function checkEndRun(cx:Int, cy:Int)
    {
        if(AP <= 0)
            triggerEndRun(cx != planetState.startPosX || cy != planetState.startPosY);
    }

    function triggerEndRun(lost:Bool)
    {
        var m = new Menu();

        if(lost)
            Gold = Std.int(Gold * (gm.buildingsLevel[EXTRACTOR] * 0.1));

        gm.addPermanentGold(Gold);
        m.addTitle(lost?"FAILURE":"SUCCESS");
        m.addSpacer();
        m.addTitle('You\'re coming home with ${Gold}g');
        m.addSpacer();
        m.addButton("Ok", gm.switchToVillage,true);
        hxd.Res.sounds.sfx.Explore_Result.play(false, 0.5);
    }

    function rewardModal(str:String, cb:()->Void)
    {

        var m = new Menu();
        m.win.maxWidth=300;
        
        m.addTitle(str);
        m.addSpacer();
        m.addButton("Ok", cb,true);
    }

}