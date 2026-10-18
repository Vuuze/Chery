package juho.hacking {

   import alternativa.math.Vector3;
   import alternativa.tanks.battle.objects.tank.ClientTankState;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.models.weapon.AllGlobalGunParams;
   import alternativa.tanks.models.weapons.targeting.direction.sector.CheatTargetingSectorsCalculator;

   /**
    * Настройки триггербота.
    *
    * Триггербот автоматически стреляет, когда на линии прицела
    * (как её видит родная система наведения, т.е. с учётом Aim cheat,
    * если он включён) появляется вражеский танк.
    *
    * Применяется патчами в SmokyWeapon/ThunderWeapon runLogic().
    *
    * @author juhe
    */
   public class TriggerBotConfig {

      // Включён ли чит (чекбокс в меню)
      public static var enabled:Boolean = false;

      // Отдельные переключатели по пушкам
      public static var smokyEnabledProp:Boolean = true;
      public static var thunderEnabledProp:Boolean = true;

      // Штатный вертикальный автоприцел (если в Aim cheat свои углы не заданы), рад
      private static const DEFAULT_VERTICAL_LIMIT:Number = 0.18;

      public static function smokyEnabled():Boolean {
         return enabled && smokyEnabledProp;
      }

      public static function thunderEnabled():Boolean {
         return enabled && thunderEnabledProp;
      }

      // Трупы - не цель: мёртвый танк ещё имеет тело и ловил бы выстрел
      public static function isValidTarget(tank:Tank):Boolean {
         return tank != null && tank.health > 0 && tank.state != ClientTankState.DEAD;
      }

      /**
       * Вписывается ли цель в сектора, настроенные в Aim cheat.
       * Та же математика, что в CheatTargetingSectorsCalculator: если цель
       * вне углов (в т.ч. вертикальных) - триггер молчит. Раньше этой
       * проверки не было и триггер стрелял шире, чем настроено в аиме.
       */
      public static function withinAimSectors(gunParams:AllGlobalGunParams, target:Tank):Boolean {
         var to:Vector3 = new Vector3();
         to.diff(target.getBody().state.position, gunParams.barrelOrigin);
         var dist:Number = to.length();
         if (dist < 1) {
            return true;
         }
         var gunRight:Vector3 = gunParams.elevationAxis.clone();
         var gunForward:Vector3 = gunParams.direction.clone();
         var gunUp:Vector3 = gunRight.clone().cross(gunForward).normalize();

         var pitch:Number = Math.atan2(to.dot(gunUp), to.dot(gunForward));
         var yaw:Number = Math.atan2(-to.dot(gunRight), to.dot(gunForward));

         var effR:Number = Math.min(HitboxHackConfig.scaledRadius(target), dist);
         var tol:Number = Math.asin(effR / dist);

         // горизонталь
         var left:Number = CheatTargetingSectorsCalculator.maxAngleLeft;
         var right:Number = CheatTargetingSectorsCalculator.maxAngleRight;
         if (left == 0 && right == 0) {
            if (yaw > tol || yaw < -tol) {
               return false;
            }
         } else if (yaw > right + tol || yaw < -(left + tol)) {
            return false;
         }

         // вертикаль
         var upLim:Number = CheatTargetingSectorsCalculator.maxAngleUpOverride;
         var downLim:Number = CheatTargetingSectorsCalculator.maxAngleDownOverride;
         if (upLim == 0 && downLim == 0) {
            upLim = DEFAULT_VERTICAL_LIMIT;
            downLim = DEFAULT_VERTICAL_LIMIT;
         }
         if (pitch > upLim + tol || pitch < -(downLim + tol)) {
            return false;
         }
         return true;
      }
   }
}
