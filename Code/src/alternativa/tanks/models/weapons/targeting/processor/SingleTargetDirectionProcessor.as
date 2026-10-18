package alternativa.tanks.models.weapons.targeting.processor
{
   import alternativa.math.Vector3;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.battle.BattleService;
   import alternativa.tanks.battle.BattleUtils;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.models.tank.ITankModel;
   import alternativa.tanks.models.weapon.AllGlobalGunParams;
   import alternativa.tanks.models.weapon.RayCollisionFilter;
   import juho.hacking.HitboxHackConfig;
   import platform.client.fp10.core.type.IGameObject;

   public class SingleTargetDirectionProcessor extends CommonDirectionProcessor implements TargetingDirectionProcessor
   {

      [Inject] // added
      public static var battleService:BattleService;

      private var collisionFilter:RayCollisionFilter = new RayCollisionFilter();

      private var rayHitResult:RayHit = new RayHit();

      private var rayHits:Vector.<RayHit> = new Vector.<RayHit>();

      private var self:IGameObject;

      private var maxDist:Number;

      public function SingleTargetDirectionProcessor(param1:IGameObject, param2:Number)
      {
         super(param2,this.collisionFilter);
         this.self = param1;
         this.maxDist = param2;
      }

      public function process(param1:AllGlobalGunParams, param2:Vector3) : Vector.<RayHit>
      {
         var _loc1_:Tank = this.getTank(this.self);
         this.collisionFilter.exclusion = _loc1_.getBody();
         this.rayHitResult.clear();
         this.rayHits.length = 0;
         if(raycast(param1,param2,this.rayHitResult))
         {
            this.rayHits.push(this.rayHitResult.clone());
         }
         // juhe: Hitbox cheat - "толстый луч": промах мимо увеличенного хитбокса
         // засчитывается как попадание (клиент объявляет хит серверу)
         if(HitboxHackConfig.active())
         {
            var _loc2_:Number = this.maxDist;
            if(this.rayHits.length > 0)
            {
               _loc2_ = this.rayHits[0].t; // дальше первого препятствия не стреляем
            }
            var _loc3_:Vector.<RayHit> = HitboxHackConfig.findFatRayHits(this.getRayOrigin(param1,param2),param2,_loc2_,_loc1_,null);
            if(_loc3_.length > 0)
            {
               var _loc4_:Vector.<RayHit> = this.rayHits.concat();
               this.rayHits.length = 0;
               for each(var _loc5_:RayHit in _loc3_)
               {
                  this.rayHits.push(_loc5_);
               }
               for each(var _loc6_:RayHit in _loc4_)
               {
                  this.rayHits.push(_loc6_);
               }
            }
         }
         return this.rayHits;
      }
      
      private function getTank(param1:IGameObject) : Tank
      {
         var _loc2_:ITankModel = ITankModel(param1.adapt(ITankModel));
         return _loc2_.getTank();
      }
   }
}

