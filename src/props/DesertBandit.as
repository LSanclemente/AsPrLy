package props
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.State;
	import com.citrusengine.objects.platformer.Baddy;
	
	import flashx.textLayout.formats.Float;
	
	import props.proyectiles.LylliaBullet;
	
	public class DesertBandit extends Baddy
	{
		public static var  DEFAULT_ATTACK_DISTANCE:int = 20;
		public static var DEFAULT_WALK_DISTANCE:int = 60;
		public static var DEFAULT_ATACK_TIME:Float = 500 ;
		
		private var attackDistance:int = DEFAULT_ATTACK_DISTANCE;
		private var walkDistance:int = DEFAULT_WALK_DISTANCE;
		
		//private armed:Boolean= true; //the bandit is still armed
		private var walk:Boolean= false; //the bandit is still armed
		private var attack:Boolean= false; //the bandit is still armed
		
		private var lives:int= 3; //count of hurts the bandit can take
		
		public function DesertBandit(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		public function DesertBandit(name:String, attackDistance:int, walkDistance:int,  params:Object=null)
		{
			super(name, params);
			if(attackDistance!= null)  this.attackDistance = attackDistance;
			if(walkDistance!= null)  this.walkDistance = walkDistance;
		}
		
		
		override public function update(timeDelta:Number):void{
			
			var currentState:State = CitrusEngine.getInstance().state;
			
			var lyllia: Lyllia = currentState.getFirstObjectByType(Lyllia) as Lyllia;
			var distance_x:int = abs(lyllia.x-this.x);
			
			if (this.armed){ //this got his weapon
				if ((_inverted && lyllia.x > this.x) || (!_inverted && lyllia.x < this.x))
					turnAround();
				
				if (distance_x < this.attackDistance){
					//stop stop walking start attacking
					this.attack= true;
					this.walk= false;
					
					
				}else if (distance_x < this.walkDistance){
					//stop idle start walking
					this.attack= false;
					this.walk= true; 
					var velocity:V2 = _body.GetLinearVelocity();
					if (!_hurt)
					{
						if (_inverted)
							velocity.x = -speed;
						else
							velocity.x = speed;
					}
				} 
			}else{ 
				//chicken mode on
				if (_inverted)
					velocity.x = speed*2;
				else
					velocity.x = -speed*2;
			}
			updateAnimation();
		}
		
		override function updateAnimation():void
		{
			/*
			if (!this.armed)
			_animation = "unarmed";
			else
			*/
			if (_hurt)
				_animation = "hurt";
			else if (this.kill)
				_animation = "kill";
			else if (this.walk)
				_animation = "walk";
			else if (this.attack)
				_animation = "attack";
			else
				_animation = "idle";
		}
		
		override function hurt():void
		{
			_hurt = true;
			this.lives--; 
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		}
		
		override function endHurtState():void
		{
			_hurt = false;
			if (this.lives <= 0) kill = true;
		}
		
		override function handleBeginContact(e:ContactEvent):void
		{
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
			
			if (collider is LylliaBullet)
				hurt();
			
		}
		
		
	}
}