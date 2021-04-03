import haxe.io.BytesBuffer;
import com.raidandfade.haxicord.types.Message;
import hx.ws.Log;
import hx.ws.WebSocketServer;
import hx.ws.SocketImpl;
import hx.ws.WebSocketHandler;
import hx.ws.Types;

import haxe.Json;
import neko.Utf8;

class BarServer {
    private var connects:Array<MyHandler> = new Array();

    public function new() {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var server = new WebSocketServer<MyHandler>("localhost", 5000, 10);
        server.start();

        server.onClientAdded = handle -> {
            connects.push(handle);
        }

        server.onClientRemoved = handle -> {
            connects.remove(handle);
            handle.close();
        }
    }

    public function sendMessage(m:Message) {
        var message:BarMessage = {
            text: m.content,
            author: m.getMember().displayName,
            authorId: m.author.id.id,
            channel: m.getGuild().textChannels[m.channel_id.id].name,
            channelId: m.channel_id.id,
        }

        var jsonString = Json.stringify(message);
        var sendString = '';
        var buf = new BytesBuffer();
        for (i in 0...Utf8.length(jsonString)) {
            buf.addInt32(Utf8.charCodeAt(jsonString, i));
        }

        var bytes = buf.getBytes();
        for (handler in connects) {
            handler.send(bytes);
        }
    }

}

class MyHandler extends WebSocketHandler {
    public function new(s: SocketImpl) {
        super(s);
        onopen = function() {
            trace(id + ". OPEN");
        }
        onclose = function() {
            trace(id + ". CLOSE");
        }
        onerror = function(error) {
            trace(id + ". ERROR: " + error);
        }
    }
}

typedef BarMessage = {
    ?text:String,
    ?author:String,
    ?channel:String,
    ?channelId:String,
    ?authorId:String,
} 