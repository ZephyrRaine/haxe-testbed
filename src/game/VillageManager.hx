import ui.Window;
import ui.Hud;

class VillageHUD extends Hud
{
    
	public var villageHUD:Window;
	var variablesText : h2d.Text;

    public function new()
    {
        super();

        variablesText = new h2d.Text(Assets.fontPixel, root);
		variablesText.filter = new dn.heaps.filter.PixelOutline();
    }
    

    public function updateGold(gold:Int) {
        variablesText.text = '$gold gold';
    }
}