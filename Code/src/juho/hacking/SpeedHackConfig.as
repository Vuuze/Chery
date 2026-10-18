package juho.hacking {

   /**
    * Настройки авто-режима SpeedHack:
    * клиент сам узнаёт "легальные" (серверные) характеристики твоего
    * корпуса/башни и лепит к ним +N% вместо ручных абсолютных чисел.
    *
    * Базовые значения перехватываются в SpeedCharacteristicsModel
    * (они приходят с сервера при спавне и при смене МУ).
    *
    * @author juhe
    */
   public class SpeedHackConfig {

      // Режим "+N% от штатной скорости корпуса"
      public static var autoEnabled:Boolean = false;

      // Процент бонуса (30 = на 30% быстрее)
      public static var bonusPercent:Number = 30;

      // Базовые (серверные) значения в клиентском масштабе. -1 = неизвестно
      public static var baseSpeed:Number = -1;
      public static var baseAcceleration:Number = -1;
      public static var baseTurnSpeed:Number = -1;
      public static var baseTurnAcceleration:Number = -1;
      public static var baseTurretTurnSpeed:Number = -1;

      public static function hasBase():Boolean {
         return baseSpeed > 0;
      }

      // Множитель: 30% -> 1.3, -50% -> 0.5
      public static function factor():Number {
         if (bonusPercent <= -99) {
            return 0.01;
         }
         return 1 + bonusPercent / 100;
      }
   }
}
