package juho.hacking {

   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.battle.objects.tank.ClientTankState;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.models.tank.ITankModel;
   import alternativa.tanks.models.weapons.targeting.direction.sector.CheatTargetingSectorsCalculator;
   import flash.utils.Dictionary;
   import platform.client.fp10.core.type.IGameObject;

   /**
    * Hitbox: увеличение хитбокса вражеских танков в N раз.
    *
    * Действует в двух местах:
    * 1) Угловые допуски секторов наведения (Cheat/TargetingSectorsCalculator)
    *    и триггербота - цель считается "толще", её проще захватить.
    * 2) "Толстый луч" при рейкасте выстрела (Single/PenetratingDirectionProcessor):
    *    если луч проходит рядом с врагом в пределах увеличенного радиуса,
    *    генерируется синтетический RayHit - клиент объявляет серверу попадание
    *    (onShotTarget / цели рельсы), как будто снаряд реально попал.
    *
    * Мёртвые танки и тиммейты в синтетические попадания не попадают.
    *
    * @author juhe
    */
   public class HitboxHackConfig {

      // Включён ли чит (чекбокс в меню)
      public static var enabled:Boolean = false;

      // Во сколько раз больше хитбокс врагов (1 = штатно, 2 = вдвое толще)
      public static var multiplier:Number = 2;

      public static function active():Boolean {
         return enabled && multiplier > 1;
      }

      // Радиус цели с учётом чита (для угловых допусков в секторах/триггере)
      public static function scaledRadius(target:Tank):Number {
         if (target == null) {
            return 0;
         }
         var r:Number = target.getBoundSphereRadius();
         return active() ? r * multiplier : r;
      }

      // Живой вражеский танк - подходящая цель
      public static function isValidTarget(selfTank:Tank, target:Tank):Boolean {
         return target != null && target != selfTank && target.health > 0
            && target.state != ClientTankState.DEAD
            && (selfTank == null || !selfTank.isSameTeam(target.teamType));
      }

      /**
       * "Толстый луч": ищет вражеские танки, чей увеличенный хитбокс
       * пересекает сегмент луча origin + dir*t (0 <= t <= maxDist).
       * Для каждого такого танка создаётся синтетический RayHit в ближайшей
       * к лучу точке - выстрел засчитается как попадание, хотя рейкаст
       * реального коллайдера промахнулся бы. Стена ближе танка (maxDist)
       * попадание отменяет. exclude[body]=true - тело пропускается.
       * Результат отсортирован по возрастанию t (ближайший первым).
       */
      public static function findFatRayHits(origin:Vector3, dir:Vector3, maxDist:Number, selfTank:Tank, exclude:Dictionary):Vector.<RayHit> {
         var result:Vector.<RayHit> = new Vector.<RayHit>();
         if (!active() || CheatTargetingSectorsCalculator.tankUsersRegistry == null) {
            return result;
         }
         var to:Vector3 = new Vector3();
         for each (var obj:IGameObject in CheatTargetingSectorsCalculator.tankUsersRegistry.getUsers()) {
            var target:Tank = ITankModel(obj.adapt(ITankModel)).getTank();
            if (!isValidTarget(selfTank, target)) {
               continue;
            }
            var body:Body = target.getBody();
            if (body == null || body.collisionShapes == null || body.collisionShapes.length == 0) {
               continue;
            }
            if (exclude != null && exclude[body]) {
               continue;
            }
            to.diff(body.state.position,origin);
            var t:Number = to.dot(dir);
            if (t < 0 || t > maxDist) {
               continue;
            }
            // квадрат расстояния от центра танка до луча
            var perpSqr:Number = to.lengthSqr() - t * t;
            var r:Number = scaledRadius(target);
            if (perpSqr > r * r) {
               continue;
            }
            var hit:RayHit = new RayHit();
            hit.shape = body.collisionShapes[0];
            hit.t = t;
            hit.position.copy(origin).addScaled(t,dir);
            hit.normal.copy(dir).reverse();
            hit.staticHit = false;
            result.push(hit);
         }
         if (result.length > 1) {
            result = result.sort(sortByHitDistance);
         }
         return result;
      }

      private static function sortByHitDistance(a:RayHit, b:RayHit):Number {
         return a.t < b.t ? -1 : (a.t > b.t ? 1 : 0);
      }
   }
}
