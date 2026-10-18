package juho.hacking {

   /**
    * Настройки Box Fall Speed: ускорение падения ящиков-припасов.
    * Скорость падения, приходящая от сервера при спавне ящика,
    * умножается на заданный множитель - ящик долетает до земли
    * в N раз быстрее (включая золотые).
    *
    * @author juhe
    */
   public class BoxFallHackConfig {

      public static var enabled:Boolean = false;

      // Во сколько раз быстрее падают ящики (2 = вдвое быстрее; 1 = штатно)
      public static var multiplier:Number = 2;

      public static function adjustFallSpeed(speed:Number):Number {
         if (!enabled || !(multiplier > 0) || multiplier == 1) {
            return speed;
         }
         return speed * multiplier;
      }
   }
}
