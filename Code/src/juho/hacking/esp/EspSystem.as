package juho.hacking.esp {

   import alternativa.tanks.battle.BattleService;
   import juho.hacking.EspConfig;

   /**
    * Система ESP: подключает EspRenderer к сцене боя на время загрузки боя.
    * Инъекция и жизненный цикл повторяют WallHackSystem (BattlefieldModel
    * держит static const экземпляр и дёргает load/unload).
    *
    * @author juhe
    */
   [ModelInfo]
   public class EspSystem {

      [Inject] // added
      public static var battleService:BattleService;

      private var renderer:EspRenderer;
      private var isLoaded:Boolean = false;

      public function EspSystem() {
         super();
      }

      public function load():void {
         if (this.isLoaded || battleService == null) {
            // защита от null: без battleService лучше отключиться,
            // чем повесить загрузку битвы исключением в objectLoadedPost
            return;
         }
         try {
            this.renderer = new EspRenderer(battleService);
            battleService.getBattleScene3D().addRenderer(this.renderer);
            this.isLoaded = true;
         } catch (e:Error) {
            this.renderer = null;
            this.isLoaded = false;
         }
      }

      public function unload():void {
         if (!this.isLoaded || battleService == null) {
            return;
         }
         try {
            battleService.getBattleScene3D().removeRenderer(this.renderer);
            this.renderer.dispose();
         } catch (e:Error) {
         }
         this.renderer = null;
         this.isLoaded = false;
         EspConfig.clearAll();
      }
   }
}
