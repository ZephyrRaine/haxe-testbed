package sample;

import h2d.Bitmap;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	var ca : ControllerAccess<GameAction>;
	var walkSpeed = 0.;

    var interactTooltip : Bitmap;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && v.dy==0 && yr==1 && level.hasCollision(cx,cy+1);


	public function new() {
		super(5,5);

		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null )
			setPosCase(start.cx, start.cy);

		// Misc inits
		v.setFricts(0.84, 0.94);

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.targetZoom = 1.5;
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

		// Player
		spr.set(Assets.hero);
		spr.setCenterRatio(0.41, 1.0);

		spr.anim.registerStateAnim("idle", 0, 1.0);
		spr.anim.registerStateAnim("run", 5, 1.0, ()->walkSpeed!=0.0);

		interactTooltip = new h2d.Bitmap(Assets.tiles.getTile("UI_X_Button"),spr);
        interactTooltip.tile.setCenterRatio(0.5,0.5);
        interactTooltip.y = -(hei+30);
        interactTooltip.visible = false;
		//spr.anim.registerTransitions(["idle"],["walk"],"idleWalk", 0.5);
	}

	public inline function isMoving() {
		return isAlive() && ( M.fabs(dxTotal)>=0.03 || M.fabs(dyTotal)>=0.03 );
	}

	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		if( xr>0.8 && level.hasCollision(cx+1,cy) )
			xr = 0.8;

		// Left collision
		if( xr<0.2 && level.hasCollision(cx-1,cy) )
			xr = 0.2;
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground
		if( yr>1 && level.hasCollision(cx,cy+1) ) {
			setSquashY(0.5);
			v.dy = 0;
			vBump.dy = 0;
			yr = 1;
		//	ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
		}

		// Ceiling collision
		if( yr<0.2 && level.hasCollision(cx,cy-1) )
			yr = 0.2;
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


		// Jump
		if( cd.has("recentlyOnGround") && ca.isPressed(Jump) ) {
			v.dy = -0.85;
			setSquashX(0.6);
			cd.unset("recentlyOnGround");
			// fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
		//	ca.rumble(0.05, 0.06);
//			hxd.Res.sounds.sfx.Jump.play(false, 0.5);
		}

		// Walk
		if( ca.getAnalogDist2(MoveLeft,MoveRight)>0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue2(MoveLeft,MoveRight); // -1 to 1
		}

		checkEntities();
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

	var currentBuilding:Building;

	function checkEntities()
	{
		var currentShip = en.Ship.Instance;

		if(currentShip != null && distPx(currentShip) <= currentShip.largeRadius)
		{
			interactTooltip.visible = true;
			hud.debug(currentShip.getDisplayName());
			if(ca.isPressed(Interact))
			{
				interactTooltip.visible = false;
				currentShip.displayPopUp();
			}
		}
		else
		{
			
			if(currentBuilding != null)
				currentBuilding.showLabel(false);
			
			currentBuilding = null;

			for(b in en.Building.ALL)
			{
				if(distPx(b) <= b.largeRadius)
				{
					currentBuilding = b;
				}
			}



			if(currentBuilding != null)
			{
			//	interactTooltip.visible = true;
			//	hud.debug(currentBuilding.getDisplayName());
				currentBuilding.showLabel(true);
				if(ca.isPressed(Interact))
				{
					interactTooltip.visible = false;
					currentBuilding.displayPopUp();
				}
			}
			else
			{
				interactTooltip.visible = false;
				hud.debug("");
			}
		}
	}
}