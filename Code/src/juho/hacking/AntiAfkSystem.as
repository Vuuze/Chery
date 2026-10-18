package juho.hacking {

   import alternativa.tanks.battle.BattleService;
   import alternativa.tanks.battle.objects.tank.ClientTankState;
   import alternativa.tanks.battle.objects.tank.Tank;
   import alternativa.tanks.battle.objects.tank.controllers.TurretController;
   import alternativa.tanks.models.tank.LocalTankInfoService;
   import flash.utils.setTimeout;

   /**
    * Anti-AFK: ВСЕГДА активен (не пункт меню, галок нет).
    *
    * Раз в ~100-160 сек делает микро-поворот башни (эмуляция короткого
    * нажатия клавиши башни): уходит штатный ClientRotateTurretOutPacket,
    * серверный анти-АФК видит активность игрока и не кикает.
    * Если игрок сам крутит башню/активен - пинг пропускается.
    *
    * Тикает из LocalTurretController.tick (работает только в битве).
    *
    * @author juhe
    */
   public class AntiAfkSystem {

      // [Inject] Activator (battlefieldmodelflash)
      public static var battleService:BattleService = null;
      public static var localTankInfoService:LocalTankInfoService = null;

      private static var accum:Number = 0;
      private static var nextPingAt:Number = 100 + Math.random() * 60; // сек
      private static var tapActive:Boolean = false;

      public static function tick(dt:Number):void {
         accum += dt;
         if (accum < nextPingAt) {
            return;
         }
         accum = 0;
         nextPingAt = 100 + Math.random() * 60;
         ping();
      }

      private static function ping():void {
         try {
            if (battleService == null || localTankInfoService == null || !battleService.isBattleActive()) {
               return;
            }
            var tank:Tank = localTankInfoService.getLocalTank();
            if (tank == null || tank.health <= 0 || tank.state == ClientTankState.DEAD) {
               return;
            }
            var turret:TurretController = tank.turretController;
            if (turret == null || tapActive) {
               return;
            }
            if (turret.getControl() != 0) {
               return; // игрок сам крутит башню - активность и так идёт
            }
            // микро-поворот влево на 60 мс (~3-6°) - как короткое касание клавиши
            turret.setControlState(1 << TurretController.BIT_LEFT);
            tapActive = true;
            setTimeout(function():void {
               tapActive = false;
               try {
                  turret.setControlState(0);
               } catch (e:*) {
               }
            }, 60);
         } catch (e:*) {
         }
      }
   }
}
