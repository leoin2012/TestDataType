package
{
	import dataType.SDTBase;
	import dataType.SDTInt;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	
	/**
	 * 
	 * Author Leo
	 */
	public class TestDataType extends Sprite
	{
		private var value:SDTInt;
		
		public function TestDataType()
		{
			var btn:TextField = new TextField();
			btn.text = "changeNumber";
			this.addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			value = new SDTInt();
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			trace("oldValue:" + value.value);
			value.value = Math.random() * 255;
			trace("newValue:" + value.value);
		}
	}
}