package props
{
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Missile;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author 
	 */
	public class Destructible extends PhysicsObject
	{
		[Property(value = "10")]
		public var hitPoints:Number = 10;
		
		private var _destroyerClass:Class = Missile;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number):Destructible
		{
			return new Destructible(name, { x: x, y: y, width: width, height: height } );
		}
		
		public function Destructible(name:String, params:Object = null )
		{
			super(name, params);
		}
		
		[Property(value="com.citrusengine.objects.platformer.Missile")]
		public function set destroyerClass(value:*):void
		{
			if (value is String)
				_destroyerClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_destroyerClass = value;
		}
			
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			super.destroy();
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.restitution = 0;
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		}
		protected function handleBeginContact(e:ContactEvent):void
		{
			
			if (_destroyerClass && e.other.GetBody().GetUserData() is _destroyerClass)
			{
				hitPoints -= 4;
				if (hitPoints <= 0){ 
				kill = true; }
			}
		}
	}
	
}