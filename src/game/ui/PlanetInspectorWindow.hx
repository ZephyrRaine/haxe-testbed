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

        var f = new h2d.Flow(win);
		f.padding = 2;


        title = new h2d.Text(Assets.fontPixel, f);
        title.textColor = Col.black();
        title.text = "Salut";

        var f = new h2d.Flow(win);
		f.padding = 2;

        description = new h2d.Text(Assets.fontPixelMono, f);
        description.textColor = Col.black();
        description.text = "A barren land.";
        
        var f = new h2d.Flow(win);
		f.padding = 2;

        action = new h2d.Text(Assets.fontPixelMono, f);
        action.textColor = Col.black();
        action.text = "Space - Dig (1AP)";

        var f = new h2d.Flow(win);
		f.padding = 2;

        analyzer = new h2d.Text(Assets.fontPixelMono, f);
        analyzer.textColor = Col.green();
        analyzer.text = '';

        variablesText = new h2d.Text(Assets.fontPixel, root);
		variablesText.filter = new dn.heaps.filter.PixelOutline();
		updateHUD(0,0);

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