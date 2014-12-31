package dataType
{
	
	/**
	 * 
	 * Author Leo
	 */
	public class SDCore
	{
		public function SDCore()
		{
		}
		
		public static function freeBytes(bytes: Object): Boolean
		{
			return MemoryPool.freeMemory(bytes);
		}
		
		private static function get crypto(): ICrypto
		{
			return XorArrayCrypto.singleton;		// encrypt 1	decrypt 1
		}
		
		public static function randBytes(len: int): Object
		{
			return crypto.randBytes(len);
		}
		
		public static function string2bytes(str: String): Object
		{
			return crypto.str2bytes(str);
		}
		
		public static function bytes2string(bytes: Object): String
		{
			return crypto.bytes2str(bytes);
		}
		
		public static function decrypt(cryptograph: Object, key: Object): Object
		{
			var r: Object = crypto.decrypt(cryptograph, key);
			return r;
		}  
		
		public static function encrypt(plaintext: Object, key: Object): Object
		{
			var r: Object = crypto.encrypt(plaintext, key);
			return r;
		}
		
		public static function get keylen(): int
		{
			return crypto.keylen;
		}
		
	}
}

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

//-----------------------------------------------------
class MemoryPool
{
	private static var ms_singleton: MemoryPool;
	
	public static function get singleton(): MemoryPool
	{
		if (ms_singleton == null)
		{
			ms_singleton = new MemoryPool();
		}
		return ms_singleton;
	}
	
	private static var ms_pool: Dictionary = new Dictionary();
	
	public static function getByteArray(len: int = 0): ByteArray
	{
		var bytes: ByteArray = getMemory(ByteArray) as ByteArray;
		bytes.length = len;
		return bytes;
	}
	
	public static function getArray(len: int = 0): Array
	{
		var arr: Array = getMemory(Array) as Array;
		arr.length = len;
		return arr;
	}
	
	public static function getMemory(clazz: Class): Object
	{
		if (clazz)
		{
			var pool: Array = ms_pool[clazz];
			if (pool && pool.length > 0)
			{
				return pool.pop();
			}
			else
			{
				return new clazz();
			}
		}
		return null;
	}
	
	private static function getClass(object: Object): *
	{
		if (object)
		{
			var clazz: * = null;
			try
			{
				var className: String = getQualifiedClassName(object);
				clazz = className ? getDefinitionByName(className) : null;
			}
			catch (e: Error)
			{}
			
			if (clazz)
			{
				return clazz;
			}
			else if (object.hasOwnProperty("constructor"))
			{
				return object.constructor;
			}
		}
		return null;
	}
	
	public static function freeMemory(object: Object): Boolean
	{
		if (object)
		{
			var clazz: Class = getClass(object);
			if (clazz)
			{
				var pool: Array = ms_pool[clazz];
				if (pool)
				{
					if (pool.indexOf(object) < 0)
					{
						pool.push(object);
						return true;
					}
				}
				else
				{
					ms_pool[clazz] = [object];
					return true;
				}
			}
		}
		return false;
	}
}

function arr2bytes(arr: Array): ByteArray
{
	var bytes: ByteArray = MemoryPool.getByteArray();//new ByteArray();
	for each (var str: String in arr)
	{
		var val: int = int(str);
		bytes.writeByte(val);
	}
	bytes.position = 0;
	return bytes;
}

function bytes2arr(bytes: ByteArray): Array
{
	var arr: Array = null;
	if (bytes)
	{
		var pos: int = bytes.position;
		bytes.position = 0;
		arr = MemoryPool.getArray();//[];
		
		for (var i: int = 0, n: int = bytes.bytesAvailable; i < n; i++)
		{
			var val: uint = bytes.readUnsignedByte();
			arr.push(val.toString());
		}
		bytes.position = pos;
	}
	return arr;
}

//-----------------------------------------------------
interface ICrypto
{
	function cloneBytes(bytes: Object): Object;
	function randBytes(len: int): Object;
	function compareBytes(bytes1: Object, bytes2: Object): Boolean;
	function str2bytes(str: String): Object;
	function bytes2str(bytes: Object): String;
	function get keylen(): int;
	function decrypt(cryptograph: Object, key: Object): Object;
	function encrypt(plaintext: Object, key: Object): Object;
}

//.....................................................
class BaseArrayCrypto implements ICrypto
{
	public function cloneBytes(bytes: Object): Object
	{
		var arr: Array = bytes as Array;
		if (arr)
		{
			var arrLen:int = arr.length;
			var buf:Array = MemoryPool.getArray(arrLen);//new Array(arrLen);
			
			var i:int = 0;
			while (i < arrLen)
			{
				buf[i] = arr[i];
				++i;
			}
		}
		return buf;
	}
	
	public function randBytes(len: int): Object
	{
		var bytes: Array = MemoryPool.getArray();//[];
		for (var i: int = 0; i < len; i++)
		{
			bytes[i] = (int)(Math.random() * 255);
		}
		return bytes;
	}
	
	public function compareBytes(bytes1: Object, bytes2: Object): Boolean
	{
		var arr1: Array = bytes1 as Array;
		var arr2: Array = bytes2 as Array;
		if (arr1 && arr2)
		{
			if(arr1.length == arr2.length)
			{
				for(var i:int = 0, n: int = arr1.length; i < n; ++i)
				{
					if(arr1[i] != arr2[i])
					{
						return false;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	public function str2bytes(s: String): Object
	{
		var len:uint = s.length;
		var ret:Array = MemoryPool.getArray(len << 1);//new Array(len << 1);
		var ch:uint = 0;
		var i:uint = 0;
		while (i < len)
		{
			ch = s.charCodeAt(i);
			ret[i << 1] = ch & 255;//0xff 取低位
			ret[(i << 1) + 1] = ch >> 8 & 255; //取高位
			++i;
		}
		return ret;
	}
	
	public function bytes2str(bytes: Object): String
	{
		var ret: String = null;
		var arr: Array = bytes as Array;
		if (arr)
		{
			var nArrLen:uint = arr.length;
			if (nArrLen & 1 != 0)
			{
				//如果是奇数，则错误！
				return null;
			}
			
			var nStrLen:uint = nArrLen >> 1;
			var ch:String = "";
			var i:uint = 0;
			ret = "";
			while (i < nStrLen)
			{
				ch = String.fromCharCode(arr[(i << 1) + 1] << 8 ^ arr[i << 1]);
				ret = ret + ch;
				++i;
			}
		}
		return ret;
	}
	
	public function decrypt(cryptograph: Object, key: Object): Object
	{
		var originBytes: Array = cryptograph as Array;
		var keyBytes: Array = key as Array;
		if (originBytes && (this.keylen > 0 && keyBytes || this.keylen == 0))
		{
			var bytes: Array = doDecrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}  
	
	public function encrypt(plaintext: Object, key: Object): Object
	{
		var originBytes: Array = plaintext as Array;
		var keyBytes: Array = key as Array;
		if (originBytes && keyBytes)
		{
			var bytes: Array = doEncrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}
	
	public function get keylen(): int
	{
		return 0;
	}
	
	protected function doDecrypt(originBytes: Array, keyBytes: Array): Array
	{
		return null;
	}
	
	protected function doEncrypt(originBytes: Array, keyBytes: Array): Array
	{
		return null;
	}
}


//----------------------------------  ---------------------------------------
class XorArrayCrypto extends BaseArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new XorArrayCrypto();
		}
		return ms_singleton;
	}
	
	protected override function doDecrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	protected override function doEncrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	public override function get keylen(): int
	{
		return 3;
	}
	
	private static function crypt(originBytes: Array, keyBytes: Array): Array
	{
		var bytes: Array = null;
		if (originBytes && keyBytes)
		{
			bytes = MemoryPool.getArray();//[];
			for (var i: int = 0, n: int = originBytes.length, m: int = keyBytes.length; i < n; i++)
			{
				var byte: uint = originBytes[i];
				var mask: uint = keyBytes[i % m];
				byte ^= mask;
				bytes.push(byte);
			}
		}
		return bytes;
	}
}