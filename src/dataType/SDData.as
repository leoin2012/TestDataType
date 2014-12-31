package dataType
{
	
	/**
	 * 
	 * Author Leo
	 */
	public class SDData
	{
		private var m_store: Object = null;
		private var m_key: Object = null;
		private var m_len:int = 0;
		
		public function SDData()
		{
		}
		
		public function dispose(): void
		{
			SDCore.freeBytes(m_key);
			SDCore.freeBytes(m_store);
			
			m_store = null;
			m_key = null;
			m_len = 0;
		}
		
		public function readStringBytes(): Object
		{
			var ret: Object = SDCore.decrypt(m_store, m_key);
			return ret;
		}
		
		
		public static function createByBytes(bytes: Object):SDData
		{
			var ret:SDData;
			if (bytes)
			{
				ret = new SDData();//安全数据
				ret.m_len = bytes.length;
				
				var buf: Object = bytes;//SDCore.cloneBytes(bytes);
				ret.m_key = SDCore.randBytes(SDCore.keylen);
				ret.m_store = SDCore.encrypt(buf, ret.m_key);
			}
			return ret;
		}
		
	}
}