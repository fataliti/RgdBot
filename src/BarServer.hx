

import haxe.Timer;
import com.raidandfade.haxicord.types.Message;
import neko.Utf8;
import haxe.io.BytesBuffer;
import haxe.Json;
import sys.net.Host;
import rn.net.tcp.TcpServer;
import rn.net.INetworkClient;


class BarServer {
    var clients:Array<String> = new Array();
    var lastMessages:Array<Message> = new Array();

    public var server:TcpServer;
    public function new() {
        server = new TcpServer();

        server.onClientBeforeConnect = c -> {trace('new connect');}
        server.onClientAfterConnect = id -> {clients.push(id); trace('client  add');};
        server.onClientDisconnect = id -> {clients.remove(id); trace('blient remove');}

        if (server.start(new Host('172.31.24.123'), 10803)) {
            trace('bar server started');
        }
    }
    

    public function sendMessage(m:Message):Void {

        lastMessages.push(m);
        if (lastMessages.length > 10) {
            lastMessages.shift();
        }
        if (clients.length > 0) {
            trace('bar send');
        }


        var message:BarMessage = {
            text: m.content,
            author: m.getMember().displayName,
            authorId: m.author.id.id,
            channel: m.getGuild().textChannels[m.channel_id.id].name,
            channelId: m.channel_id.id,
        }
        var jsonString = Json.stringify(message);
        var buf = new BytesBuffer();
        for (i in 0...Utf8.length(jsonString)) {
            buf.addInt32(Utf8.charCodeAt(jsonString, i));
        }
        var bytes = buf.getBytes();
        for (cli in clients) {
            server.sendData(cli, bytes);
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


/*
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
        var server = new WebSocketServer<MyHandler>("127.0.0.1", 10800, 10);
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
        if (connects.length > 0) {
            trace('bar send');
        }
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
*/