package juho.hacking.hackmenu
{
    import flash.display.Sprite;
    import fl.containers.ScrollPane;
    import fl.controls.ScrollPolicy;
    import utils.ScrollStyleUtils;

    public class HackMenuList extends ScrollPane {

        private var _cont:Sprite;
        private var some:Sprite;
        private var previousItem:HackMenuItem;

        public function HackMenuList() {
            super();
            this.some = new Sprite();
            this._cont = new Sprite();
            this._cont.addChild(some);

            ScrollStyleUtils.setGreenStyle(this);
            this.horizontalScrollPolicy = ScrollPolicy.OFF;
            this.verticalScrollPolicy = ScrollPolicy.AUTO;
            this.source = this._cont;
            // juhe: побольше шаг прокрутки, чтобы листалось быстрее
            this.verticalLineScrollSize = 80;
            this.verticalPageScrollSize = 400;
            this.update();
            this.focusEnabled = false;
        }

        // juhe: прозрачный спейсер внизу списка, чтобы последний чит
        // можно было прокрутить до конца, а не только край
        public function addBottomSpacer(height:int) : void {
            var spacer:Sprite = new Sprite();
            spacer.graphics.beginFill(0, 0);
            spacer.graphics.drawRect(0, 0, 4, height);
            spacer.graphics.endFill();
            if (previousItem != null) {
                spacer.y = previousItem.y + previousItem.height + 10;
            }
            this._cont.addChild(spacer);
            this.update();
        }

        public function addItem(item:HackMenuItem) : void {
            if (previousItem != null) {
                item.y = previousItem.y + previousItem.height + 10;
            } else {
               item.y = 10
            }

            this.previousItem = item;
            this._cont.addChild(item);
            this.update();
        }

        public function deleteItem(item:HackMenuItem) : void {
            this._cont.removeChild(item);
            this.update();
        }
    }
}