package juho.hacking {

   import alternativa.tanks.bonuses.BonusConst;

   /**
    * Box Hitbox ("магнит ящиков"): увеличение хитбокса подбора
    * ящиков-припасов (включая золотые) в N раз.
    *
    * Подбор в клиенте происходит так: физический движок каждый тик
    * проверяет пересечение корпуса танка с CollisionBox ящика
    * (BonusTrigger, половинный размер = 75). При пересечении клиент
    * шлёт серверу attemptToTakeBonus. Мы просто делаем этот бокс
    * больше - клиент объявляет подбор раньше, чем танк реально
    * касается ящика.
    *
    * @author juhe
    */
   public class BoxHitboxHackConfig {

      // Включён ли чит (чекбокс в меню)
      public static var enabled:Boolean = false;

      // Во сколько раз больше хитбокс ящика (1 = штатно, 2 = вдвое)
      public static var multiplier:Number = 2;

      // Половинный размер хитбокса ящика с учётом чита
      public static function halfSize():Number {
         if (!enabled || !(multiplier > 1)) {
            return BonusConst.BONUS_HALF_SIZE;
         }
         return BonusConst.BONUS_HALF_SIZE * multiplier;
      }
   }
}
