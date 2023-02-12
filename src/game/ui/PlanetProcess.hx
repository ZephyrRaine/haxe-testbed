package ui;

import h2d.Bitmap;

class PlanetProcess extends GameChildProcess
{
    public override function new()
    {
        super();


		createRootInLayers(game.root, Const.DP_BG);
		root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering
        

        
        var v = new Bitmap(Assets.planets[Lib.irnd(0,Assets.planets.length)], root);
        v.scale(6);

        
		var w = M.ceil( w()/Const.UI_SCALE*0.9 );
		var h = M.ceil( h()/Const.UI_SCALE*0.9 );

        v.setPosition(w-125, 25);

        onResize();
    }

    
	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE*0.9);
	}

	override function preUpdate() {
		super.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

	}
}