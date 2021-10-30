package commands;

import haxe.Int64;
import com.raidandfade.haxicord.types.structs.Embed;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.Timer;
import com.raidandfade.haxicord.types.Message;

using Utils;

@admin
@desc('Control', 'Модуль с командами для контроля')
class Control {

    public static var gusSasiArray:Array<String> = new Array();
    static var botStatus:BotStatus = null;

    static var timeOutTimers:Array<{userId:String, timer:Timer, timeEnd:Float}> = [];
    static var banTimers:Array<{userId:String, timer:Timer, timeEnd:Float}> = [];

    @initialize
    public static function initialize() {
        Rgd.db.request('
        CREATE TABLE IF NOT EXISTS "gusSasi" (
            "userId" TEXT PRIMARY KEY
        )');
        var gusesos = Rgd.db.request("SELECT userId FROM gusSasi");
        for (u in gusesos) {
            gusSasiArray.push(u.userId);
        }

        Rgd.db.request('
        CREATE TABLE IF NOT EXISTS "unban" (
            "userId" TEXT PRIMARY KEY
        )');

        
        if (FileSystem.exists('data/status.json')) {

            var content = File.getContent('data/status.json');
            if (content != "null") {
            
                botStatus = Json.parse(content);
                Rgd.bot.setStatus({
                    afk: false,
                    status: 'online',
                    game: {
                        type: 0,
                        name: botStatus.title,
                    }
                });
            }
        }
        

        if (FileSystem.exists('data/timeout.json')) {
            var content = File.getContent('data/timeout.json');
            var timeOutLoadStruct:Array<TimeOutSave> = Json.parse(content);

            
            for (timeOutLoad in timeOutLoadStruct) {
                var whenTimerEnd = Std.int(timeOutLoad.whenEnd - Date.now().getTime());
                
                if (whenTimerEnd < 10000) {
                    whenTimerEnd = 10000;
                }
                Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMember(timeOutLoad.userId, _member -> {
                    var timer = new Timer(whenTimerEnd);

                    var timeOutInstance = {
                        userId: timeOutLoad.userId,
                        timer: timer,
                        timeEnd: cast whenTimerEnd
                    };
                    timer.run = () -> {
                        _member.removeRole("703031279670657024");
                        _member.removeRole("521748931894444054");
                        timeOutTimers.remove(timeOutInstance);
                        timer.stop();
                    }
                    timeOutTimers.push(timeOutInstance);
                });
            }
        }


        if (FileSystem.exists('data/bans.json')) {
            var content = File.getContent('data/bans.json');
            var bansLoadStruct:Array<TimeOutSave> = Json.parse(content);

            for (banLoad in bansLoadStruct) {
                var whenTimerEnd = Std.int(banLoad.whenEnd - Date.now().getTime());
                
                if (whenTimerEnd < 10000) {
                    whenTimerEnd = 10000;
                }
                
                var timer = new Timer(whenTimerEnd);

                var banTimer = {
                    userId: banLoad.userId,
                    timer: timer,
                    timeEnd: cast whenTimerEnd
                };
                timer.run = () -> {
                    Rgd.bot.endpoints.unbanMember(Rgd.rgdId, banLoad.userId, "Time is out");
                    banTimers.remove(banTimer);
                    timer.stop();
                }
                banTimers.push(banTimer);
            }
        }


    }   

    @admin
    @command(["gusSasi"], "Добавить админа который не может юзать админские команды", ">ping")
    public static function gusSasi(m:Message, w:Array<String>) {
        if (m.author.id.id != '371690693233737740') return;
        var u = m.mentions[0];
        if (u == null) {
            m.reply({content: 'забыл упомянуть'});
            return;
        }
        gusSasiArray.push(u.id.id);
        Rgd.db.request('INSERT INTO gusSasi(userId) VALUES("${u.id.id}")');
        m.reply({embed: {description: u.tag + ' был добавлен в список пососов'}});
    }

    @admin
    @command(['статус', 'status'], 'установить статус боту', '>фраза для статуса')
    public static function setStatus(m:Message, w:Array<String>) {
        botStatus = {title: w.join(' ')}
        Rgd.bot.setStatus({
            afk: false,
            status: 'online',
            game: {
                type: 0,
                name: botStatus.title,
            }
        });
    }

    @admin
    @command(['purge', 'пурж'],  'удалить некоторое колличество сообщений из чата', '>число сообщений ?отправитель')
    public static function purge(m:Message, w:Array<String>) {
        if (w[0] == null) {
            m.reply({content: 'не указано число удаляемых сообщения'});
            return;
        } 
        var cnt = Std.parseInt(w[0]);
        if (cnt == null) {
            m.reply({content: 'не указано число удаляемых сообщения'});
            return;
        }
        if (cnt <= 0 || cnt > 100) {
            m.reply({content: 'не подходящее число'});
            return;
        }

        var user = m.mentions[0];

        m.getChannel().getMessages(null,(msgs, err) -> {
            if (err != null) {
                return;
            }

            var iter = 0;
            var purger = new Timer(1000);

            if (user == null) {
                purger.run = () -> {
                    if (msgs[iter] == null) {
                        purger.stop();
                        return;
                    }
                    msgs[iter].delete();
                    if (++iter > cnt) {
                        purger.stop();
                    }
                }
            } else {
                purger.run = () -> {
                    while (msgs[iter] != null && msgs[iter].author.id.id != user.id.id) {
                        ++iter;
                    }
                    if (msgs[iter] == null) {
                        purger.stop();
                        return;
                    }
                    msgs[iter].delete();
                    if (++iter > cnt) {
                        purger.stop();
                    }
                }
            }

        });
    }

    @admin
    @command(["purgeto"], "Сделать пурж до определенного сообщения", ">id сообщения")
    public static function purgeto(m:Message, w:Array<String>) {
        if (w[0] == null) {
            m.answer('нет айди сообщения');
            return;
        }
        m.getChannel().getMessages(null, (arr, err) -> {
            if (err != null) {
                return;
            }
            var targetMsg = arr.filter( e-> {
                return e.id.id == w[0];
            })[0];
            if (targetMsg == null) {
                return;
            }
            m.mentions = [];
            purge(m, [Std.string(arr.indexOf(targetMsg) + 1)]);
        });
    }

    @command(["rename", "rn"], "переименовать кого-то", ">пинг >имя")
    public static function renameUser(m:Message, w:Array<String>) {


        var usr = m.mentions[0];
        if (usr == null) {
            m.answer("нет пинга");
            return;
        }
        if (usr.id.id == "538623912016216077") return;


        if (w[1] == null) {
            m.answer("нет переименования");
            return;
        }
        w.shift();
        Rgd.bot.endpoints.editGuildMember(Rgd.rgdId, usr.id.id, {nick: w.join(' ')});
    }
    
    @command(["renamev", "rnv"], "переименовать войс канал", ">id канала >имя")
    public static function renameVoice(m:Message, w:Array<String>) {
        if (w[1] == null) {
            m.answer("нет переименования");
            return;
        }
        var ch = w.shift();
        if (ch == null) {
            m.answer('нет айди канала');
            return;
        }
        if (!Rgd.bot.getGuildUnsafe(Rgd.rgdId).voiceChannels.exists(ch)) {
            m.answer('или такого канала нет или это не войс канал');
            return;
        }
        Rgd.bot.getGuildUnsafe(Rgd.rgdId).voiceChannels[ch].editChannel({name: w.join(' ')});
    }


    @command(['grole'], 'выдать роль кому-то', '>ping >pingrole')
    public static function grole(m:Message, w:Array<String>) {
        if (!m.isOtec())  return;
        m.getGuild().members[m.mentions[0].id.id].addRole(m.mention_roles[0].id.id);
    }

    @command(['drole'], 'забрать роль у кого-то', '>ping >pingrole')
    public static function drole(m:Message, w:Array<String>) {
        if (!m.isOtec())  return;
        m.getGuild().members[m.mentions[0].id.id].removeRole(m.mention_roles[0].id.id);
    }

    @command(['megaban'], 'забанить кого-то', '>ping ')
    public static function banban(m:Message, w:Array<String>) {
        if (!m.isOtec())  return;
        m.getGuild().members[m.mentions[0].id.id].ban();
    }



    @admin
    @command(['goc'], 'игра сообщества', '>attachfile')
    public static function goc(m:Message, w:Array<String>) {
        var atachFile = m.attachments[0];
        if (atachFile == null) {
            gocPost(w);
        } else {
            gocFile(m);
        }
    }


    @admin
    @command(['timeout', 'таймаут', 'мут', 'mute', 'm'], 'временный мут', '>ping >часов')
    public static function timeout(m:Message,w:Array<String>) {
        var user = m.mentions[ 0];
        if (user == null) {
            m.answer('нет упоминания пользователя');
            return;
        }

        var hoursInText = w[1];
        if (hoursInText == null) {
            m.answer('не указана длительность');
            return;
        }

        var hours = Std.parseFloat( hoursInText);

        if (Math.isNaN(hours)) {
            m.answer('неправильно указана длительность');
            return;
        }

        var dateEnd = DateTools.delta(Date.now(), Std.int(1000 * 60 * 60 * hours));
        var whenTimerEnd = dateEnd.getTime();
        
        var member = Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMemberUnsafe(user.id.id);
        if (member == null) {
            m.answer('член не захэширован');
            Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMember(user.id.id, (_member) -> {});
            return;
        }        

        member.addRole("703031279670657024");
        member.addRole("521748931894444054");
        var timer = new Timer(Std.int(whenTimerEnd - Date.now().getTime()));

        var timeOutInstance = {
            userId: user.id.id,
            timer: timer,
            timeEnd: whenTimerEnd
        };

        timer.run = () -> {
            member.removeRole("703031279670657024");
            member.removeRole("521748931894444054");
            timeOutTimers.remove(timeOutInstance);
            timer.stop();

        }
        
        timeOutTimers.push(timeOutInstance);
        m.answer(user.tag + ' получил мут на ${Math.round(60*hours)} минут');
    }

    @admin
    @command(['ban'], 'временный бан', '>ping >часов')
    public static function ban(m:Message,w:Array<String>) {
        var user = m.mentions[ 0];
        if (user == null) {
            m.answer('нет упоминания пользователя');
            return;
        }
        
        if (user.id.id == "371690693233737740") {
            m.answer("соси");
            return;
        }

        var hoursInText = w[1];
        if (hoursInText == null) {
            m.answer('не указана длительность');
            return;
        }

        var hours = Std.parseFloat( hoursInText);

        if (Math.isNaN(hours)) {
            m.answer('неправильно указана длительность');
            return;
        }

        var dateEnd = DateTools.delta(Date.now(), Std.int(1000 * 60 * 60 * hours));
        var whenTimerEnd = dateEnd.getTime();
        
        var member = Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMemberUnsafe(user.id.id);
        if (member == null) {
            m.answer('член не захэширован');
            Rgd.bot.getGuildUnsafe(Rgd.rgdId).getMember(user.id.id, (_member) -> {});
            return;
        }        

        member.ban();
        var timer = new Timer(Std.int(whenTimerEnd - Date.now().getTime()));

        var banInstance = {
            userId: user.id.id,
            timer: timer,
            timeEnd: whenTimerEnd
        };

        timer.run = () -> {
            Rgd.bot.endpoints.unbanMember(Rgd.rgdId, user.id.id, "time is over");
            banTimers.remove(banInstance);
            timer.stop();
        }
        
        banTimers.push(banInstance);
        m.answer(user.tag + ' получил бан на ${Math.round(60*hours)} минут');
    }


    static function gocFile(m:Message) {
        var loadFile = new sys.Http(m.attachments[0].url);
        loadFile.onBytes = function (b) {
            gocPost([b.toString()]);
        }
        loadFile.request();
    }

    public static function gocPost(w:Array<String>) {
        trace("goc post call");


        var jsonString = w.join(" ");
        var proj:Project = Json.parse(jsonString);

        trace(proj);
        trace(proj.author);
        trace(proj.cost);
        trace(proj.name);

        var platformImages:Map<String, {img:String, name:String}> = [
            'steam' => {img:'https://cdn.discordapp.com/attachments/854576129679556618/854576143423635476/512px-Steam_icon_logo.png', name: 'Steam'},
            'gp' =>  {img:'https://cdn.discordapp.com/attachments/854576129679556618/854576281340215356/google_play.png', name: 'PlayMarker'},
            'itch' => {img:'https://cdn.discordapp.com/attachments/854576129679556618/854576200944320512/app-icon.png', name: 'Itch'},
            'apple' => {img:'https://cdn.discordapp.com/attachments/854576129679556618/854576544789430272/Apple_Store-512.png', name: 'AppStore'},
            'nintendo' => {img:'https://cdn.discordapp.com/attachments/854576129679556618/854576358651199498/1200px-NintendoSwitchLogo.png', name: 'Nintendo'},
        ];

        var postProj = function(?link:String) {
            var emb:Embed = {};

            var authors = proj.author.split(' ').filter(e -> return e.length > 0);
            var tags = '';
            for (s in authors) {
                tags += '<@$s> ';
            }

            emb = {
                description: '**Цена:** ${proj.cost}\n**Жанр:** ${proj.genre}\n**Авторы:** ${tags}\n\n${proj.description}',
                author: {name: proj.name},
                color: Std.parseInt(StringTools.replace(proj.color, '#', '0x')),
                fields: [],
            }

            if (proj.platforms.length != 0) {

                emb.thumbnail = {
                    url: platformImages.get(proj.platforms[0].platform).img
                }

                if (proj.platforms.length > 1) {
                    for (platform in proj.platforms) {
                        emb.fields.push({
                            name: platformImages.get(platform.platform).name,
                            value: '[клик](${platform.link})',
                            _inline: true,
                        });
                    }
                } else {
                    emb.description += '\n\n[**ПЕРЕЙТИ В МАГАЗИН**](${proj.platforms[0].link})';
                }
            
            }

            if (link != null) {
                emb.image = {
                    url: link,
                }
            }

            Rgd.bot.endpoints.sendMessage("560442708561362946", {
                embed: emb,
            }); 
        }

        if (proj.picture != null) {
            ImgBb.uploadImage(proj.picture, link -> {
                postProj(link);
            });
        } else {
            postProj();
        }
        
    }


    


    @down
    public static function down() {
        File.saveContent('data/status.json', Json.stringify(botStatus));

        var timeOutSaveStruct:Array<TimeOutSave> = [];
        for (timeoutTimer in timeOutTimers) {
            timeOutSaveStruct.push({
                userId: timeoutTimer.userId,
                whenEnd: cast timeoutTimer.timeEnd
            });
        }
        File.saveContent('data/timeout.json', Json.stringify(timeOutSaveStruct));


        var banSaveStructr:Array<TimeOutSave> = [];
        for (banTimer in banTimers) {
            banSaveStructr.push({
                userId: banTimer.userId,
                whenEnd: cast banTimer.timeEnd
            });
        }
        File.saveContent('data/bans.json', Json.stringify(banSaveStructr));

    }



}

typedef BotStatus = {
    ?title:String,
}


typedef Project = {
    ?author:String,
    ?name:String,
    ?cost:String,
    ?genre:String,
    ?platforms:Array<{
        platform:String,
        link:String
    }>,
    ?description:String,
    ?picture:String,
    ?color:String,
}


typedef TimeOutSave ={
    userId:String,
    whenEnd:Float
} 