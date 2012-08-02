package 
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Coin;
	import com.citrusengine.objects.platformer.Crate;
	import com.citrusengine.objects.platformer.Missile;
	import com.citrusengine.objects.platformer.MovingPlatform;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.objects.platformer.RewardBox;
	import com.citrusengine.objects.platformer.Sensor;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import props.Destructible;
	import props.Lyllia;
	import props.TimeDestructible;
	
	public class Main extends CitrusEngine 
	{
		public var instructionText:TextField;
		
		public function Main():void 
		{
			super();
			
			var classes:Array = [Baddy, CitrusSprite, Coin, Crate, Destructible, Lyllia, TimeDestructible, Missile, MovingPlatform, PhysicsObject, Platform, RewardBox, Sensor];
			console.addCommand("play", handlePlayCommand);
			createInstructionText();
		}
		
		private function handlePlayCommand(levelPath:String):void
		{
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, handleLevelLoadComplete);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleLevelLoadError);
			
			trace("handlePlayCommand");
			if (levelPath.indexOf(".lev") == -1)
				levelPath += ".lev";
			
			l.load(new URLRequest(levelPath));
		}
		
		private function handleLevelLoadComplete(e:Event):void
		{
			trace("handleLevelLoadComplete");
			if (instructionText.parent)
				removeChild(instructionText);
			state = new GameState(XML(e.target.data));
		}
		
		private function handleLevelLoadError(e:IOErrorEvent):void 
		{
			trace("handleLevelLoadError");
			instructionText.text = "The level you typed does not exist. Please check the file name and try again.\nIf your level is in a subdirectory relative to this SWF, you will need to specify that directory in the command.\nFor example: 'play levels/level1'";
		}
		
		private function createInstructionText():void
		{
			trace("createInstructionText");
			instructionText = new TextField();
			addChild(instructionText);
			instructionText.autoSize = "left";
			instructionText.x = 10;
			instructionText.y = 30;
			instructionText.defaultTextFormat = new TextFormat("_sans");
			instructionText.text = "Press tab to open the console. Then type 'play levelName' where levelName is the name of the level file you made.\nFrom the console, you can use the up/down arrow keys to quickly access your previous commands.";
			instructionText.appendText("\n\nWhile in a level, you can turn the 'debug graphics' on and off by using this command: 'set Box2D visible true'");
		}
	}
	
}