package commands;

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


    @down
    public static function down() {
        File.saveContent('data/status.json', Json.stringify(botStatus));
    }
}

typedef BotStatus = {
    ?title:String,
}