package assets;

import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
class Assets {

	// Fonts
	public static var fontPixel : h2d.Font;
	public static var fontPixelMono : h2d.Font;
	public static var spaceFont : h2d.Font;
	public static var titleFont : h2d.Font;
	public static var menuFont : h2d.Font;
	/** Main atlas **/
	public static var tiles : SpriteLib;
	public static var hero : SpriteLib;
	public static var merchant : SpriteLib;
	public static var mudGuard : SpriteLib;
	public static var redDude : SpriteLib;
	public static var smallDroid : SpriteLib;
	public static var totemDude : SpriteLib;

	/** LDtk world data **/
	public static var worldData : World;

	public static var planets: Array<h2d.Tile>;

	static var _initDone = false;
	public static function init() {
		if( _initDone )
			return;
		_initDone = true;

		// Fonts
		fontPixel = new hxd.res.BitmapFont( hxd.Res.fonts.pixel_unicode_regular_12_xml.entry ).toFont();
		fontPixelMono = new hxd.res.BitmapFont( hxd.Res.fonts.pixica_mono_regular_16_xml.entry ).toFont();
		spaceFont = new hxd.res.BitmapFont( hxd.Res.fonts.ExpressionPro.entry ).toFont();
		titleFont = new hxd.res.BitmapFont( hxd.Res.fonts.FutilePro.entry ).toFont();
		menuFont = new hxd.res.BitmapFont( hxd.Res.fonts.MatchupPro.entry ).toFont();



		// gameJamFont = new hxd.res.BitmapFont(hxd.Res.fonts.gamejam_font_16_xml.entry).toFont();
		planets = [for (x in 1...127) hxd.Res.loader.load('bg/planets/body/$x.png').toTile()];
		// build sprite atlas directly from Aseprite file
		tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
		hero = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.hero.toAseprite());
		merchant = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.merchant.toAseprite());
		mudGuard = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.mudGuard.toAseprite());
		redDude = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.redDude.toAseprite());
		smallDroid = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.smallDroid.toAseprite());
		totemDude = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.totemDude.toAseprite());

		// Hot-reloading of CastleDB
		#if debug
		hxd.Res.data.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("cdb");
			App.ME.delayer.addS("cdb", function() {
				CastleDb.load( hxd.Res.data.entry.getBytes().toString() );
				Const.db.reload_data_cdb( hxd.Res.data.entry.getText() );
			}, 0.2);
		});
		#end

		// Parse castleDB JSON
		CastleDb.load( hxd.Res.data.entry.getText() );

		// Hot-reloading of `const.json`
		hxd.Res.const.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("constJson");
			App.ME.delayer.addS("constJson", function() {
				Const.db.reload_const_json( hxd.Res.const.entry.getBytes().toString() );
			}, 0.2);
		});

		// LDtk init & parsing
		worldData = new World();

		// LDtk file hot-reloading
		#if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch(_) null; // assume the LDtk file is in "res/" subfolder
		if( res!=null )
			res.watch( ()->{
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				App.ME.delayer.cancelById("ldtk");
				App.ME.delayer.addS("ldtk", function() {
					worldData.parseJson( res.entry.getText() );
					if( Game.exists() )
						Game.ME.onLdtkReload();
				}, 0.2);
			});
		#end
	}


	/**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
	public static function update(tmod:Float) {
		if( Game.exists() && Game.ME.isPaused() )
			tmod = 0;

		tiles.tmod = tmod;
		// <-- add other atlas TMOD updates here
	}

}