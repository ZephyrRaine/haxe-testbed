package ui;

import PlanetState.InspectorPayload;

class PlanetInspectorWindow extends Window
{
    var title:h2d.Text;
    var description:h2d.Text;
    var action:h2d.Text;
    var analyzer:h2d.Text;

	var variablesText : h2d.Text;

    public override function new() {
        super(null);
        win.padding = 10;
        win.layout = Vertical;
        win.backgroundTile = Assets.tiles.getTile("ui_border_2");
       // win.setPosition((w()- 100)/Const.UI_SCALE , 50/Const.UI_SCALE);
        var f = new h2d.Flow(win);
        win.horizontalAlign = Right;
		win.minWidth = 150;
		win.maxWidth = 150;
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
        action.text = "Space - Dig (1AP)";

        var f = new h2d.Flow(win);
		f.padding = 2;

        analyzer = new h2d.Text(Assets.fontPixelMono, f);
        analyzer.textColor = Col.fromInt(0x95b89d);
        analyzer.text = '';
        analyzer.textAlign = Right;

        variablesText = new h2d.Text(Assets.menuFont, root);
		variablesText.filter = new dn.heaps.filter.PixelOutline();
		updateHUD(0,0);
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


    public function updateHUD(gold:Int, AP:Int)
    {
        variablesText.text = 'g:$gold - ap:$AP';
    }
    

    public function updateTile(payload : InspectorPayload)
    {
        title.text = payload.title;
        action.text = payload.action;
        description.text = payload.description;
        analyzer.text = payload.analyzer;
    }
}