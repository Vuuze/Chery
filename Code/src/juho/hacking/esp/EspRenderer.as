package juho.hacking.esp {

   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.tanks.battle.BattleService;
   import alternativa.tanks.battle.BattleView;
   import alternativa.tanks.battle.scene3d.Renderer;
   import alternativa.tanks.bonuses.BattleBonus;
   import alternativa.tanks.bonuses.BonusMesh;
   import alternativa.tanks.models.battle.battlefield.mine.ProximityMine;
   import flash.geom.ColorTransform;
   import flash.utils.Dictionary;
   import juho.hacking.EspConfig;

   use namespace alternativa3d;

   /**
    * Рендер ESP: каждый кадр проецирует 3D-позиции зарегистрированных
    * ящиков и мин на экран и двигает туда HUD-маркеры.
    * Проекция 1-в-1 повторяет штатный радар HORNET (BattleRadarHudIndicators).
    *
    * @author juhe
    */
   public class EspRenderer implements Renderer {

      private static const m:Matrix4 = new Matrix4();
      private static const m1:Matrix4 = new Matrix4();
      private static const v:Vector3 = new Vector3();
      private static const cameraPosition:Vector3 = new Vector3();
      private static const direction:Vector3 = new Vector3();

      private static const MARGIN:Number = 15;
      private static const BONUS_Z_OFFSET:Number = 60;
      private static const MINE_Z_OFFSET:Number = 35;

      // juhe: цвета мин по команде владельца
      private static const MINE_COLOR_OWN:uint = 0x33CCFF;   // своя - голубая
      private static const MINE_COLOR_ALLY:uint = 0x44DD44;  // союзная - зелёная
      private static const MINE_COLOR_ENEMY:uint = 0xFF4444; // вражеская - красная

      // juhe: цвета ящиков по типу бонуса
      private static const BOX_COLOR_UNKNOWN:uint = 0xFFCC00; // неизвестный - жёлтый (как раньше)
      private static const BOX_COLOR_NITRO:uint = 0xFFEE00;   // нитро - жёлтый
      private static const BOX_COLOR_DAMAGE:uint = 0xFF4444;  // ДД - красный
      private static const BOX_COLOR_ARMOR:uint = 0x8B5A2B;   // ДА - коричневый
      private static const BOX_COLOR_MEDKIT:uint = 0xFFFFFF;  // аптека - белый
      private static const BOX_COLOR_CRYSTAL:uint = 0x3399FF; // кри - синий
      private static const BOX_COLOR_RECHARGE:uint = 0xFF66CC; // речардж - сиреневый

      private static function boxColor(t:int):uint {
         switch (t) {
            case EspConfig.BONUS_NITRO: return BOX_COLOR_NITRO;
            case EspConfig.BONUS_DAMAGE: return BOX_COLOR_DAMAGE;
            case EspConfig.BONUS_ARMOR: return BOX_COLOR_ARMOR;
            case EspConfig.BONUS_MEDKIT: return BOX_COLOR_MEDKIT;
            case EspConfig.BONUS_CRYSTAL: return BOX_COLOR_CRYSTAL;
            case EspConfig.BONUS_GOLD: return EspConfig.goldColor; // juhe: настраиваемый цвет голда
            case EspConfig.BONUS_RECHARGE: return BOX_COLOR_RECHARGE;
            default: return BOX_COLOR_UNKNOWN;
         }
      }

      private static function boxLabel(t:int):String {
         switch (t) {
            case EspConfig.BONUS_NITRO: return "NITRO";
            case EspConfig.BONUS_DAMAGE: return "DD";
            case EspConfig.BONUS_ARMOR: return "DA";
            case EspConfig.BONUS_MEDKIT: return "MED";
            case EspConfig.BONUS_CRYSTAL: return "CRY";
            case EspConfig.BONUS_GOLD: return "GOLD";
            case EspConfig.BONUS_RECHARGE: return "RCH";
            default: return "BOX";
         }
      }

      private var battleService:BattleService;
      private var markersMap:Dictionary = new Dictionary(true);

      public function EspRenderer(param1:BattleService) {
         super();
         this.battleService = param1;
      }

      public function dispose():void {
         var view:BattleView = this.battleService.getBattleView();
         if (view != null) {
            var marker:EspMarker;
            for each (marker in this.markersMap) {
               view.removeOverlayObject(marker);
            }
         }
         this.markersMap = new Dictionary(true);
      }

      public function render(param1:int, param2:int):void {
         var marker:EspMarker;
         if (!EspConfig.enabled) {
            for each (marker in this.markersMap) {
               marker.visible = false;
            }
            return;
         }

         if (this.battleService.getBattleScene3D() == null || this.battleService.getBattleView() == null) {
            return;
         }
         var camera:Camera3D = this.battleService.getBattleScene3D().getCamera();
         if (camera == null) {
            return;
         }

         this.syncMarkers();

         var proj:Matrix4 = this.calculateProjectionMatrix(camera);
         var view:BattleView = this.battleService.getBattleView();
         var key:Object;
         for (key in this.markersMap) {
            this.updateMarker(key, EspMarker(this.markersMap[key]), proj, camera, view);
         }
      }

      // juhe: заставляет саму 3D-коробку "светиться" - яркий золотой colorTransform
      // поверх родного карточного освещения (setColorTransform соблюдает базовый свет)
      private function applyGoldMeshGlow(bonus:BattleBonus):void {
         var mesh:BonusMesh = bonus.getBonusMesh();
         if (mesh == null) {
            return;
         }
         // собрать из настраиваемого цвета: r/g/b каналы усиливаем до яркого свечения
         var c:uint = EspConfig.goldColor;
         var t:ColorTransform = new ColorTransform();
         t.redOffset = 80 + ((c >> 16) & 0xFF) / 2;
         t.greenOffset = 80 + ((c >> 8) & 0xFF) / 2;
         t.blueOffset = 40 + (c & 0xFF) / 4;
         t.redMultiplier = 1.3;
         t.greenMultiplier = 1.3;
         t.blueMultiplier = 1.1;
         mesh.setColorTransform(t);
      }

      private function syncMarkers():void {
         var key:Object;
         var marker:EspMarker;
         var view:BattleView = this.battleService.getBattleView();

         // выкинуть маркеры исчезнувших или отключенных объектов
         var stale:Array = [];
         for (key in this.markersMap) {
            if (!this.isTracked(key)) {
               stale.push(key);
            }
         }
         for each (key in stale) {
            view.removeOverlayObject(EspMarker(this.markersMap[key]));
            delete this.markersMap[key];
         }

         // добавить маркеры новых объектов
         if (EspConfig.boxesEnabled) {
            for (key in EspConfig.bonuses) {
               this.addMarkerIfMissing(key, 0xFFCC00, "BOX", view);
            }
         }
         if (EspConfig.minesEnabled) {
            for (key in EspConfig.mines) {
               this.addMarkerIfMissing(key, this.mineColor(ProximityMine(key)), "MINE", view);
            }
         }
         // juhe: зоны падения голда
         if (EspConfig.goldZonesEnabled) {
            for (key in EspConfig.goldZones) {
               this.addMarkerIfMissing(key, EspConfig.goldZoneColor, "GOLD ZONE", view);
            }
         }
      }

      private function mineColor(mine:ProximityMine):uint {
         switch (mine.getOwnerRelation()) {
            case 0:
               return MINE_COLOR_OWN;
            case 1:
               return MINE_COLOR_ALLY;
            default:
               return MINE_COLOR_ENEMY;
         }
      }

      private function addMarkerIfMissing(key:Object, color:uint, text:String, view:BattleView):void {
         if (this.markersMap[key] != null) {
            return;
         }
         var marker:EspMarker = new EspMarker(color, text);
         marker.visible = false;
         this.markersMap[key] = marker;
         view.addOverlayObject(marker);
      }

      private function isTracked(key:Object):Boolean {
         if (key is BattleBonus) {
            return EspConfig.boxesEnabled && EspConfig.bonuses[key] === true;
         }
         if (key is ProximityMine) {
            return EspConfig.minesEnabled && EspConfig.mines[key] === true;
         }
         // juhe: зона падения голда - простой объект с полями px/py/pz
         if (key.hasOwnProperty("zoneId")) {
            return EspConfig.goldZonesEnabled && EspConfig.goldZones[key] === true;
         }
         return false;
      }

      private function readWorldPosition(key:Object, out:Vector3):Boolean {
         if (key is BattleBonus) {
            var mesh:BonusMesh = BattleBonus(key).getBonusMesh();
            if (mesh == null) {
               return false;
            }
            mesh.readPosition(out);
            out.z += BONUS_Z_OFFSET;
            return true;
         }
         if (key is ProximityMine) {
            out.copy(ProximityMine(key).position);
            out.z += MINE_Z_OFFSET;
            return true;
         }
         // juhe: зона падения голда
         if (key.hasOwnProperty("zoneId")) {
            out.reset(key.px, key.py, key.pz + BONUS_Z_OFFSET);
            return true;
         }
         return false;
      }

      private function updateMarker(key:Object, marker:EspMarker, proj:Matrix4, camera:Camera3D, view:BattleView):void {
         if (!this.readWorldPosition(key, v)) {
            marker.visible = false;
            return;
         }
         // juhe: команда владельца мины может "дозреть" позже (когда появится localTank)
         if (key is ProximityMine) {
            marker.setColor(this.mineColor(ProximityMine(key)));
         }
         // juhe: ящики красим и подписываем по типу бонуса (нитро/ДД/ДА/аптечка/кри/голд)
         if (key is BattleBonus) {
            var bonusType:int = BattleBonus(key).espBonusType;
            // juhe: голд падает точно в свою зону - если ящик стоит рядом с активной
            // зоной голда, это голд, даже если имя его спавн-объекта не содержит "gold"
            if (bonusType != EspConfig.BONUS_GOLD && EspConfig.isNearGoldZone(v.x, v.y, 600)) {
               bonusType = EspConfig.BONUS_GOLD;
               // juhe: подсветка самой 3D-коробки - яркий золотой цветной на меш
               this.applyGoldMeshGlow(BattleBonus(key));
            }
            marker.setKind(boxLabel(bonusType), boxColor(bonusType));
            // juhe: настраиваемая прозрачность голда
            marker.setOpacity(bonusType == EspConfig.BONUS_GOLD ? EspConfig.goldOpacity : 100);
            // juhe: маркер голда крупнее обычного
            var goldScale:Number = bonusType == EspConfig.BONUS_GOLD ? 2.2 : 1;
            if (marker.scaleX != goldScale) {
               marker.scaleX = goldScale;
               marker.scaleY = goldScale;
            }
         }
         // juhe: зона падения голда - цвет/прозрачность из настроек + крупный маркер
         if (key.hasOwnProperty("zoneId")) {
            marker.setKind("GOLD ZONE", EspConfig.goldZoneColor);
            marker.setOpacity(EspConfig.goldZoneOpacity);
            var zoneScale:Number = 2.4;
            if (marker.scaleX != zoneScale) {
               marker.scaleX = zoneScale;
               marker.scaleY = zoneScale;
            }
         }
         v.transform4(proj);
         this.projectToView(v, view);

         if (v.z <= 0 || !this.isPointInsideViewport(v.x, v.y, view)) {
            marker.visible = false;
            return;
         }

         marker.visible = true;
         marker.x = int(v.x + view.getWidth() / 2);
         marker.y = int(v.y + view.getHeight() / 2);

         if (EspConfig.showDistance) {
            cameraPosition.reset(camera.x, camera.y, camera.z);
            this.readWorldPosition(key, direction);
            direction.diff(direction, cameraPosition);
            marker.setDistance(int(direction.length() / 100));
         } else {
            marker.resetLabel();
         }
      }

      private function isPointInsideViewport(px:Number, py:Number, view:BattleView):Boolean {
         var hw:Number = view.getWidth() / 2 - MARGIN;
         var hh:Number = view.getHeight() / 2 - MARGIN;
         return px >= -hw && px <= hw && py >= -hh && py <= hh;
      }

      // ---- дальше взята матричная проекция из BattleRadarHudIndicators ----

      private function projectToView(param1:Vector3, view:BattleView):void {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var camera:Camera3D = this.battleService.getBattleScene3D().getCamera();
         if (param1.z > 0.001) {
            param1.x = param1.x * camera.viewSizeX / param1.z;
            param1.y = param1.y * camera.viewSizeY / param1.z;
         } else if (param1.z < -0.001) {
            param1.x = -param1.x * camera.viewSizeX / param1.z;
            param1.y = -param1.y * camera.viewSizeY / param1.z;
         } else {
            _loc2_ = Number(view.getDiagonalSquared());
            _loc3_ = Math.sqrt(param1.x * param1.x + param1.y * param1.y);
            param1.x *= _loc2_ / _loc3_;
            param1.y *= _loc2_ / _loc3_;
         }
      }

      private function calculateProjectionMatrix(camera:Camera3D):Matrix4 {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc1_:Number = camera.viewSizeX / camera.focalLength;
         var _loc2_:Number = camera.viewSizeY / camera.focalLength;
         var _loc3_:Number = Math.cos(camera.rotationX);
         var _loc4_:Number = Math.sin(camera.rotationX);
         var _loc5_:Number = Math.cos(camera.rotationY);
         var _loc6_:Number = Math.sin(camera.rotationY);
         var _loc7_:Number = Math.cos(camera.rotationZ);
         var _loc8_:Number = Math.sin(camera.rotationZ);
         var _loc9_:Number = _loc7_ * _loc6_;
         var _loc10_:Number = _loc8_ * _loc6_;
         var _loc11_:Number = _loc5_ * camera.scaleX;
         var _loc12_:Number = _loc4_ * camera.scaleY;
         _loc13_ = _loc3_ * camera.scaleY;
         _loc14_ = _loc3_ * camera.scaleZ;
         _loc15_ = _loc4_ * camera.scaleZ;
         m.m00 = _loc7_ * _loc11_ * _loc1_;
         m.m01 = (_loc9_ * _loc12_ - _loc8_ * _loc13_) * _loc2_;
         m.m02 = _loc9_ * _loc14_ + _loc8_ * _loc15_;
         m.m03 = camera.x;
         m.m10 = _loc8_ * _loc11_ * _loc1_;
         m.m11 = (_loc10_ * _loc12_ + _loc7_ * _loc13_) * _loc2_;
         m.m12 = _loc10_ * _loc14_ - _loc7_ * _loc15_;
         m.m13 = camera.y;
         m.m20 = -_loc6_ * camera.scaleX * _loc1_;
         m.m21 = _loc5_ * _loc12_ * _loc2_;
         m.m22 = _loc5_ * _loc14_;
         m.m23 = camera.z;
         var _loc16_:Object3D = camera;
         while (_loc16_.parent != null) {
            _loc16_ = _loc16_.parent;
            m.append(composeObject3DMatrix(_loc16_));
         }
         m.invert();
         return m;
      }

      private static function composeObject3DMatrix(param1:Object3D):Matrix4 {
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc2_:Number = Math.cos(param1.rotationX);
         var _loc3_:Number = Math.sin(param1.rotationX);
         var _loc4_:Number = Math.cos(param1.rotationY);
         var _loc5_:Number = Math.sin(param1.rotationY);
         _loc6_ = Math.cos(param1.rotationZ);
         var _loc7_:Number = Math.sin(param1.rotationZ);
         var _loc8_:Number = _loc6_ * _loc5_;
         _loc9_ = _loc7_ * _loc5_;
         _loc10_ = _loc4_ * param1.scaleX;
         _loc11_ = _loc3_ * param1.scaleY;
         var _loc12_:Number = _loc2_ * param1.scaleY;
         _loc13_ = _loc2_ * param1.scaleZ;
         var _loc14_:Number = _loc3_ * param1.scaleZ;
         m1.m00 = _loc6_ * _loc10_;
         m1.m01 = _loc8_ * _loc11_ - _loc7_ * _loc12_;
         m1.m02 = _loc8_ * _loc13_ + _loc7_ * _loc14_;
         m1.m03 = param1.x;
         m1.m10 = _loc7_ * _loc10_;
         m1.m11 = _loc9_ * _loc11_ + _loc6_ * _loc12_;
         m1.m12 = _loc9_ * _loc13_ - _loc6_ * _loc14_;
         m1.m13 = param1.y;
         m1.m20 = -_loc5_ * param1.scaleX;
         m1.m21 = _loc4_ * _loc11_;
         m1.m22 = _loc4_ * _loc13_;
         m1.m23 = param1.z;
         return m1;
      }
   }
}
