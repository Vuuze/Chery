package juho.hacking.hacks {

   import juho.hacking.Hack;
   import juho.hacking.WeaponHackConfig;

   /**
    * Чит на характеристики оружия:
    *  - угол конуса огнемёта (по умолчанию 180°)
    *  - угол конуса фриза   (по умолчанию 180°)
    *  - множитель скорости снаряда твинса (по умолчанию x3)
    *
    * Скорость снаряда твинса применяется мгновенно (читается из
    * TwinsCC каждый кадр). Углы конуса копируются в систему наведения
    * при создании оружия, поэтому применяются при заходе в бой /
    * респавне. Урон всё равно считает сервер.
    *
    * @author juhe
    */
   public class WeaponHack extends Hack {

      private static const NAME:String = "Weapon Hack";

      // ID is used in saving to disk
      private static const ID:String = "WEAPON_HACK";

      private static const PROP_TWINS_SPEED:String = "Twins shell speed multiplier";

      public function WeaponHack() {
         super(NAME, ID);

         this.addProperty(PROP_TWINS_SPEED, 3.0, "Number", this.settingsChanged);

         // Подхватить сохранённые значения свойств
         this.pushSettingsToConfig();
         WeaponHackConfig.enabled = this.isEnabled;
         WeaponHackConfig.reapplyAll();
      }

      override public function enable():void {
         super.enable();
         WeaponHackConfig.enabled = true;
         this.pushSettingsToConfig();
         WeaponHackConfig.reapplyAll();
      }

      override public function disable():void {
         super.disable();
         WeaponHackConfig.enabled = false;
         // reapplyAll с enabled=false вернёт серверные значения
         WeaponHackConfig.reapplyAll();
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
         WeaponHackConfig.reapplyAll();
      }

      private function pushSettingsToConfig():void {
         WeaponHackConfig.twinsSpeedMultiplier = this.getProperty(PROP_TWINS_SPEED).value;
      }
   }
}
