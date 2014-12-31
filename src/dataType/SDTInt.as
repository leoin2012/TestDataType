package dataType
{
	
	/**
	 * 
	 * Author Leo
	 */
	public class SDTInt extends SDTBase
	{
		public function SDTInt()
		{
			super();
		}
		
		public function set value(data:int):void
		{
			var bytes: Object = SDCore.string2bytes(data.toString());
			super.setValue(bytes);
			SDCore.freeBytes(bytes);
		}
		
		public function get value():int
		{
			var bytes:Object = super.getValue();
			var dat:int = Number(SDCore.bytes2string(bytes));
			SDCore.freeBytes(bytes);
			return dat;
		} 
		
	}
}