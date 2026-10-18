package alternativa.tanks.bonuses
{
   import alternativa.math.Matrix3;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.collision.CollisionShape;
   import alternativa.physics.collision.primitives.CollisionBox;
   import alternativa.tanks.battle.BattleRunnerProvider;
   import alternativa.tanks.battle.Trigger;
   import alternativa.tanks.physics.CollisionGroup;
   import juho.hacking.BoxHitboxHackConfig;

   public class BonusTrigger extends BattleRunnerProvider implements Trigger
   {

      private var bonus:BattleBonus;

      private var collisionBox:CollisionBox;

      public function BonusTrigger(param1:BattleBonus)
      {
         super();
         this.bonus = param1;
         // juhe: Box Hitbox cheat - хитбокс подбора ящика с чит-множителем
         var _loc2_:Number = BoxHitboxHackConfig.halfSize();
         this.collisionBox = new CollisionBox(new Vector3(_loc2_,_loc2_,_loc2_),CollisionGroup.BONUS_WITH_TANK,PhysicsMaterial.DEFAULT_MATERIAL);
      }
      
      public function enable() : void
      {
         getBattleRunner().addTrigger(this);
      }
      
      public function disable() : void
      {
         getBattleRunner().removeTrigger(this);
      }
      
      public function update(param1:Matrix4) : void
      {
         var _loc2_:Matrix4 = this.collisionBox.transform;
         _loc2_.copy(param1);
         this.collisionBox.calculateAABB();
      }
      
      public function updateByComponents(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Number) : void
      {
         var _loc7_:Matrix4 = this.collisionBox.transform;
         _loc7_.setMatrix(param1,param2,param3,param4,param5,param6);
         this.collisionBox.calculateAABB();
      }
      
      public function setTransform(param1:Vector3, param2:Matrix3) : void
      {
         var _loc3_:Matrix4 = this.collisionBox.transform;
         _loc3_.setFromMatrix3(param2,param1);
         this.collisionBox.calculateAABB();
      }
      
      public function checkTrigger(param1:Body) : void
      {
         // juhe: Box Hitbox cheat - настройка из меню может меняться на ходу
         this.applyHalfSize();
         var _loc3_:CollisionShape = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.numCollisionShapes)
         {
            _loc3_ = param1.collisionShapes[_loc2_];
            if(getBattleRunner().getCollisionDetector().testCollision(_loc3_,this.collisionBox))
            {
               this.bonus.onTriggerActivated();
               return;
            }
            _loc2_++;
         }
      }

      private function applyHalfSize() : void
      {
         var _loc1_:Number = BoxHitboxHackConfig.halfSize();
         if(this.collisionBox.hs.x != _loc1_)
         {
            this.collisionBox.hs.reset(_loc1_,_loc1_,_loc1_);
            this.collisionBox.calculateAABB();
         }
      }
   }
}

