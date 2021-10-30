package commands;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.io.BytesOutput;
import com.raidandfade.haxicord.types.structs.Embed;
import haxe.Json;
import com.raidandfade.haxicord.types.Message;

using Utils;

@desc("Uebermap","Карта участников сервера")
class Uebermap {
    
    public static var token:Null<String>;
    public static var uebermapData = InitData.uebermapData;


    @initialize
    public static function initialize() {

        Rgd.db.request('
            CREATE TABLE IF NOT EXISTS "spots" (
                "userId" TEXT PRIMARY KEY,
                "location" TEXT,
                "spot" INTEGER 
            )'
        );

        var reqv = new sys.Http('https://uebermaps.com/api/v2/authentication');
        reqv.setParameter('user[email]', uebermapData.email);
        reqv.setParameter('user[password]', uebermapData.password);
        reqv.onData = (d:String) -> {
            var authData:AuthStruct = Json.parse(d);
            if (authData.meta.code == 200) {
                token = authData.data.auth_token;
            }
            trace('ueber inited');
        }
        reqv.request(true);
    }

    @command(['map', 'maplink', 'карта'], 'Открыть карту РГД')
    public static function maplink(m:Message, w:Array<String>) {
        var emb:Embed = {};
        emb.author = {
            url: uebermapData.maplink,
            name: 'Карта',
        }
        emb.title = 'участников сервера';
        emb.color = 0xFF9900;
        emb.image = {
            url: 'https://cdn.discordapp.com/attachments/735105892264968234/849528143487827988/1www1.png',
        }
        emb.url = uebermapData.maplink;
        var cnt = Rgd.db.request('SELECT userId FROM spots').results().length;
        emb.footer = {
            text: 'на карте расположилось ${cnt} человек',
        }
        m.reply({embed: emb});
    }

    @command(['spot', 'спот'], 'указать где живешь', '>место жительства')
    public static function spotCreate(m:Message, w:Array<String>) {
        
        if (Rgd.db.request('SELECT userId FROM spots WHERE userId = "${m.author.id.id}"').results().length > 0)  {
            m.answer('для начала удали нынешнее положение');
            return;
        }

        if (w.length == 0) {
            m.answer('не указано место');
            return;
        }

        var coorReqv = new sys.Http('https://geocode.xyz/?scantext=${w.join('-')}&json=1');
        coorReqv.onData = (d:String) -> {
            trace(d);
            d = StringTools.replace(d, '\\','');
            var data:CoordStruct = Json.parse(d);
            
            trace('info geted');
            if (data.latt == null) {
                m.answer('локация не найдена');
                return;
            }

            var spotCreate = new sys.Http('https://uebermaps.com/api/v2/maps/${uebermapData.mapId}/spots');
            spotCreate.setParameter('spot[title]', m.author.username);
            spotCreate.setParameter('spot[description]', 'тут живет ${m.author.username}');
            spotCreate.setParameter('spot[lat]', data.latt);
            spotCreate.setParameter('spot[lon]', data.longt);
            spotCreate.setParameter('auth_token', token);

            spotCreate.onData = (dd:String) -> {
                var results = Json.parse(dd);
                Rgd.db.request('INSERT INTO spots(userId, location, spot) VALUES("${m.author.id.id}", "${w.join(" ")}", ${results.data.id})');
                m.answer('локация установлена');
                trace(dd);
            }
            spotCreate.onError = (dd:String) -> {
                trace(dd);
            }
            spotCreate.onStatus = (dd:Int) -> {
                trace(dd);
            }
            spotCreate.request(true);
        }

        coorReqv.onStatus = s -> {
            if (s != 200) {
                m.answer('что-то пошло не так');
            }
        }
        coorReqv.request();
    }


    @command(['spotcord', 'споткорд'], 'указать где живешь через координаты(для тех кто хочет указать более точное положение или изменить кривое автоматическое)', '>координаты N E')
    public static function spotCreateCoords(m:Message, w:Array<String>) {
        if (Rgd.db.request('SELECT userId FROM spots WHERE userId = "${m.author.id.id}"').results().length > 0)  {
            m.answer('для начала удали нынешнее положение');
            return;
        }

        if (w.length < 2) {
            m.answer('не указаны координаты');
            return;
        }

        var coorReqv = new sys.Http('https://geocode.xyz/${w[0]},${w[1]}?json=1');

        coorReqv.onData = (d:String) -> {
            var data:CoordStruct = Json.parse(d);
            
            trace('info geted');
            if (data.latt == null) {
                m.answer('локация не найдена');
                return;
            }

            var spotCreate = new sys.Http('https://uebermaps.com/api/v2/maps/${uebermapData.mapId}/spots');
            spotCreate.setParameter('spot[title]', m.author.username);
            spotCreate.setParameter('spot[description]', 'тут живет ${m.author.username}');
            spotCreate.setParameter('spot[lat]', data.latt);
            spotCreate.setParameter('spot[lon]', data.longt);
            spotCreate.setParameter('auth_token', token);

            spotCreate.onData = (dd:String) -> {
                var results = Json.parse(dd);
                Rgd.db.request('INSERT INTO spots(userId, location, spot) VALUES("${m.author.id.id}", "${data.city}", ${results.data.id})');
                m.answer('локация установлена');
                trace(dd);
            }
            spotCreate.onError = (dd:String) -> {
                trace(dd);
            }
            spotCreate.onStatus = (dd:Int) -> {
                trace(dd);
            }
            spotCreate.request(true);
        }


        coorReqv.onStatus = s -> {
            if (s != 200) {
                m.answer('что-то пошло не так');
            }
        }
        coorReqv.request();


    }


    @command(['spotdel', 'спотуд'], 'Удалить свое местоположение из профиля и карты')
    public static function spotdel(m:Message, w:Array<String>) {
        var s = Rgd.db.request('SELECT * FROM spots WHERE userId = "${m.author.id.id}"').results();
        if (s.length == 0) {
            m.answer('нечего удалять');
            return;
        }
        trace('delete try');
        var delReqv = new sys.Http('https://uebermaps.com/api/v2/spots/${s.pop().spot}');
        delReqv.addHeader('Authorization', 'Basic ' + Base64.encode(Bytes.ofString(uebermapData.email+":"+uebermapData.password)));

        delReqv.onBytes = (b:Bytes) -> {
            var str = b.getString(0, b.length);
            trace(str);
        }
        delReqv.onStatus = s -> {
            if (s == 200) {
                Rgd.db.request('DELETE FROM spots WHERE userId = "${m.author.id.id}"');
                m.answer('точка удалена');
            }
        }
        delReqv.onError = e -> {
            trace(e);
        }
        delReqv.onData = d -> {
            trace(d);
        }
        var bo = new BytesOutput();
        delReqv.customRequest(true, bo, null, "DELETE");
    }

}


typedef AuthStruct = {
    data: {
        auth_token:String,
    },
    meta: {
        code:Int,
    }
} 

typedef CoordStruct = {
    ?longt:String,
    ?latt:String,
    ?city:String,
}