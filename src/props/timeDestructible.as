package props
{
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Missile;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import props.Lyllia;
	import props.Destructible;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author 
	 */
	public class timeDestructible extends Destructible
	{
		[Property(value = "500")]
		public var timeToBanish:Number = 500
		
		protected var _banishTimeoutID:Number;
		
		private var _destroyerClass:Class = Lyllia;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number):timeDestructible
		{
			return new timeDestructible(name, { x: x, y: y, width: width, height: height } );
		}
		
		public function timeDestructible(name:String, params:Object = null )
		{
			super(name, params);
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			clearTimeout(_banishTimeoutID);
			super.destroy();
		}
		
		public function banish():void
		{
			_banishTimeoutID = setTimeout(banishState,timeToBanish);
			}
		
		[Property(value="code.lyllia.Lyllia")]
		override public function set destroyerClass(value:*):void
		{
			if (value is String)
				_destroyerClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_destroyerClass = value;
		}
		override protected function handleBeginContact(e:ContactEvent):void
		{
			
			if (_destroyerClass && e.other.GetBody().GetUserData() is _destroyerClass)
			{
				banish();
			}
		}
		public function banishState():void
		{
			kill = true;
			}
	}
	
}