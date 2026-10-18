package alternativa.tanks.models.weapon.shared
{
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.physics.CollisionGroup;
   import alternativa.tanks.physics.TanksCollisionDetector;
   import alternativa.tanks.models.tank.ITankModel;
   import alternativa.tanks.utils.EncryptedNumber;
   import alternativa.tanks.utils.EncryptedNumberImpl;
   import alternativa.tanks.battle.objects.tank.ClientTankState;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.models.weapons.targeting.direction.sector.CheatTargetingSectorsCalculator;
   import flash.utils.Dictionary;
   import platform.client.fp10.core.type.IGameObject;
   
   public class ConicAreaTargetingSystem
   {
      
      private static const COLLISION_GROUP:int = CollisionGroup.WEAPON;
      
      private static const origin:Vector3 = new Vector3();
      
      private var range:EncryptedNumber;
      
      private var halfConeAngle:EncryptedNumber;
      
      private var numRays:int;
      
      private var numSteps:int;
      
      private var collisionDetector:TanksCollisionDetector;
      
      private var targetValidator:ConicAreaTargetValidator;
      
      private const _xAxis:Vector3 = new Vector3();
      
      private const matrix:Matrix3 = new Matrix3();
      
      private const rotationMatrix:Matrix3 = new Matrix3();
      
      private const rayHit:RayHit = new RayHit();
      
      private const collisionFilter:ConicTargetingCollisionFilter = new ConicTargetingCollisionFilter();
      
      private const rayDirection:Vector3 = new Vector3();
      
      private const muzzlePosition:Vector3 = new Vector3();
      
      private var distanceByTarget:Dictionary;
      
      private var hitPointByTarget:Dictionary;
      
      public function ConicAreaTargetingSystem(param1:Number, param2:Number, param3:int, param4:int, param5:TanksCollisionDetector, param6:ConicAreaTargetValidator)
      {
         super();
         this.range = new EncryptedNumberImpl(param1);
         this.halfConeAngle = new EncryptedNumberImpl(0.5 * param2);
         this.numRays = param3;
         this.numSteps = param4;
         this.collisionDetector = param5;
         this.targetValidator = param6;
      }
      
      public function getTargets(param1:Body, param2:Number, param3:Number, param4:Vector3, param5:Vector3, param6:Vector3, param7:Vector.<Body>, param8:Vector.<Number>, param9:Vector.<Vector3>) : void
      {
         var _loc16_:* = undefined;
         var _loc17_:Number = NaN;
         this.collisionFilter.shooter = param1;
         this.distanceByTarget = new Dictionary();
         this.hitPointByTarget = new Dictionary();
         var _loc10_:Number = param3 * param2;
         var _loc11_:Number = param2 - _loc10_;
         if(this.collisionDetector.raycast(param4,param5,COLLISION_GROUP,param2,this.collisionFilter,this.rayHit) && this.rayHit.shape.body.tank == null)
         {
            return;
         }
         this._xAxis.copy(param6);
         this.muzzlePosition.copy(param4).addScaled(_loc10_,param5);
         var _loc12_:Number = this.range.getNumber() + _loc11_;
         this.processRay(this.muzzlePosition,param5,_loc12_);
         this.rotationMatrix.fromAxisAngle(param5,Math.PI / this.numSteps);
         var _loc13_:Number = this.halfConeAngle.getNumber() / this.numRays;
         var _loc14_:int = 0;
         while(_loc14_ < this.numSteps)
         {
            this.processSector(this.muzzlePosition,param5,this._xAxis,_loc12_,this.numRays,_loc13_);
            this.processSector(this.muzzlePosition,param5,this._xAxis,_loc12_,this.numRays,-_loc13_);
            this._xAxis.transform3(this.rotationMatrix);
            _loc14_++;
         }
         // juhe: угол из меню 270+ градусов - режим "по окружности": добираем
         // цели радиально (включая вперёд и сзади), стены блокируют, союзники
         // и трупы не задеваются
         if(this.halfConeAngle.getNumber() * 2 >= 4.6)
         {
            this.addRadialTargets(param1,param4,_loc11_);
         }
         var _loc15_:int = 0;
         for(_loc16_ in this.distanceByTarget)
         {
            param7[_loc15_] = _loc16_;
            _loc17_ = this.distanceByTarget[_loc16_] - _loc11_;
            if(_loc17_ < 0)
            {
               _loc17_ = 0;
            }
            param8[_loc15_] = _loc17_;
            param9[_loc15_] = this.hitPointByTarget[_loc16_];
            _loc15_++;
         }
         param7.length = _loc15_;
         param8.length = _loc15_;
         this.collisionFilter.shooter = null;
         this.collisionFilter.clearInvalidTargets();
         this.distanceByTarget = null;
      }
      
      // juhe: радиальный добор целей в сфере вокруг дула (режим "по окружности")
      private function addRadialTargets(param1:Body, param4:Vector3, param11:Number) : void
      {
         var registry:* = CheatTargetingSectorsCalculator.tankUsersRegistry;
         if(registry == null)
         {
            return;
         }
         var shooterTank:Tank = param1.tank;
         var maxDist:Number = this.range.getNumber() + param11;
         for each(var obj:IGameObject in registry.getUsers())
         {
            if(obj == null)
            {
               continue;
            }
            var tank:Tank = ITankModel(obj.adapt(ITankModel)).getTank();
            if(tank == null || tank == shooterTank)
            {
               continue;
            }
            if(tank.health <= 0 || tank.state == ClientTankState.DEAD)
            {
               continue; // трупы не едим
            }
            if(shooterTank != null && tank.isSameTeam(shooterTank.teamType))
            {
               continue; // свои не едим
            }
            var body:Body = tank.getBody();
            if(body == null || this.distanceByTarget[body] != null)
            {
               continue; // уже зафиксирован штатными лучами
            }
            var to:Vector3 = new Vector3();
            to.diff(body.state.position,param4);
            var dist:Number = to.length();
            if(dist > maxDist || dist < 1)
            {
               continue;
            }
            to.normalize();
            // один луч до цели - если попали именно в неё, стен нет
            if(this.collisionDetector.raycast(param4,to,COLLISION_GROUP,dist,this.collisionFilter,this.rayHit) && this.rayHit.shape.body == body)
            {
               if(this.targetValidator.isValidTarget(body))
               {
                  this.collisionFilter.addTarget(body);
                  this.distanceByTarget[body] = this.rayHit.t;
                  this.hitPointByTarget[body] = this.rayHit.position.clone();
               }
            }
         }
      }

      private function processSector(param1:Vector3, param2:Vector3, param3:Vector3, param4:Number, param5:int, param6:Number) : void
      {
         var _loc7_:Number = 0;
         var _loc8_:int = 0;
         while(_loc8_ < param5)
         {
            _loc7_ += param6;
            this.matrix.fromAxisAngle(param3,_loc7_);
            this.matrix.transformVector(param2,this.rayDirection);
            this.processRay(param1,this.rayDirection,param4);
            _loc8_++;
         }
      }
      
      private function processRay(param1:Vector3, param2:Vector3, param3:Number) : void
      {
         var _loc5_:Body = null;
         var _loc6_:Number = NaN;
         origin.copy(param1);
         var _loc4_:Number = 0;
         if(this.collisionDetector.raycast(origin,param2,COLLISION_GROUP,param3,this.collisionFilter,this.rayHit))
         {
            _loc5_ = this.rayHit.shape.body;
            if(_loc5_.tank != null && !MarginalCollider.segmentWithStaticIntersection(origin,this.rayHit.position))
            {
               origin.addScaled(this.rayHit.t,param2);
               _loc4_ += this.rayHit.t;
               if(this.targetValidator.isValidTarget(_loc5_))
               {
                  this.collisionFilter.addTarget(_loc5_);
                  _loc6_ = Number(this.distanceByTarget[_loc5_]);
                  if(isNaN(_loc6_) || _loc6_ > _loc4_)
                  {
                     this.distanceByTarget[_loc5_] = _loc4_;
                     this.hitPointByTarget[_loc5_] = this.rayHit.position.clone();
                  }
               }
               else
               {
                  this.collisionFilter.addInvalidTarget(_loc5_);
               }
            }
         }
         this.collisionFilter.clearTargets();
      }
   }
}

