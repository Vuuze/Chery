package juho.hacking.hacks {

   import juho.hacking.Hack;
   import juho.hacking.HitboxHackConfig;

   /**
    * Hitbox: хитбокс вражеских танков увеличивается в N раз.
    * Множитель настраивается в меню (как скорость падения ящиков).
    *
    * @author juhe
    */
   public class HitboxHack extends Hack {

      private static const NAME:String = "Hitbox";

      // ID is used in saving to disk
      private static const ID:String = "HITBOX";

      private static const PROP_MULTIPLIER:String = "Size multiplier";

      public function HitboxHack() {
         super(NAME, ID);

         this.addProperty(PROP_MULTIPLIER, 2.0, "Number", this.settingsChanged);

         this.pushSettingsToConfig();
         HitboxHackConfig.enabled = this.isEnabled;
      }

      override public function enable():void {
         super.enable();
         HitboxHackConfig.enabled = true;
         this.pushSettingsToConfig();
      }

      override public function disable():void {
         super.disable();
         HitboxHackConfig.enabled = false;
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
      }

      private function pushSettingsToConfig():void {
         HitboxHackConfig.multiplier = this.getProperty(PROP_MULTIPLIER).value;
      }
   }
}
