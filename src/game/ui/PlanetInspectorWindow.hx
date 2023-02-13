package ui;

import sample.GameManager;
import PlanetState.InspectorPayload;

class PlanetInspectorWindow extends Window
{
    var title:h2d.Text;
    var description:h2d.Text;
    var action:h2d.Text;
    var analyzer:h2d.Text;

	var goldText : h2d.Text;
    var apText : h2d.Text;

    var _barValue : Float = 0;
	public var BarValue(default,set) : Float = 0;
    function set_BarValue(v)
    {
        _barValue = v;
        updateBar(v);
        return _barValue;
    }

    var bar : Bar;

    public override function new() {
        super(null);
        win.padding = 10;
        win.layout = Vertical;
        win.backgroundTile = Assets.tiles.getTile("ui_border_2");
       // win.setPosition((w()- 100)/Const.UI_SCALE , 50/Const.UI_SCALE);
       
       win.horizontalAlign = Right;
       win.minWidth = 150;
       win.maxWidth = 150;

       var f = new h2d.Flow(win);
        f.padding = 2;
        f.horizontalSpacing = 20;
       f.layout = Horizontal; 
       goldText = new h2d.Text(Assets.menuFont, f);
       goldText.filter = new dn.heaps.filter.PixelOutline();
       apText = new h2d.Text(Assets.menuFont, f);
        apText.filter =  new dn.heaps.filter.PixelOutline();

        var f = new h2d.Flow(win);
        f.padding = 2;


        title = new h2d.Text(Assets.titleFont, f);
        title.textColor = Col.white();
        title.text = "Salut";

        var f = new h2d.Flow(win);
		f.padding = 2;

        description = new h2d.Text(Assets.menuFont, f);
        description.textColor = Col.fromInt(0xbbbbbb);
        description.text = "A barren land.";
        
        var f = new h2d.Flow(win);
		f.padding = 2;

        action = new h2d.Text(Assets.menuFont, f);
        action.textColor = Col.white();
        action.text = "Dig (1AP)";

        var f = new h2d.Flow(win);
		f.padding = 2;

        bar = new Bar(Std.int(100),5, Col.white(), f);

        var f = new h2d.Flow(win);
		f.padding = 2;

        analyzer = new h2d.Text(Assets.fontPixelMono, f);
        analyzer.textColor = Col.fromInt(0x95b89d);
        analyzer.text = '';
        analyzer.textAlign = Right;


		updateHUD(0,0,0);
		dn.Process.resizeAll();

    }

    override function onResize() {
		super.onResize();

		root.setScale(Const.UI_SCALE);

		var w = M.ceil( w()/Const.UI_SCALE );
		var h = M.ceil( h()/Const.UI_SCALE );
		win.x = Std.int( w - (win.outerWidth +20));
		win.y = Std.int( 20);
	}


    public function updateHUD(gold:Int, AP:Int, AP_MAX:Int)
    {
        // variablesText.text = 'g:$gold - ap:$AP';
       goldText.text = '${gold} gold';
       apText.text = '${AP} action points';
       goldText.textColor = Col.graduate(gold/150, Col.white(), 0xFFD689, 0xFFA600);
       apText.textColor = Col.graduate(1-(AP/AP_MAX),Col.green(), Col.white(), Col.red());
    }

    function updateBar(v:Float)
    {
        v = Math.min(Math.max(v,0),1);
        bar.set(v,1);
    }
    

    public function updateTile(payload : InspectorPayload)
    {
        title.text = payload.title;
        action.text = payload.action;
        description.text = payload.description;
        analyzer.text = payload.analyzer;
    }

	public function DigNow(cb:() -> Void) {

        action.text = "Digging...";
        BarValue = 0;
        var p = Game.ME.createChildProcess();
        p.tw.createS(BarValue, 1, TEaseOut, Lib.rnd(2,3+(5-cast(Game.ME, GameManager).buildingsLevel[EXTRACTOR])*0.5)).end(()->{
            p.destroy();
            cb();
        });

    }
}