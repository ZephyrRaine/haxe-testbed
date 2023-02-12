import ui.Window;
import ui.Hud;

class VillageHUD extends Hud
{
    
	public var villageHUD:Window;
	var variablesText : h2d.Text;

    public function new()
    {
        super();
        var f = new h2d.Flow(root);
        f.horizontalAlign = Middle;
        variablesText = new h2d.Text(Assets.titleFont, f);
        variablesText.textColor = Col.white();
        variablesText.textAlign = Center;
        
        
		var w = M.ceil( w()/Const.UI_SCALE );
		var h = M.ceil( h()/Const.UI_SCALE );
        f.x = w*0.5;
        f.y = 10;

		variablesText.filter = new dn.heaps.filter.PixelOutline();
    }
    

    public function updateGold(gold:Int) {
        variablesText.text = '$gold g';
    }
}