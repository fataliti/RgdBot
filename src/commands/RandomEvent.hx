package commands;

import BarServer.BarMessage;
import haxe.iterators.MapKeyValueIterator;
import haxe.io.Bytes;
import haxe.crypto.Md5;
import neko.Utf8;
import com.raidandfade.haxicord.types.structs.Embed;
import haxe.Http;
import events.OnMessage;
import sys.FileSystem;
import com.raidandfade.haxicord.types.Message;
import haxe.Timer;
import sys.io.File;
import haxe.Json;

using Utils;

@desc("RandomEvent","Рандомная жижа")
class RandomEvent {
    

    static var rndUsed:Array<String> = new Array();
    public static var cursedChannels:Array<{chanId:String, messages:Array<String>}> = new Array();
    static var mutedUsers:Array<String> = new Array();
    public static var renamedUser:Map<String, String> = new Map();
    
    static var banRoad:Map<String, Int> = new Map();
    //static var banned = 

    static var randFuncs:Array<{func:(m:Message, w:Array<String>) -> Void, w:Int}> = new Array();


    @initialize
    public static function initialize() {
        

        if (FileSystem.exists('data/cursed.json')) {
            cursedChannels = Json.parse(File.getContent('data/cursed.json'));
            for (s in cursedChannels) {
                var timer = new Timer(1000*60*15);
                timer.run = () -> {curseChannel(s.chanId, timer);}

                var blessMessage:(Message)->Void = null;
                var blessMessage = (blessMsg:Message) -> {
                    if (blessMsg.channel_id.id != s.chanId) return;
                    if (blessMsg.content == "есус помоги") {
                        if (Math.random() > 0.9) {
                            blessMsg.answer('есус услышал вас');
                            blessChannel(s.chanId);
                            OnMessage.messageOn.remove(blessMessage);
                        }
                    }
                }
                OnMessage.messageOn.push(blessMessage);

            }
        }

        if (FileSystem.exists('data/muted.json')) {
            mutedUsers = Json.parse(File.getContent('data/muted.json'));
            for (s in mutedUsers) {
                Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMember(s, (member) -> {
                    if (member != null) {
                        member.removeRole("703031279670657024");
                        member.removeRole("521748931894444054");
                    }
                });
            }
        }

        if (FileSystem.exists('data/banRoad.json')) {
            banRoad = Json.parse(File.getContent('data/banRoad.json'));
        }

        var push = (func:(m:Message, w:Array<String>) -> Void, w:Int) -> {
            randFuncs.push({func: func, w: w});
        }

        
        push(moneyDrop, 10);
        push(rename, 30);
        push(megatonncick, 5);
        push(texastonncick, 1);
        push(mute, 10);
        push(pisi, 15);
        push(nomoremod, 5);
        push(nothing, 20);
        push(mod15, 1);
        push(curse, 3);
        push(gachibass, 15);
        push(respect, 10);
        push(anek, 15);
        push(noMoreAdmin, 5);
    }

    static function curseChannel(channelId:String, timer:Null<Timer> = null):Void {
        var filtred = cursedChannels.filter(e -> {return e.chanId == channelId;})[0];
        if (filtred == null) { 
            if (timer != null) {
                timer.stop();
            }   
            return;
        }
        Rgd.bot.endpoints.sendMessage(channelId, {embed: {title: 'канал проклят' ,image: {url: 'https://cdn.discordapp.com/attachments/474260428948635661/825346057037938718/tumblr_inline_p7g3m6yBzh1rfjsz3_500.gif'},footer: {text: 'есус помоги'}}}, (newMsg, err) -> {
            filtred.messages.push(newMsg.id.id);
        });
    }

    static  public function blessChannel(channelId:String):Void {
        var filtred = cursedChannels.filter(e -> {return e.chanId == channelId;})[0];
        if (filtred == null) { 
            return;
        }
        var messages = filtred.messages;
        var chanId = filtred.chanId;
        cursedChannels.remove(filtred);
        var timerDeleter = new Timer(1000);
        timerDeleter.run = () -> {
            trace(chanId);
            trace(messages);
            var msgId = messages.shift();
            Rgd.bot.endpoints.deleteMessage(chanId, msgId);
            if (messages.length == 0) {
                timerDeleter.stop();
            }
        } 
    }


    @command(["rnd", "ктв"], "Попытать удачу") 
    public static function rnd(m:Message, w:Array<String>) {
        if (rndUsed.contains(m.author.id.id)) {
            m.answer(m.author.tag + ' твое время еще не пришло');
            return;
        } else {
            rndUsed.push(m.author.id.id);
        }

        var mass = 0;
        for (elm in randFuncs) {
            mass += elm.w;
        }
        var r = mass * Math.random();
        var leftPoint = 0;
        for (elm in randFuncs) {
            if (leftPoint < r && r < leftPoint+elm.w) {
                elm.func(m, w);
                break;
            }
            leftPoint += elm.w;
        }
    }

    @down
    public static function down() {
        File.saveContent('data/cursed.json', Json.stringify(cursedChannels));
        File.saveContent('data/muted.json', Json.stringify(mutedUsers));
        File.saveContent('data/banRoad.json', Json.stringify(banRoad));
    }

    static function nothing(m:Message, w:Array<String>) {
        m.answer(m.author.tag + ' ничего не произошло, может оно и к лучшему');
    }

    static function moneyDrop(m:Message, w:Array<String>) {
        var coinRand = Std.random(500)+1;
        m.reply({embed: {description: '${m.author.tag} выдано $coinRand <:rgd_coin_rgd:745172019619823657>'}});
        m.reply({content: 'https://tenor.com/view/when-the-money-vince-mcmahon-big-chungus-wwe-gif-16018373'});
        Rgd.db.request('UPDATE users SET coins = coins + $coinRand WHERE userId = "${m.author.id.id}"');
    }

    static function rename(m:Message, w:Array<String>) {
        var _names = ["пук", "серь", "попущеный", "фыф", "линуксосер", "ахахахахаххаха", "амогус", "ඞ", "Нурсултан", "куколд", "кринж", "╲⎝⧹╲⎝⧹⎝⎠ ╲╱╲╱ ⎝⎠⧸⎠╱⧸⎠╱","⎝⎠⧸⎠╱⧸⎠╱╲⎝⧹╲⎝⧹⎝⎠", "卍", "卐", "☭",]; 
        var _randName = _names[Std.random(_names.length)];
        var renameTimer = new Timer(1000*3);
        renameTimer.run = () -> {
            m.getMember().changeNickname(_randName, (newName, err) -> {
                if (err == null) {
                    renamedUser.set(m.author.id.id, _randName);
                    renameTimer.stop();
                }
            });
        }
    }

    static function megatonncick(m:Message, w:Array<String>) {
        if (m.isOtec()) {
            return;
        }

        Rgd.bot.sendMessage(m.author.id.id, {content: "ты проиграл в лотерею и если тебя киукнуло то вот линк на возврат https://discord.gg/5kZhhWD"}, (newMessagem, err) -> {
            if (err != null) {
                return;
            }
            Rgd.bot.endpoints.kickMember(m.getGuild().id.id, m.author.id.id, "RND fucks");
        });
        m.answer(m.author.tag + ' проиграл в лотерею');
    }

    static function texastonncick(m:Message, w:Array<String>) {
        Rgd.bot.endpoints.kickMember(Rgd.rgdId, "288712351048400897","RND fucks", (wtf,err) -> {
            if (err == null) {
                m.answer("кикнуло техаса");
            } else {
                m.answer("кикнуло техаса, он еще тут");
            }
        });
    }

    static function mute(m:Message, w:Array<String>) {
        m.getMember().addRole("703031279670657024");
        m.getMember().addRole("521748931894444054");
        m.answer(m.author.tag + ' проглотил язык');
        mutedUsers.push(m.author.id.id);
    }

    static function nomoremod(m:Message, w:Array<String>) {
        if (m.getMember().hasRole("551145218259419146")) {
            m.getMember().removeRole("551145218259419146");
            m.answer(m.author.tag + ' больше не модер');
        } else {
            m.answer(m.author.tag + ' ты не модер');
        }
    }

    public static var mod15Arr:Array<String> = new Array();
    static function mod15(m:Message, w:Array<String>) {
        if (!m.getMember().hasRole("551145218259419146")) {
            mod15Arr.push(m.author.id.id);
            var modTimer = new Timer(1000*15);
            m.answer(m.author.tag + ' стал модером на 15 секунд');
            m.getMember().addRole("551145218259419146");
            modTimer.run = () -> {
                m.getMember().removeRole("551145218259419146", (d1, d2) -> {
                    if (d2 == null) {
                        mod15Arr.remove(m.author.id.id);
                        modTimer.stop();
                    }
                }); 
            }
        }
    }

    static function curse(m:Message, w:Array<String>) {
        if ((cursedChannels.filter(e -> {return e.chanId == m.channel_id.id;})[0] == null)) {
            m.answer("канал проклят, зовите есуса");
            cursedChannels.push({chanId: m.channel_id.id, messages: []});
            curseChannel(m.channel_id.id);
            var curseTimer = new Timer(1000*60*15);
            curseTimer.run = () -> {
                curseChannel(m.channel_id.id, curseTimer);
            }

            var blessMessage:(Message)->Void = null;
            var blessMessage = (blessMsg:Message) -> {
                if (blessMsg.channel_id.id != m.channel_id.id) return;
                if (blessMsg.content == "есус помоги") {
                    if (Math.random() > 0.5) {
                        blessMsg.answer('есус услышал вас');
                        blessChannel(m.channel_id.id);
                        OnMessage.messageOn.remove(blessMessage);
                    }
                }
            }
            OnMessage.messageOn.push(blessMessage);

        } else {
            m.answer("канал уже проклят, зовите есуса");
        }
    }

    static function gachibass(m:Message, w:Array<String>) {
        var gach:Array<String> = [
            'https://2ch.hk/char/src/476/15618433479090.mp4',
            'https://2ch.hk/char/src/476/15527497937610.mp4',
            'https://2ch.hk/char/src/476/15519060851662.mp4',
            'https://2ch.hk/char/src/476/15482332777990.mp4',
            'https://2ch.hk/char/src/476/15373763889660.webm',
            'https://2ch.hk/char/src/476/15028661871810.webm',
            'https://2ch.hk/char/src/476/14994556545010.webm',
            'https://2ch.hk/char/src/476/14994127382150.webm',
            'https://2ch.hk/char/src/476/14993675315100.webm',
            'https://2ch.hk/char/src/476/14993652634061.webm',
            'https://2ch.hk/char/src/476/14649597664090.webm',
            'https://2ch.hk/char/src/476/14649645663960.webm',
            'https://2ch.hk/char/src/476/14649663081980.webm',
            'https://2ch.hk/char/src/476/14649729756880.webm',
            'https://2ch.hk/char/src/476/14649729757481.webm',
            'https://2ch.hk/char/src/476/14649739790220.webm',
            'https://2ch.hk/char/src/476/14649768903560.webm',
            'https://2ch.hk/char/src/476/14649901954020.webm',
            'https://2ch.hk/char/src/476/14650195430400.webm',
            'https://2ch.hk/char/src/476/14652468186640.webm',
            'https://2ch.hk/char/src/476/14689513116241.webm',
            'https://2ch.hk/char/src/476/14705178277360.webm',
            'https://2ch.hk/char/src/476/14649600829600.webm',
            'https://2ch.hk/char/src/476/14713504866240.webm',
            'https://2ch.hk/char/src/476/14751622738360.webm',
            'https://2ch.hk/char/src/476/14765154168790.webm',
            'https://2ch.hk/char/src/476/14765154170771.webm',
            'https://2ch.hk/char/src/476/14765156144460.webm',
            'https://2ch.hk/char/src/476/14765156149533.webm',
            'https://2ch.hk/char/src/476/14869086988160.webm',
            'https://2ch.hk/char/src/476/14959035295250.webm',
            'https://2ch.hk/char/src/476/15482331954930.mp4',
            'https://2ch.hk/char/src/476/15307836354290.mp4',
        ];
        m.reply({content: 'boy next door ' + gach[Std.random(gach.length)]});
    }

    static function respect(m:Message, w:Array<String>) {
        m.answer(m.author.tag + ' стал немного уважаемее');
        Rgd.db.request('UPDATE users SET rep = rep + 1 WHERE userId = "${m.author.id.id}"');
    }

    static function anek(m:Message, w:Array<String>) {
        var anekReq = new sys.Http('http://anecdotica.ru/item/${Std.random(21800)+1}');
        anekReq.onData = (data:String) -> {
            var index1 = data.indexOf('class="item_text">');
            var index2  = data.indexOf('</div>', index1);
            var itog = data.substr(index1, index2 - index1);
            itog = StringTools.replace(itog, 'class="item_text">', '');
            itog = StringTools.replace(itog, '<br />', '');
            m.answer(itog);
        }
        anekReq.request();
    }


    static function pisi(m:Message, w:Array<String>) {
        var pisiReq = new sys.Http('http://placekitten.com/${200+Std.random(800)}/${200+Std.random(800)}');
        pisiReq.onBytes = (bytes:Bytes) -> {
            ImgBb.postImage(bytes, m.channel_id.id);
        }
        pisiReq.request();
    }
    

    static function noMoreAdmin(m:Message, w:Array<String>) {
        if (m.isOtec()) {
            return;
        }
        if (m.getMember().hasRole("504624668787998721")) {
            m.getMember().removeRole("504624668787998721");
            m.answer(m.author.tag + ' больше не админ');
        } else {
            m.answer(m.author.tag + ' ты не тот');
        }
    }


    
    static function roadToBan(m:Message, w:Array<String>) {    
        if (!banRoad.exists(m.author.id.id)) {
            banRoad[m.author.id.id] = 0;
        }

        banRoad[m.author.id.id]++;
       
        if (banRoad[m.author.id.id] == 4) {
            m.answer('${m.author.tag} был забанен на сутки(нет)');
            //Rgd.bot.endpoints.banMember(Rgd.rgdId, m.author.id.id, 0, 'RND FUCK');
            return;
        }

        var emb:Embed = {};
        emb.title = 'скоро бан';
        emb.footer = {
            text: '${banRoad[m.author.id.id]} из 3 до бана на сутки'
        };

    }


}