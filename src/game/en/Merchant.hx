package en;

class Merchant extends Entity {
	var walkSpeed = 0.;

	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && v.dy==0 && yr==1 && level.hasCollision(cx,cy+1);

	public function new(sprLib:SpriteLib, xCenter:Float, xPos:Int, yPos:Int) {
		super(xPos,yPos);

		// Misc inits
		v.setFricts(0.84, 0.94);

		// Player
		spr.set(sprLib);
		spr.setCenterRatio(xCenter, 1.0);

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

		walkSpeed = 0;
		if( onGround )
			cd.setS("recentlyOnGround",0.1); // allows "just-in-time" jumps

		// Walk
		// if( ca.getAnalogDist2(MoveLeft,MoveRight)>0 ) {
		// 	// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
		// 	walkSpeed = ca.getAnalogValue2(MoveLeft,MoveRight); // -1 to 1
    }


	override function fixedUpdate() {
		super.fixedUpdate();

		// Gravity
		if( !onGround )
			v.dy+=0.05;

		// Apply requested walk movement
		if( walkSpeed!=0 )
			v.dx += walkSpeed * 0.045; // some arbitrary speed

		set_dir(Std.int(walkSpeed));

		
	}
}