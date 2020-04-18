package;

import assets.Assets;
import assets.ResourceType;

class Main 
{
	
	static function main() 
	{
		Assets.instance.load("cat", "cat.jpg", ResourceType.BLOB);
		Assets.instance.load("in", "index.html", ResourceType.BUFFER);
		Assets.instance.load("js", "index.js", ResourceType.TEXT);
		Assets.instance.onProgress = function(l, t){ trace(l, t, l / t); };
		Assets.instance.onComplete = function(){ trace("Finish!"); trace(Assets.instance); };
	}
}