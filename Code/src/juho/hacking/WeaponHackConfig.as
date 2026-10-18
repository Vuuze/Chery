package juho.hacking {

   import flash.utils.Dictionary;
   import projects.tanks.client.battlefield.models.tankparts.weapon.twins.TwinsCC;
   import projects.tanks.client.battlefield.models.tankparts.weapon.flamethrower.FlameThrowerCC;
   import projects.tanks.client.battlefield.models.tankparts.weapon.freeze.FreezeCC;

   /**
    * Настройки оружейного чита (WeaponHack).
    *
    * Значения меняются в чит-меню, а применяются патчами в objectLoaded()
    * моделей TwinsModel / FlamethrowerModel / FreezeModel.
    *
    * Здесь же хранятся базовые (серверные) значения живых CC-объектов,
    * чтобы чит можно было выключить и вернуть всё как было.
    *
    * @author juhe
    */
   public class WeaponHackConfig {

      // Включён ли чит (управляется из меню)
      public static var enabled:Boolean = false;

      // Угол конуса огнемёта в ГРАДУСАХ (-1 или меньше = серверное значение)
      public static var flameConeAngleDeg:Number = 180;

      // Угол конуса фриза в ГРАДУСАХ (-1 или меньше = серверное значение)
      public static var freezeConeAngleDeg:Number = 180;

      // Множитель скорости полёта снаряда твинса (1 = серверное значение)
      public static var twinsSpeedMultiplier:Number = 3;

      // Базовые (серверные) значения, ключ - живой CC-объект.
      // Слабые ключи, чтобы объекты могли собраться GC после выхода из боя.
      private static const twinsBaseSpeed:Dictionary = new Dictionary(true);
      private static const flameBaseConeAngle:Dictionary = new Dictionary(true);
      private static const freezeBaseConeAngle:Dictionary = new Dictionary(true);

      /**
       * Вызывается из TwinsModel.objectLoaded() после toClientScale(),
       * а также из reapplyAll(). Меняет скорость снаряда.
       */
      public static function applyTwinsCC(cc:TwinsCC):void {
         if (twinsBaseSpeed[cc] === undefined) {
            twinsBaseSpeed[cc] = cc.speed;
         }

         var mult:Number = twinsSpeedMultiplier;
         // NaN / 0 / отрицательные значения или выключенный чит = вернуть базу
         if (!enabled || !(mult > 0)) {
            mult = 1;
         }

         cc.speed = Number(twinsBaseSpeed[cc]) * mult;
      }

      /**
       * Вызывается из FlamethrowerModel.objectLoaded() до создания ConicAreaData.
       * Угол внутри игры в радианах, в меню задаётся в градусах.
       */
      public static function applyFlameThrowerCC(cc:FlameThrowerCC):void {
         if (flameBaseConeAngle[cc] === undefined) {
            flameBaseConeAngle[cc] = cc.coneAngle;
         }

         if (enabled && flameConeAngleDeg >= 0) {
            cc.coneAngle = flameConeAngleDeg * Math.PI / 180;
         } else {
            cc.coneAngle = Number(flameBaseConeAngle[cc]);
         }
      }

      /**
       * Вызывается из FreezeModel.objectLoaded() до создания ConicAreaData.
       */
      public static function applyFreezeCC(cc:FreezeCC):void {
         if (freezeBaseConeAngle[cc] === undefined) {
            freezeBaseConeAngle[cc] = cc.damageAreaConeAngle;
         }

         if (enabled && freezeConeAngleDeg >= 0) {
            cc.damageAreaConeAngle = freezeConeAngleDeg * Math.PI / 180;
         } else {
            cc.damageAreaConeAngle = Number(freezeBaseConeAngle[cc]);
         }
      }

      /**
       * Пересчитывает значения всех живых CC-объектов.
       * Вызывается из WeaponHack при изменении настроек в меню
       * и при включении/выключении чита.
       */
      public static function reapplyAll():void {
         var obj:Object;
         for (obj in twinsBaseSpeed) {
            applyTwinsCC(TwinsCC(obj));
         }
         for (obj in flameBaseConeAngle) {
            applyFlameThrowerCC(FlameThrowerCC(obj));
         }
         for (obj in freezeBaseConeAngle) {
            applyFreezeCC(FreezeCC(obj));
         }
      }
   }
}
