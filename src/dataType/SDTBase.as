package dataType
{
	
	/**
	 * 
	 * Author Leo
	 */
	public class SDTBase
	{
		private var m_data:SDData = null;
		
		public function SDTBase()
		{
		}
		
		public function dispose(): void
		{
			if (m_data)
			{
				m_data.dispose();
				m_data = null;
			}
			
		}
		
		protected function setValue(data: Object):void
		{
			if (m_data)
			{
				m_data.dispose();
			}
			m_data = SDData.createByBytes(data);
		}
		
		protected function getValue(): Object
		{
			var bytes: Object;
			if(m_data)
			{
				bytes = m_data.readStringBytes();
			}
			return bytes;        	
		}
		
	}
}