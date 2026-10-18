package juho.hacking.hacks {

   import juho.hacking.EspConfig;
   import juho.hacking.Hack;

   /**
    * ESP Hack: подсвечивает HUD-маркерами падающие/стоящие ящики
    * припасов (включая золотые) и мины. Маркеры видны сквозь стены,
    * с дистанцией.
    *
    * @author juhe
    */
   public class EspHack extends Hack {

      private static const NAME:String = "ESP (Boxes, Mines)";

      // ID is used in saving to disk
      private static const ID:String = "ESP";

      private static const PROP_BOXES:String = "Boxes enabled";
      private static const PROP_MINES:String = "Mines enabled";
      private static const PROP_DISTANCE:String = "Show distance";
      private static const PROP_GOLD_ZONES:String = "Gold drop zones enabled";
      private static const PROP_GOLD_COLOR:String = "Gold box color (dec hex)";
      private static const PROP_GOLD_OPACITY:String = "Gold box opacity %";
      private static const PROP_ZONE_COLOR:String = "Gold zone color (dec hex)";
      private static const PROP_ZONE_OPACITY:String = "Gold zone opacity %";

      public function EspHack() {
         super(NAME, ID);

         this.addProperty(PROP_BOXES, true, "Boolean", this.settingsChanged);
         this.addProperty(PROP_MINES, true, "Boolean", this.settingsChanged);
         this.addProperty(PROP_DISTANCE, true, "Boolean", this.settingsChanged);
         this.addProperty(PROP_GOLD_ZONES, true, "Boolean", this.settingsChanged);
         this.addProperty(PROP_GOLD_COLOR, 16746496.0, "Number", this.settingsChanged);
         this.addProperty(PROP_GOLD_OPACITY, 100.0, "Number", this.settingsChanged);
         this.addProperty(PROP_ZONE_COLOR, 16711935.0, "Number", this.settingsChanged);
         this.addProperty(PROP_ZONE_OPACITY, 70.0, "Number", this.settingsChanged);

         this.pushSettingsToConfig();
         EspConfig.enabled = this.isEnabled;
      }

      override public function enable():void {
         super.enable();
         EspConfig.enabled = true;
         this.pushSettingsToConfig();
      }

      override public function disable():void {
         super.disable();
         EspConfig.enabled = false;
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
      }

      private function pushSettingsToConfig():void {
         EspConfig.boxesEnabled = this.getProperty(PROP_BOXES).value;
         EspConfig.minesEnabled = this.getProperty(PROP_MINES).value;
         EspConfig.showDistance = this.getProperty(PROP_DISTANCE).value;
         EspConfig.goldZonesEnabled = this.getProperty(PROP_GOLD_ZONES).value;
         EspConfig.goldColor = uint(Number(this.getProperty(PROP_GOLD_COLOR).value)) & 0xFFFFFF;
         EspConfig.goldOpacity = Number(this.getProperty(PROP_GOLD_OPACITY).value);
         EspConfig.goldZoneColor = uint(Number(this.getProperty(PROP_ZONE_COLOR).value)) & 0xFFFFFF;
         EspConfig.goldZoneOpacity = Number(this.getProperty(PROP_ZONE_OPACITY).value);
      }
   }
}
