package props
{
	import com.citrusengine.objects.platformer.Hero;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import com.citrusengine.objects.platformer.Missile;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.objects.platformer.Sensor;
	import com.citrusengine.physics.CollisionCategories;
	import flash.display.MovieClip;
	import org.osflash.signals.natives.base.SignalBitmap;
	
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.core.CitrusEngine;
	
	import flash.media.Video;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	import props.proyectiles.LylliaBullet;

	
	/**
	 * Esta es Lyllia la heroina de Assault Princess
	 * Puede correr, saltar, agacharse, disparar, recibir daño, morir y tiene una barra de vida.
	 */	
	public class Lyllia extends Hero
	{
		//propiedades
		
		/* Not used 
			killVelocity
			enemySpringHeight
			enemySpringJumpHeight
		*/
		/**
		 * Retardo entre disparos
		 */
		[Property]
		private var delayDuration:Number = 1300;
		
		//eventos
				
		/**
		 * Disparado cada vez que Lyllia dispara.
		 */
		public var onShoot:Signal;
		
		// properties for ladder
		[Property]
		public var originalGravity:Number = 1.6;
		public var canClimb:Boolean = false;
		public var climbVelocity:Number = 5;
		public var ladder:Sensor;
		protected var _onLadder:Boolean = false;
		
		[Inspectable]
		protected var _climbing:Boolean = false;
		
		[Property]
		protected var _climbAnimation:String = "escaleraidle";
		
		//end properties for ladder
		protected var _shootDelayTimeoutID:Number;
		protected var _shootDelay:Boolean = false;
		protected var _playerMovingLyllia:Boolean = false;
		protected var _bulletN:Missile;
		
		public function Lyllia(name:String, params:Object = null)
		{
			super(name, params);
			this.view = "art/sprites/lyllia.swf" 
			originalGravity = gravity;
			onShoot = new Signal();	
			trace("lyllia created");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportPreSolve = true;
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
		
		override public function update(timeDelta:Number):void
		{
			var input_z:int = 90;
			var input_x:int = 88;
			super.update(timeDelta);
			
			var velocity:V2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDown(Keyboard.DOWN) && _onGround && canDuck);
				
				if (_ce.input.isDown(Keyboard.RIGHT) && !_ducking)
				{
					if (canClimb) 
					{
						gravity = originalGravity;
						_climbing = false;
					}
					velocity.x += (acceleration);
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDown(Keyboard.LEFT) && !_ducking)
				{
					if (canClimb) 
					{
						gravity = originalGravity;
						_climbing = false;
					}
					
					velocity.x -= (acceleration);
					moveKeyPressed = true;
				}
				_onLadder = ((_ce.input.isDown(Keyboard.DOWN) || _ce.input.isDown(Keyboard.UP)) && canClimb);
				
				if (_onLadder) {
					if (x < ladder.x) 
						x++;
					if (x > ladder.x)
						x--;
				}
				
				if (_ce.input.isDown(Keyboard.UP) && canClimb) {
					_onLadder = _climbing = true;
					_climbAnimation = "escala";
					velocity = new V2(0, 0);
					velocity.y -= climbVelocity;
					gravity = 0;
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDown(Keyboard.DOWN) && canClimb) {
					_onLadder = _climbing = true;
					_climbAnimation = "escala";
					velocity = new V2(0, 0);
					velocity.y += climbVelocity;
					gravity = 0;
					moveKeyPressed = true;
				}
				
				// Remove velocity if just stop climbing
				if ((_ce.input.justReleased(Keyboard.UP) || _ce.input.justReleased(Keyboard.DOWN)) && canClimb) {
					_climbAnimation = "escaleraidle";
					velocity.y = 0;
				}
				
				if (canClimb && _ce.input.justPressed(Keyboard.SPACE)) {
					_climbing = false;
					gravity = originalGravity;
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingLyllia)
				{
					_playerMovingLyllia = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
					//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingLyllia)
				{
					_playerMovingLyllia = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				if (_onGround && _ce.input.justPressed(input_z) && !_ducking)
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				if (_ce.input.isDown(input_z) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				if (_ce.input.isDown(input_x) && _shootDelay == false)
				{
					
					if (_ce.input.isDown(Keyboard.UP) && _ce.input.isDown(Keyboard.RIGHT)&& !_ducking) {	
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x +50, y:this.y -55, angle:329, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_ce.input.isDown(Keyboard.UP) && _ce.input.isDown(Keyboard.LEFT)&& !_ducking) {
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x -50, y:this.y -55, angle:209, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_ce.input.isDown(Keyboard.UP) && !_ducking	) {
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x +10, y:this.y -100, angle:270, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_ce.input.isDown(Keyboard.DOWN) && !_onGround) {
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x, y:this.y +80, angle:90, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_inverted && _ducking){
						_bulletN = new Missile("Missile", { height: 10, width: 10, x: this.x - 50, y:this.y, angle:180, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_inverted){
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x - 50, y:this.y -31, angle:180, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else if (_ducking){
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x + 50, y:this.y, angle:0, registration: "TopLeft", view:"art/missile_a.swf"} );
					}else {
						_bulletN = new LylliaBullet("Missile", { height: 10, width: 10, x: this.x + 50, y:this.y -31, angle:0, registration: "TopLeft", view:"art/missile_a.swf"} );
					}
					CitrusEngine.getInstance().state.add(_bulletN);
					shootDelay();
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.SetLinearVelocity(velocity);
			}
			
			updateAnimation();
		}
		
		override protected function updateAnimation():void
		{
			var input_z:int = 90;
			var input_x:int = 88;
			var prevAnimation:String = _animation;
			
			var velocity:V2 = _body.GetLinearVelocity();
			if (_hurt)
			{
				_animation = "hurt";
			}
			else if (_climbing) {
				
				_animation = _climbAnimation;
			}
			else if ((_ce.input.isDown(input_x)) && (_ce.input.isDown(Keyboard.UP)) && !_onGround && (_ce.input.isDown(Keyboard.RIGHT)))
			{
				_animation = "jumpdiag"
			}	
			else if ((_ce.input.isDown(input_x)) && (_ce.input.isDown(Keyboard.UP)) && !_onGround && (_ce.input.isDown(Keyboard.LEFT)))
			{
				_animation = "jumpdiag"
			}
			else if ((_ce.input.isDown(input_x)) && (_ce.input.isDown(Keyboard.UP)) && !_onGround)
			{
				_animation = "jumpupatk"
			}	
			else if ((_ce.input.isDown(input_x)) && (_ce.input.isDown(Keyboard.DOWN)) && !_onGround)
			{
				_animation = "jumpatk"
			}	
			else if ((_ce.input.isDown(input_x)) && !_onGround)
			{
				_animation = "jumpfrontatk"
			}	
			else if ((_ce.input.isDown(input_x)) && _ducking)
			{
				_animation = "downatk"
			}	
			else if (!_onGround)
			{
				_animation = "jump";
			}
			else if (_ducking)
			{
				_animation = "duck";
			}
			else if (_ce.input.isDown(input_x))
			{
				if (_ce.input.isDown(Keyboard.RIGHT) &&  _ce.input.isDown(Keyboard.UP))
				{
					_animation = "rundiag"
					_inverted = false;
				}	
				else if (_ce.input.isDown(Keyboard.LEFT) && _ce.input.isDown(Keyboard.UP))
				{
					_animation = "rundiag"
					_inverted = true;
				}	
				else if (_ce.input.isDown(Keyboard.UP))
				{
					_animation = "upatk";
				}
				else if (_ce.input.isDown(Keyboard.RIGHT))
				{
					_animation = "runatk"
					_inverted = false;
				}	
				else if (_ce.input.isDown(Keyboard.LEFT))
				{
					_animation = "runatk"
					_inverted = true;
				}	
				else
				{
					_animation = "atk";
				}
			}
			else
			{
				var walkingSpeed:Number = getWalkingSpeed();
				if (walkingSpeed < -acceleration)
				{
					_inverted = true;
					_animation = "walk";
				}
				else if (walkingSpeed > acceleration)
				{
					_inverted = false;
					_animation = "walk";
				}
				else
				{
					_animation = "idle";
				}
			}
			
			if (prevAnimation != _animation)
			{
				onAnimationChange.dispatch();
			}
		}
		
		override public function destroy():void
		{
			clearTimeout(_shootDelayTimeoutID);
			onShoot.removeAll();
			super.destroy();
		}	
		
		public function shootDelay():void
		{
			_shootDelay = true;
			_shootDelayTimeoutID = setTimeout (endDelayState, delayDuration);
			onShoot.dispatch();
		}
		
		protected function endDelayState():void
		{
			_shootDelay = false;
		}

		override protected function updateCombinedGroundAngle():void
		{
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _groundContacts)
				_combinedGroundAngle += contact.GetBody().GetAngle();
			_combinedGroundAngle /= _groundContacts.length;
		}

		override protected function handleBeginContact(e:ContactEvent):void
		{
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
			var colliderBody:b2Body = e.other.GetBody();
			
			if (_enemyClass && collider is _enemyClass)
			{
				if (!_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:V2 = _body.GetLinearVelocity();
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.SetLinearVelocity(hurtVelocity);
				}
			}
			
			if (colliderBody.GetUserData() is Sensor && colliderBody.GetUserData().isLadder) {
				canClimb = true;
				canDuck = false;
				ladder = colliderBody.GetUserData();
			}

			//Collision angle
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135)
				{
					_groundContacts.push(e.other);
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		override protected function handleEndContact(e:ContactEvent):void
		{
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
			if (e.other.GetBody().GetUserData() is Sensor && e.other.GetBody().GetUserData().isLadder) {
				_climbing = canClimb = false;
				canDuck = true;
				gravity = originalGravity;
			}

		}
		
		override protected function handlePreSolve(e:ContactEvent):void 
		{
			if (e.other.GetBody().GetUserData() is Platform && canClimb && (_climbing || !_onGround)) {
				if ((y + height / 2) < (ladder.y + ladder.height / 2)) {
					e.contact.Disable();
				}
			}
			
			if (!_ducking)
				return;
			
			var other:PhysicsObject = e.other.GetBody().GetUserData() as PhysicsObject;
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				e.contact.Disable();
		}
		
		
		
	}
}