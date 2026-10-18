package juho.hacking.hacks {

   import juho.hacking.BoxHitboxHackConfig;
   import juho.hacking.Hack;

   /**
    * Box Hitbox ("магнит ящиков"): ящики-припасы подбираются
    * издалека - их хитбокс подбора увеличивается в N раз.
    * Множитель настраивается в меню (как скорость падения).
    *
    * @author juhe
    */
   public class BoxHitboxHack extends Hack {

      private static const NAME:String = "Box Hitbox";

      // ID is used in saving to disk
      private static const ID:String = "BOX_HITBOX";

      private static const PROP_MULTIPLIER:String = "Pickup size multiplier";

      public function BoxHitboxHack() {
         super(NAME, ID);

         this.addProperty(PROP_MULTIPLIER, 2.0, "Number", this.settingsChanged);

         this.pushSettingsToConfig();
         BoxHitboxHackConfig.enabled = this.isEnabled;
      }

      override public function enable():void {
         super.enable();
         BoxHitboxHackConfig.enabled = true;
         this.pushSettingsToConfig();
      }

      override public function disable():void {
         super.disable();
         BoxHitboxHackConfig.enabled = false;
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
      }

      private function pushSettingsToConfig():void {
         BoxHitboxHackConfig.multiplier = this.getProperty(PROP_MULTIPLIER).value;
      }
   }
}
