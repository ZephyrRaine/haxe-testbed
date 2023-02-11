package ui;


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
    

    public function updateTile(t:PlanetState.TILE_TYPE, status:PlanetExploration.TILE_STATUS)
    {
        action.text = status==PlanetExploration.TILE_STATUS.REVEALED?"Space - Dig (1AP)":"Nothing left to do here";
        // TODO: analyzer.text = "Golds: 70% [10~30] | AP: 30 % [-1]";
        switch(t)
        {
            case VIDE:
                title.text = "Empty";
                description.text = "Nothing to see here";
            case SHIP:
                title.text = "Ship";
                description.text = "Your beloved ship";
                action.text = "Space - Return Home (0AP)"; 
            case CREVASSE:
                title.text = "Crevasse";
                description.text = "A bottomless pit";
            case WRECK:
                title.text = "Wreck";
                description.text = "Someone was less lucky than you";
            case VILLAGE:
                title.text = "Village";
                description.text = "People used to live here?!";
            case ORE:
                title.text = "Ore";
                description.text = "A shiny rock";
            case PLANT:
                title.text = "Plant";
                description.text = "You can't eat this";
            case CORPSE:
                title.text = "Corpsed";
                description.text = "Kinda horrible";

        }
    }
}