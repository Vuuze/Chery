   package juho.hacking.hacks {
   import juho.hacking.Hack;
   import juho.hacking.SpeedHackConfig;
   import juho.hacking.event.HackEventDispatcher;
   import juho.hacking.event.LocalTankUnloadedEvent;
   import juho.hacking.event.LocalTankInitedEvent;
   import juho.hacking.event.TankSpecificationsChangedEvent;
   import alternativa.tanks.battle.objects.tank.Tank;
   
   public class SpeedHack extends Hack {
  
      private static const NAME:String = "Speed Hack";
      
      // ID is used in saving to disk
      private static const ID:String = "SPEED_HACK";
      
      private var localTank:Tank;
      
      private static const PROP_SPEED:String = "Speed (be careful to not get banned)";
      private static const PROP_TURN_SPEED:String = "Turn speed";
      private static const PROP_TURRET_ROT_SPEED:String = "Turret rotation speed";
      private static const PROP_TURRET_ACCEL:String = "Turret accelaration";
      private static const PROP_ACCEL:String = "Accelaration";
      private static const PROP_TURN_ACCEL:String = "Turn accelaration";
      private static const PROP_AUTO:String = "Auto speed (+% of hull)";
      private static const PROP_PERCENT:String = "Speed bonus %";

      public function SpeedHack() {
         super(NAME, ID);

         this.addProperty(PROP_SPEED, 500.0, "Number", speedChanged);
         this.addProperty(PROP_ACCEL, 1000.0, "Number", speedChanged);
         this.addProperty(PROP_TURN_SPEED, 3.0, "Number", speedChanged);
         this.addProperty(PROP_TURN_ACCEL, 5.0, "Number", speedChanged);
         this.addProperty(PROP_TURRET_ROT_SPEED, 3.0, "Number", speedChanged);
         this.addProperty(PROP_TURRET_ACCEL, 2.0, "Number", speedChanged);
         this.addProperty(PROP_AUTO, false, "Boolean", autoChanged);
         this.addProperty(PROP_PERCENT, 30.0, "Number", percentChanged);
         this.pushAutoToConfig();
         HackEventDispatcher.singleton.addEventListener(LocalTankInitedEvent.LOCAL_TANK_INITED, this.localTankInited);
         HackEventDispatcher.singleton.addEventListener(LocalTankUnloadedEvent.LOCAL_TANK_UNLOADED_EVENT, this.localTankDestroyed);
         HackEventDispatcher.singleton.addEventListener(TankSpecificationsChangedEvent.TANK_SPECIFICATIONS_CHANGED_EVENT, this.tankSpecificationsChanged);
      }
      
      override public function enable():void {
         super.enable();
         this.setSpeed();
      }
      
      override public function disable():void {
         super.disable();
      }
      
      private function speedChanged(value:*):void {
         this.setSpeed();
      }
      
      private function localTankInited(e:LocalTankInitedEvent) : void {
         this.localTank = e.localTank;
         if(isEnabled)
            enable()
         else
            disable()
      }
      
      private function localTankDestroyed(e:LocalTankUnloadedEvent) : void {
         this.localTank = null;
      }
      
      public function tankSpecificationsChanged(e:TankSpecificationsChangedEvent) : void {
         if (e.tank == this.localTank) {
            this.setSpeed();
         }
      }
      
      private function autoChanged(value:*):void {
         this.pushAutoToConfig();
         this.setSpeed();
      }

      private function percentChanged(value:*):void {
         this.pushAutoToConfig();
         this.setSpeed();
      }

      private function pushAutoToConfig():void {
         SpeedHackConfig.autoEnabled = this.getProperty(PROP_AUTO).value;
         SpeedHackConfig.bonusPercent = this.getProperty(PROP_PERCENT).value;
      }

      private function setSpeed() : void {
         if (this.localTank == null || !this.isEnabled) {
            return;
         }

         var speed:Number;
         var turnSpeed:Number;
         var accelaration:Number;
         var turnAccelaration:Number;
         var turretRotationSpeed:Number;
         var turretAccelaration:Number;

         if (SpeedHackConfig.autoEnabled && SpeedHackConfig.hasBase()) {
            // juhe: авто-режим - штатная скорость корпуса + N%
            var f:Number = SpeedHackConfig.factor();
            speed = SpeedHackConfig.baseSpeed * f;
            turnSpeed = SpeedHackConfig.baseTurnSpeed > 0 ? SpeedHackConfig.baseTurnSpeed * f : this.getProperty(PROP_TURN_SPEED).value;
            accelaration = SpeedHackConfig.baseAcceleration > 0 ? SpeedHackConfig.baseAcceleration * f : this.getProperty(PROP_ACCEL).value;
            turnAccelaration = SpeedHackConfig.baseTurnAcceleration > 0 ? SpeedHackConfig.baseTurnAcceleration * f : this.getProperty(PROP_TURN_ACCEL).value;
            turretRotationSpeed = SpeedHackConfig.baseTurretTurnSpeed > 0 ? SpeedHackConfig.baseTurretTurnSpeed * f : this.getProperty(PROP_TURRET_ROT_SPEED).value;
            // башенное ускорение: отдельной базы нет - берём текущее живое
            turretAccelaration = this.localTank.turretController.getTurnAcceleration();
            if (!(turretAccelaration > 0)) {
               turretAccelaration = this.getProperty(PROP_TURRET_ACCEL).value;
            } else {
               turretAccelaration *= f;
            }
         } else {
            speed = this.getProperty(PROP_SPEED).value;
            turnSpeed = this.getProperty(PROP_TURN_SPEED).value;
            accelaration = this.getProperty(PROP_ACCEL).value;
            turnAccelaration = this.getProperty(PROP_TURN_ACCEL).value;
            turretRotationSpeed = this.getProperty(PROP_TURRET_ROT_SPEED).value;
            turretAccelaration = this.getProperty(PROP_TURRET_ACCEL).value;
         }

         this.localTank.setMaxSpeed(speed, true);
         this.localTank.setMaxTurnSpeed(turnSpeed, true);
         this.localTank.setAcceleration(accelaration)
         this.localTank.setTurnAccelaration(turnAccelaration)
         this.localTank.turretController.setMaxTurnSpeed(turretRotationSpeed, true);
         this.localTank.turretController.setTurnAcceleration(turretAccelaration);
      }
   
   }
}