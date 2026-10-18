package juho.hacking {
   
   import juho.hacking.hacks.SpeedHack;
   import juho.hacking.Hack;
   import juho.hacking.hacks.TankIgnoreHack;
   import juho.hacking.hacks.AimHack;
   import juho.hacking.hacks.WallHack;
   import juho.hacking.hacks.WeaponHack;
   import juho.hacking.hacks.TriggerBotHack;
   import juho.hacking.hacks.EspHack;
   import juho.hacking.hacks.BoxFallHack;
   import juho.hacking.hacks.HitboxHack;
   import juho.hacking.hacks.BoxHitboxHack;
   
   public class HackRegistry {
      
      public static var allHacks:Vector.<Hack>;
      
      public function HackRegistry() {
         allHacks = new Vector.<Hack>();
         
         var tankIgnoreHack:TankIgnoreHack = new TankIgnoreHack()
         allHacks.push(tankIgnoreHack);
         
         var aimHack:AimHack = new AimHack()
         allHacks.push(aimHack);
         
         var wallHack:WallHack = new WallHack()
         allHacks.push(wallHack);

         var speedHack:SpeedHack = new SpeedHack()
         allHacks.push(speedHack);

         var weaponHack:WeaponHack = new WeaponHack()
         allHacks.push(weaponHack);

         var triggerBotHack:TriggerBotHack = new TriggerBotHack()
         allHacks.push(triggerBotHack);

         var espHack:EspHack = new EspHack()
         allHacks.push(espHack);


         var boxFallHack:BoxFallHack = new BoxFallHack()
         allHacks.push(boxFallHack);

         var hitboxHack:HitboxHack = new HitboxHack()
         allHacks.push(hitboxHack);

         var boxHitboxHack:BoxHitboxHack = new BoxHitboxHack()
         allHacks.push(boxHitboxHack);

      }
   }
}