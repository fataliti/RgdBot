package commands;


import neko.Utf8;
import haxe.Timer;
import haxe.Json;
import sys.FileSystem;
import haxe.Http;
import haxe.xml.Access;
import haxe.zip.Reader;
import haxe.io.BytesInput;
import sys.io.File;
import com.raidandfade.haxicord.types.Message;

@desc("SIgame","Модуль для задавания вопросов из своей игры в чат")
class SIgame {

    static var siQuests:Array<SiQuest> = new Array();
    static var quester:Timer;
    static var hinted:Array<Int> = [];



    @initialize
    public static function initialize() {
        if (FileSystem.exists("si.json")) {
            siQuests = Json.parse(File.getContent("si.json"));
            if (siQuests.length == 0) return;
            quester = new Timer(1000 * 60 * 60);
            quester.run = askNext;
        }
    }


    static function ask() {
        var qq = siQuests[0];

        switch (qq.type) {
            case 0:
                ImgBb.postImageQuestion(qq);
            case 1:
                Rgd.bot.sendMessage(Rgd.botChan, {
                    embed: {
                        author: {
                            name: 'Категория: ${qq.theme}',
                            icon_url: "https://vladimirkhil.com/images/si.jpg",
                        },
                        description: "**Вопрос:\n**" + qq.question.join('\n'),
                        footer: {
                            text: 'Цена вопроса: ${qq.price}',
                        }
                    }
                });
        }

        


    }

    static function siParse(m:Message, w:Array<String>) {  
        for (s in FileSystem.readDirectory("siFiles")) 
            FileSystem.deleteFile('siFiles/'+s);

        var packBytes = File.getBytes('pack.zip');
        var byteInput = new BytesInput(packBytes);
        var reader = Reader.readZip(byteInput);

        var newQuest:Array<SiQuest> = [];

        for(file in reader) {
            if (StringTools.endsWith(file.fileName, '.jpg') || StringTools.endsWith(file.fileName, '.JPG') ) {
                haxe.zip.Tools.uncompress(file);
                File.saveBytes('siFiles/${file.fileName.substr(file.fileName.lastIndexOf('/')+1)}', file.data);
            }

            if (file.fileName == 'content.xml') {
                haxe.zip.Tools.uncompress(file);
                var data = file.data.toString();
                
                var xml = Xml.parse(data);
                var acc = new Access(xml.firstElement());

                var rounds = acc.node.rounds;

                for (r in rounds.elements) {
                    trace(r.name + ' ' + r.att.name);

                    for(theme in r.node.themes.elements) {

                        for (q in theme.node.questions.nodes.question) {

                            var qq:SiQuest = {};
                            qq.theme = theme.att.name;
                            qq.price = q.att.price;
                            qq.answer = q.node.right.node.answer.innerData;

                            var s = q.node.scenario;
                            
                            var atoms:Array<String> = [];
                            var skip = false;

                            var atom = s.node.atom;
                            if (atom.has.type) {
                                if (atom.att.type == 'image') {
                                    atoms.push(atom.innerData.substr(1));
                                    qq.type = 0;
                                } else {
                                    skip = true;
                                }
                            } else {
                                qq.type = 1;
                                atoms.push(atom.innerData);
                            }

                            if (skip == true)
                                continue;

                            qq.question = atoms;
                            newQuest.push(qq);
                        }   
                    }
                }
            }

        }


        if (newQuest.length > 0) {
            Rgd.bot.sendMessage(m.channel_id.id, {
                embed: {
                    description: 'Загружен пак с `${newQuest.length}` вопросами и теперь он начнет спрашиваться'
                }
            });
            siQuests = newQuest;
            ask();

            if (quester != null) 
                quester.stop();
            quester = new Timer(1000 * 60 * 60);
            quester.run = askNext;
        } else {
            Rgd.bot.sendMessage(m.channel_id.id, {
                embed: {
                    description: 'В паке ни одного подходящего вопроса'
                }
            });
        }

    }


    @admin
    @command(['siLoad'], "Поставить пак на разыгровку", ">ссылка на пак")
    public static function siLoad(m:Message, w:Array<String>) {
        if (w[0] == null) {
            m.reply({content: 'не указана ссылка на пак'});
            return;
        } 

        var r = new Http(w[0]);
        r.onBytes = function (b) {
            File.saveBytes('pack.zip', b);
            siParse(m, w);
        }
        r.request();
    }

    @inbot
    @command(['siAnswer', 'si', 'a', 'си'], "Ответить на вопрос", ">ответ")
    public static function siAnswer(m:Message, w:Array<String>) {
        if (siQuests[0] == null) return;

        var ra = siQuests[0].answer.split(" ").filter(e -> e != " ");
        
        for (i in 0...ra.length) 
            ra[i] = toDownCase(ra[i]);

        for (i in 0...w.length) 
            w[i] = toDownCase(w[i]);
        
        

        var has = 0;

        for (word in w) { 
            if (ra.contains(word)) {
                has++;
                continue;
            }

            for(r in ra) {
                if (Lev.demarauLev(word, r) <= 1) {
                    has++;
                    break;
                }
            }

        }
        
        var percent = has / ra.length;

        var ans = siQuests[0].answer;
        var rew =  Math.floor(Std.parseFloat(siQuests[0].price) / 100);
        if (rew < 1)
            rew = 1;



        var miss = function () {
            if (hinted.length < Math.min(5, Utf8.length(ans))) {

                var hint = new Utf8();
                while (true) {
                    var r = Std.random(Utf8.length(ans));
                    if (!hinted.contains(r)) {
                        hinted.push(r);
                        break;
                    }
                }
                
                for (i in 0...Utf8.length(ans)) {
                    if (hinted.contains(i)) {
                        hint.addChar(Utf8.charCodeAt(ans, i));
                    } else {
                        hint.addChar((Utf8.charCodeAt(ans, i) == " ".code) ? " ".code : "*".code);
                    }
                }
                m.reply({content: 'Подсказка `${hint.toString()}`'});
            } else {
                askNext();
            }
        }



        
        if (percent < 0.1) {
            m.reply({embed: {description: '<@${m.author.id.id}>, абсолютно неверный ответ'}});
            miss();
        } else if (percent >= 0.1 && percent < 0.5) {
            m.reply({embed: {description: '<@${m.author.id.id}>, кажется близко к ответу'}});
            miss();
        } else if (percent >= 0.5 && percent < 0.75){
            m.reply({embed: {
                description: '<@${m.author.id.id}>, не совсем, но засчитывается',
                footer: {text: 'награда `$rew`'}
            }});
            Rgd.db.request('UPDATE users SET coins = coins + $rew WHERE userId = "${m.author.id.id}"');
            askNext();
        } else {
            m.reply({embed: {
                description: '<@${m.author.id.id}>, абсолютно верно',
                footer: {text: 'награда `$rew`'}
            }});
            Rgd.db.request('UPDATE users SET coins = coins + $rew WHERE userId = "${m.author.id.id}"');
            askNext();
        }



    }

    public static function askNext() {
        Rgd.bot.sendMessage(Rgd.botChan,{content: 'Следующий вопрос,а ответом на этот был `${siQuests[0].answer}`'});

        hinted = [];
        quester.stop();
        siQuests.shift();

        if (siQuests.length > 0) {
            ask();
            quester = new Timer(1000 * 60 * 60);
            quester.run = askNext;
        } else {
            Rgd.bot.sendMessage(Rgd.botChan, {
                embed: {
                    description: 'Вопросы пака закончились, ставьте следующий'
                }
            });
        }
    }

    @inbot
    @command(['siNext', 'skip', 's', 'next', 'с', 'дальше'], "Пропуск вопроса")
    public static function siNext(m:Message, w:Array<String>) {
        if (siQuests.length > 0) {
            askNext();
        }
    }

    @inbot
    @admin
    @command(['siNextCat', 'skipCat', 'категорияГовно', 'ск'], "Пропуск категории")
    public static function siNextCat(m:Message, w:Array<String>) {
        if (siQuests.length > 0) {
            var theme = siQuests[0].theme;
            for (q in siQuests) {
                if (q.theme != theme) {
                    break;
                }
                siQuests.shift();
            }
            askNext();
        }
    }

    @down
    public static function down() {
        File.saveContent('si.json', Json.stringify(siQuests));
    }

    static function toDownCase(str:String):String {
        str = str.toLowerCase();
        
        var up = ["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х", "Ъ", "Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э", "Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю", "Ё"];
        var dw = ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ", "ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "ё"];
        var tr = ['`', '!', '@', '$', '$', '%', '^', '&', '*', '-', '+', '[', ']', '\\', "'", '"', '|', '<', '>', ',', '.', '?', '(', ')', '«', '»'];
        var s = '';

        var iter = StringTools.iterator(str);

        while (iter.hasNext()) {
            var n = String.fromCharCode(iter.next());
            if (tr.contains(n)) {
                n = " ";
            }
            s += n;
        }
        for (i in 0...up.length) {
            s = StringTools.replace(s, up[i], dw[i]);
        }
        return s;
    }

}


typedef SiQuest = {
    var ?theme:String;
    var ?question:Array<String>;
    var ?type:Int;
    var ?answer:String;
    var ?price:String;
}



