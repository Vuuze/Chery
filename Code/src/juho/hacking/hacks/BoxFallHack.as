package juho.hacking.hacks {

   import juho.hacking.BoxFallHackConfig;
   import juho.hacking.Hack;

   /**
    * Box Fall Speed: ящики припасов (обычные и золотые) падают
    * в N раз быстрее - парашют сдувается почти сразу, ящик лежит
    * на земле через секунду вместо долгого парения.
    *
    * @author juhe
    */
   public class BoxFallHack extends Hack {

      private static const NAME:String = "Box Fall Speed";

      // ID is used in saving to disk
      private static const ID:String = "BOX_FALL_SPEED";

      private static const PROP_MULTIPLIER:String = "Fall speed multiplier";

      public function BoxFallHack() {
         super(NAME, ID);

         this.addProperty(PROP_MULTIPLIER, 2.0, "Number", this.settingsChanged);

         this.pushSettingsToConfig();
         BoxFallHackConfig.enabled = this.isEnabled;
      }

      override public function enable():void {
         super.enable();
         BoxFallHackConfig.enabled = true;
         this.pushSettingsToConfig();
      }

      override public function disable():void {
         super.disable();
         BoxFallHackConfig.enabled = false;
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
      }

      private function pushSettingsToConfig():void {
         BoxFallHackConfig.multiplier = this.getProperty(PROP_MULTIPLIER).value;
      }
   }
}
