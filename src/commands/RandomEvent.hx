package commands;

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

        var r = Math.random() * 150;
        trace('random event $r');

        if (r >= 30  && r < 50) {
            m.answer(m.author.tag + ' ничего не произошло, может оно и к лучшему');
            return;
        }

        if (r >= 50 && r < 60) {
            var _names = ["пук", "серь", "попущеный", "фыф", "линуксосер", "ахахахахаххаха", "амогус", "Нурсултан"];
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
            return;
        }
        if (rndUsed.contains(m.author.id.id)) {
            m.answer(m.author.tag + ' твое время еще не пришло');
            return;
        }
        rndUsed.push(m.author.id.id);
        

        if (r < 15) {
            //m.mentions = [m.author];
            //Coin.award(m, ["", Std.string(Std.random(500)+1)]);
            var coinRand = Std.random(500)+1;
            m.reply({embed: {image: {url: 'https://media.tenor.co/videos/91963205e59359bb25336c03029362bb/mp4'}, description: '${m.author.tag} выдано $coinRand <:rgd_coin_rgd:745172019619823657>'}});
            Rgd.db.request('UPDATE users SET coins = coins + $coinRand WHERE userId = "${m.author.id.id}"');
            return;
        }

        if (r >= 15 && r < 30) {
            Rgd.bot.sendMessage(m.author.id.id, {content: "ты проиграл в лотерею и если тебя киукнуло то вот линк на возврат https://discord.gg/5kZhhWD"}, (newMessagem, err) -> {
                if (err != null) {
                    return;
                }
                Rgd.bot.endpoints.kickMember(m.getGuild().id.id, m.author.id.id, "RND fucks");
            });
            
            m.answer(m.author.tag + ' проиграл в лотерею');
            return;
        }

        if (r >= 60 && r < 61) {
            Rgd.bot.endpoints.kickMember(Rgd.rgdId, "288712351048400897","RND fucks", (wtf,err) -> {
                if (err == null) {
                    m.answer("кикнуло техаса");
                } else {
                    m.answer("кикнуло техаса, он еще тут");
                }
            });
            return;
        }

        if (r >= 65 && r < 75) {
            m.getMember().addRole("703031279670657024");
            m.getMember().addRole("521748931894444054");
            m.answer(m.author.tag + ' проглотил язык');
            mutedUsers.push(m.author.id.id);
            return;
        }

        if (r >= 75 && r < 85) {
            if (m.getMember().hasRole("551145218259419146")) {
                m.getMember().removeRole("551145218259419146");
                m.answer(m.author.tag + ' больше не модер');
            }
            return;
        }

        if (r >= 85 && r < 86) {
            if (!m.getMember().hasRole("551145218259419146")) {
                var modTimer = new Timer(1000*15);
                m.answer(m.author.tag + ' стал модером на 15 секунд');
                m.getMember().addRole("551145218259419146");
                modTimer.run = () -> {
                    m.getMember().removeRole("551145218259419146", (d1, d2) -> {
                        if (d2 == null) {
                            modTimer.stop();
                        }
                    }); 
                }
            }
            return;
        }


        if (r >= 86 && r < 91) {
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
                        if (Math.random() > 0.9) {
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
            return;
        }

        if (r >= 100 && r < 115) {
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
            ];
            m.reply({content: 'boy next door ' + gach[Std.random(gach.length)]});
            return;
        }
        if (r>=115 && r < 130) {
            var anekReq = new sys.Http('http://rzhunemogu.ru/RandJSON.aspx?CType=1');
            anekReq.onData = (data:String) -> {
                var anekdot:{?content:String} = Json.parse(data);
                var emb:Embed = {}; 
                emb.color = 0xFF9900;
                emb.title = 'Анекдот';
                emb.description = anekdot.content;
                m.reply({embed: emb});
                trace(data);
            }
            anekReq.request();
            return;
        }

        if (r >= 130 && r < 140) {
            m.answer(m.author.tag + ' стал немного уважаемее');
            Rgd.db.request('UPDATE users SET rep = rep + 1 WHERE userId = "${m.author.id.id}"');
            return;
        }
        m.answer('вышел процент в ничто');

    }

    @down
    public static function down() {
        File.saveContent('data/cursed.json', Json.stringify(cursedChannels));
        File.saveContent('data/muted.json', Json.stringify(mutedUsers));
    }

    @command(["anek"], "анекдот")
    public static function anek(m:Message, w:Array<String>) {


        var pid = 'pid=E461GA80B6&method=getRandItemP&format=json&charset=utf-8&uts=${Std.string(Date.now().getTime())}';
        var md5 = Md5.encode(pid);
        
        var anekReq = new sys.Http('http://anecdotica.ru/api?$pid&hash=$md5');
        // anekReq.setParameter('pid','E461GA80B6');
        // anekReq.setParameter('method', 'getRandItemP');
        // anekReq.setParameter('format', 'json');
        // anekReq.setParameter('charset', 'utf-8');
        // anekReq.setParameter('uts', Std.string(Date.now().getTime()));
        // anekReq.setParameter('md5','');
        
        anekReq.onData = (data:String) -> {
            trace(data);
            //var anekXml = Xml.parse(data);
            //var emb:Embed = {}; 
            //emb.color = 0xFF9900;
            //emb.title = 'Анекдот';
            //emb.description = data;
            //m.reply({embed: emb});
        }
        anekReq.request();
    }

}