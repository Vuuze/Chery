package alternativa.tanks.models.weapons.targeting.processor
{
   import alternativa.math.Vector3;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.battle.BattleService;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.models.tank.ITankModel;
   import alternativa.tanks.models.weapon.AllGlobalGunParams;
   import alternativa.tanks.models.weapon.railgun.MultibodyCollisionFilter;
   import alternativa.tanks.physics.TanksCollisionDetector;
   import flash.utils.Dictionary;
   import juho.hacking.HitboxHackConfig;
   import platform.client.fp10.core.type.IGameObject;
   
   public class DirectionProcessorForPenetratingWeapons extends CommonDirectionProcessor implements TargetingDirectionProcessor
   {
      
      [Inject] // added
      public static var battleService:BattleService;
      
      private var self:IGameObject;
      
      private var maxDistance:Number;
      
      private var collisionDetector:TanksCollisionDetector;
      
      private var multibodyFilter:MultibodyCollisionFilter = new MultibodyCollisionFilter();
      
      private var rayHitResult:RayHit = new RayHit();
      
      private var hits:Vector.<RayHit> = new Vector.<RayHit>();
      
      public function DirectionProcessorForPenetratingWeapons(param1:IGameObject, param2:Number)
      {
         super(param2,this.multibodyFilter);
         this.self = param1;
         this.maxDistance = param2;
         this.collisionDetector = battleService.getBattleRunner().getCollisionDetector();
      }
      
      public function process(param1:AllGlobalGunParams, param2:Vector3) : Vector.<RayHit>
      {
         var _loc1_:Tank = this.getTank(this.self);
         this.multibodyFilter.addBody(_loc1_.getBody());
         this.hits.length = 0;
         while(raycast(param1,param2,this.rayHitResult))
         {
            this.hits.push(this.rayHitResult.clone());
            if(this.rayHitResult.staticHit)
            {
               break;
            }
            this.multibodyFilter.addBody(this.rayHitResult.shape.body);
         }
         this.multibodyFilter.clear();
         // juhe: Hitbox cheat - "толстый луч": рельса пьёт всех врагов,
         // чей увеличенный хитбокс пересекает луч (кроме уже попавших)
         if(HitboxHackConfig.active())
         {
            var _loc2_:Number = this.maxDistance;
            var _loc3_:Dictionary = new Dictionary();
            _loc3_[_loc1_.getBody()] = true;
            for each(var _loc4_:RayHit in this.hits)
            {
               if(_loc4_.staticHit)
               {
                  _loc2_ = _loc4_.t; // за стеной никого не добавляем
               }
               else if(_loc4_.shape != null && _loc4_.shape.body != null)
               {
                  _loc3_[_loc4_.shape.body] = true;
               }
            }
            var _loc5_:Vector.<RayHit> = HitboxHackConfig.findFatRayHits(this.getRayOrigin(param1,param2),param2,_loc2_,_loc1_,_loc3_);
            if(_loc5_.length > 0)
            {
               var _loc6_:Vector.<RayHit> = new Vector.<RayHit>(); // хиты по танкам
               var _loc7_:Vector.<RayHit> = new Vector.<RayHit>(); // статика
               for each(_loc4_ in this.hits)
               {
                  if(_loc4_.staticHit)
                  {
                     _loc7_.push(_loc4_);
                  }
                  else
                  {
                     _loc6_.push(_loc4_);
                  }
               }
               for each(var _loc8_:RayHit in _loc5_)
               {
                  _loc6_.push(_loc8_);
               }
               if(_loc6_.length > 1)
               {
                  _loc6_ = _loc6_.sort(this.sortByHitDistance);
               }
               this.hits.length = 0;
               for each(_loc4_ in _loc6_)
               {
                  this.hits.push(_loc4_);
               }
               for each(_loc4_ in _loc7_)
               {
                  this.hits.push(_loc4_);
               }
            }
         }
         return this.hits;
      }

      private function sortByHitDistance(param1:RayHit, param2:RayHit) : Number
      {
         return param1.t < param2.t ? -1 : (param1.t > param2.t ? 1 : 0);
      }
      
      private function getTank(param1:IGameObject) : Tank
      {
         var _loc2_:ITankModel = ITankModel(param1.adapt(ITankModel));
         return _loc2_.getTank();
      }
   }
}

