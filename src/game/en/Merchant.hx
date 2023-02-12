package en;

class Merchant extends Entity {
	var walkSpeed = 0.;
    
    var minDelayMove = 4.0;
    var maxDelayMove = 12.0;
    var minDurationMove = 0.5;
    var maxDurationMove = 2.0;
    var minClampX : Int;
    var maxClampX : Int;
    var timerMove = 0.;
    var moveDir = 0;

	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && v.dy==0 && yr==1 && level.hasCollision(cx,cy+1);

	public function new(_sprLib:SpriteLib, _xCenter:Float, _xPos:Int, _yPos:Int, _clampX:Int) {
		super(_xPos,_yPos);

		// Misc inits
		v.setFricts(0.84, 0.94);

        minClampX = _xPos - _clampX;
        maxClampX = _xPos + _clampX;

		// Player
		spr.set(_sprLib);
		spr.setCenterRatio(_xCenter, 1.0);

		spr.anim.registerStateAnim("idle", 0, 1.0);
		spr.anim.registerStateAnim("run", 5, 1.0, ()->walkSpeed!=0.0);
		//spr.anim.registerTransitions(["idle"],["walk"],"idleWalk", 0.5);
	}

	public inline function isMoving() {
		return isAlive() && ( M.fabs(dxTotal)>=0.03 || M.fabs(dyTotal)>=0.03 );
	}


	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

        timerMove -= tmod;
        if( timerMove<=0. ) {
            UpdateMoveState();
        }

		walkSpeed = 0;
		if( onGround )
			cd.setS("recentlyOnGround",0.1); // allows "just-in-time" jumps

		// Walk
		if( moveDir != 0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = moveDir; // -1 to 1
        }
    }


	override function fixedUpdate() {
		super.fixedUpdate();

		// Gravity
		if( !onGround )
			v.dy+=0.05;

		// Apply requested walk movement
		if( walkSpeed != 0 )
			v.dx += walkSpeed * 0.0040; // some arbitrary speed


        
		set_dir(Std.int(walkSpeed));

		if((cx <= minClampX && moveDir < 0)|| (cx >= maxClampX && moveDir > 0))
            moveDir = -moveDir;
	}

    private function UpdateMoveState()
    {
        if(moveDir == 0)
        {
            moveDir = dn.Lib.irnd(0,1) * 2 - 1;
            timerMove = dn.Lib.rnd(minDurationMove, maxDurationMove) * 100;
        }
        else
        {
            moveDir = 0;
            timerMove = dn.Lib.rnd(minDelayMove, maxDelayMove) * 100;
        }
    }
}