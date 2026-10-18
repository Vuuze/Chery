package juho.hacking.esp {

   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;

   /**
    * Один маркер ESP: цветной ромб + подпись (напр. BOX / MINE и дистанция).
    *
    * @author juhe
    */
   public class EspMarker extends Sprite {

      private var labelField:TextField;
      private var baseText:String;
      private var markerColor:uint;

      public function EspMarker(color:uint, text:String) {
         super();
         this.baseText = text;
         this.markerColor = color;
         this.mouseEnabled = false;
         this.mouseChildren = false;

         // ромб 7x7
         this.drawDiamond(color);

         this.labelField = new TextField();
         var format:TextFormat = new TextFormat("Tahoma", 10, color, true);
         this.labelField.defaultTextFormat = format;
         this.labelField.autoSize = TextFieldAutoSize.LEFT;
         this.labelField.selectable = false;
         this.labelField.mouseEnabled = false;
         this.labelField.text = text;
         this.labelField.filters = [new GlowFilter(0x000000, 1, 2, 2, 6)];
         this.labelField.y = -24;
         addChild(this.labelField);
      }

      private function drawDiamond(color:uint):void {
         this.graphics.clear();
         this.graphics.beginFill(color, 1);
         this.graphics.drawPath(Vector.<int>([1, 2, 2, 2, 2]),
                                Vector.<Number>([0, -7, 7, 0, 0, 7, -7, 0, 0, -7]));
         this.graphics.endFill();
         this.graphics.lineStyle(1, 0x000000, 0.6);
         this.graphics.drawPath(Vector.<int>([1, 2, 2, 2, 2]),
                                Vector.<Number>([0, -7, 7, 0, 0, 7, -7, 0, 0, -7]));
      }

      // juhe: смена цвета на лету (пока не изменился - вообще ничего не делает)
      public function setColor(color:uint):void {
         if (color == this.markerColor) {
            return;
         }
         this.markerColor = color;
         this.drawDiamond(color);
         this.labelField.textColor = color;
      }

      // juhe: смена вида маркера целиком - текст + цвет (типы ящиков)
      public function setKind(text:String, color:uint):void {
         if (text == this.baseText && color == this.markerColor) {
            return;
         }
         this.baseText = text;
         this.setColor(color);
         this.setLabel(text);
      }

      // juhe: прозрачность маркера в процентах 0..100 (для голда и зоны голда)
      public function setOpacity(percent:Number):void {
         if (percent < 0) {
            percent = 0;
         } else if (percent > 100) {
            percent = 100;
         }
         var a:Number = percent / 100;
         if (a != this.alpha) {
            this.alpha = a;
         }
      }

      public function setLabel(text:String):void {
         if (this.labelField.text != text) {
            this.labelField.text = text;
         }
         this.labelField.x = -int(this.labelField.width / 2);
      }

      public function resetLabel():void {
         this.setLabel(this.baseText);
      }

      public function setDistance(meters:int):void {
         this.setLabel(this.baseText + " " + meters.toString() + "m");
      }
   }
}
