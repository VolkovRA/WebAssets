package;

import assets.Assets;
import assets.ResourceType;

class Main 
{
	
    static function main() 
    {
        Assets.shared.add("cat.jpg", ResourceType.BLOB);
        Assets.shared.add("index.html", ResourceType.BUFFER);
        Assets.shared.add("index.js", ResourceType.TEXT);
        Assets.shared.onProgress = function(l, t){ trace(l, t, l / t);  };
        Assets.shared.onComplete = function(){ trace("Finish!"); trace(Assets.shared); };
        Assets.shared.onError = function(e, r){ trace("Error", e, r); };
        Assets.shared.load();
    }
}