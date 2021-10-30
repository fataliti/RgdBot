

import haxe.Exception;
import commands.Control;
import haxe.Json;
import sys.net.Host;
import rn.net.tcp.TcpServer;

class RgdWikiTcpServer {
    
    var server:TcpServer;
    var jsServer:String;

    public function new() {
        var methods:Map<String, Dynamic->Void> = [
            '/user' => getUser,
            '/rep' => getRep,
            '/game' => postGame,
        ];

        server = new TcpServer();    
        server.onClientBeforeConnect = c -> {trace('js connect');}
        server.onClientAfterConnect = id -> {jsServer = id; trace('js geted');};

        server.onClientText = (id:String, txt:String) -> {
            try {
                var request:{method:String, body:Dynamic} = Json.parse(txt);
                trace(request);
                var method = methods.get(request.method);
                method(request.body);
            } catch (e:Exception) {
                trace(e.toString());
            }
        }   

        server.start(new Host('127.0.0.1'), 10900);
    }


    public function getUser(data:Dynamic):Void {
        var reqv = Rgd.db.request('SELECT * FROM users WHERE userId = "${data.id}"').results();
        var location = Rgd.db.request('SELECT location FROM spots WHERE userId = "${data.id}"').results();
        var answer = {
            method: 'getUser',
            id: data.id,
            data: reqv.pop(),
        }
        if (location.length > 0) {
            answer.data.location = location.pop().location;
        }
        server.sendText(jsServer, Json.stringify(answer));
    }

    public function getRep(data:Dynamic):Void {
        var reqv =  Rgd.db.request('SELECT fromId,reason,_when  FROM rep WHERE userId = "${data.id}"').results();
        var answer = {
            method: 'getRep',
            id: data.id,
            data: [for (unknown in reqv) unknown],
        }
        server.sendText(jsServer, Json.stringify(answer));
    }

    public function postGame(body:Dynamic):Void {
        if (body.data != null) {
            Control.gocPost([body.data]);
        }
    }

}