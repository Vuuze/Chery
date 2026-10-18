package juho.hacking.hacks {

   import juho.hacking.Hack;
   import juho.hacking.TriggerBotConfig;

   /**
    * Trigger Bot: автоматически стреляет, когда в зону прицела
    * попадает вражеский танк. Работает со Смоки и Громом.
    *
    * Перезарядку и готовность оружия учитывает (стреляет только когда
    * оружие готово), союзников не бьёт (проверка команды).
    * В связке с "Aim cheat" стреляет при захвате цели аимом.
    *
    * @author juhe
    */
   public class TriggerBotHack extends Hack {

      private static const NAME:String = "Trigger Bot (Smoky, Thunder)";

      // ID is used in saving to disk
      private static const ID:String = "TRIGGER_BOT";

      private static const PROP_SMOKY:String = "Smoky enabled";
      private static const PROP_THUNDER:String = "Thunder enabled";

      public function TriggerBotHack() {
         super(NAME, ID);

         this.addProperty(PROP_SMOKY, true, "Boolean", this.settingsChanged);
         this.addProperty(PROP_THUNDER, true, "Boolean", this.settingsChanged);

         this.pushSettingsToConfig();
         TriggerBotConfig.enabled = this.isEnabled;
      }

      override public function enable():void {
         super.enable();
         TriggerBotConfig.enabled = true;
         this.pushSettingsToConfig();
      }

      override public function disable():void {
         super.disable();
         TriggerBotConfig.enabled = false;
      }

      private function settingsChanged(value:*):void {
         this.pushSettingsToConfig();
      }

      private function pushSettingsToConfig():void {
         TriggerBotConfig.smokyEnabledProp = this.getProperty(PROP_SMOKY).value;
         TriggerBotConfig.thunderEnabledProp = this.getProperty(PROP_THUNDER).value;
      }
   }
}
