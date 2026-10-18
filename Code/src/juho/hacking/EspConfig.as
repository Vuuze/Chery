package juho.hacking {

   import flash.utils.Dictionary;

   /**
    * Настройки и реестр объектов для ESP чита
    * (подсветка ящиков-припасов и мин сквозь стены).
    *
    * BattleBonus/ProximityMine регистрируют себя здесь при появлении
    * и убираются при исчезновении. Рендер читает позиции напрямую.
    *
    * @author juhe
    */
   public class EspConfig {

      // Включён ли чит (чекбокс в меню)
      public static var enabled:Boolean = false;

      // Категории
      public static var boxesEnabled:Boolean = true;
      public static var minesEnabled:Boolean = true;
      public static var showDistance:Boolean = true;

      // juhe: голд-подсветка (ящик + зона выпадения)
      public static var goldZonesEnabled:Boolean = true;   // маркер точки падения голда
      public static var goldColor:uint = 0xFF8800;         // цвет маркера голд-ящика
      public static var goldOpacity:Number = 100;          // прозрачность голд-ящика, %
      public static var goldZoneColor:uint = 0xFF00FF;     // цвет маркера зоны падения
      public static var goldZoneOpacity:Number = 70;       // прозрачность зоны падения, %

      // juhe: активные зоны падения голда (ключ - объект {x,y,z}) - пока сервер показывает зону
      public static const goldZones:Dictionary = new Dictionary(true);
      public static var nextGoldZoneId:int = 1;

      // Живые объекты (слабые ключи: объект -> true)
      public static const bonuses:Dictionary = new Dictionary(true);
      public static const mines:Dictionary = new Dictionary(true);

      // Типы ящиков для ESP (раскраска маркеров)
      public static const BONUS_UNKNOWN:int = 0;
      public static const BONUS_NITRO:int = 1;
      public static const BONUS_DAMAGE:int = 2;
      public static const BONUS_ARMOR:int = 3;
      public static const BONUS_MEDKIT:int = 4;
      public static const BONUS_CRYSTAL:int = 5;
      public static const BONUS_GOLD:int = 6;
      public static const BONUS_RECHARGE:int = 7;

      // juhe: у объекта-спауна бонуса имя имеет вид "тип#номер" (см. BattlePacketHandler),
      // по ключевым словам определяем тип ящика
      public static function parseBonusType(objectName:String):int {
         var s:String = objectName == null ? "" : objectName.toLowerCase();
         if (s.indexOf("gold") >= 0) {
            return BONUS_GOLD;
         }
         if (s.indexOf("crystal") >= 0 || s.indexOf("cry") >= 0) {
            return BONUS_CRYSTAL;
         }
         if (s.indexOf("nitro") >= 0 || s.indexOf("speed") >= 0) {
            return BONUS_NITRO;
         }
         if (s.indexOf("armor") >= 0 || s.indexOf("armour") >= 0) {
            return BONUS_ARMOR;
         }
         if (s.indexOf("damage") >= 0 || s.indexOf("dmg") >= 0) {
            return BONUS_DAMAGE;
         }
         if (s.indexOf("aid") >= 0 || s.indexOf("health") >= 0 || s.indexOf("repair") >= 0 || s.indexOf("medic") >= 0) {
            return BONUS_MEDKIT;
         }
         if (s.indexOf("recharge") >= 0) {
            return BONUS_RECHARGE;
         }
         return BONUS_UNKNOWN;
      }

      public static function registerBonus(bonus:Object):void {
         bonuses[bonus] = true;
      }

      public static function unregisterBonus(bonus:Object):void {
         delete bonuses[bonus];
      }

      public static function registerMine(mine:Object):void {
         mines[mine] = true;
      }

      public static function unregisterMine(mine:Object):void {
         delete mines[mine];
      }

      public static function clearAll():void {
         var key:Object;
         for (key in bonuses) {
            delete bonuses[key];
         }
         for (key in mines) {
            delete mines[key];
         }
         for (key in goldZones) {
            delete goldZones[key];
         }
      }

      // juhe: регистрация зоны падения голда, позиция уже в клиентских юнитах.
      // Возвращает объект-ключ, по которому потом зона удаляется.
      public static function registerGoldZone(x:Number, y:Number, z:Number):Object {
         var zone:Object = {px: x, py: y, pz: z, zoneId: nextGoldZoneId++};
         goldZones[zone] = true;
         return zone;
      }

      public static function unregisterGoldZone(zone:Object):void {
         if (zone != null) {
            delete goldZones[zone];
         }
      }

      // juhe: true если точка рядом с активной зоной падения голда.
      // Используется чтобы опознать голд-ящик, даже когда сервер
      // зовёт его спавн-объект не по имени "gold" (точки - его зона падения).
      public static function isNearGoldZone(x:Number, y:Number, tolerance:Number):Boolean {
         var zone:Object;
         for (zone in goldZones) {
            var dx:Number = zone.px - x;
            var dy:Number = zone.py - y;
            if (dx * dx + dy * dy < tolerance * tolerance) {
               return true;
            }
         }
         return false;
      }
   }
}
