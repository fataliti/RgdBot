package events;

import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Guild;

class OnMemberLeave {

    static var phrases =  [
        "% вышел с сервера, а он ему как раз.",
        "% вышел с сервера, press F to пошёл нахуй.",
        "% укатился за горизонт.",
        "% теперь в лучшем мире.",
        "% навечно ливнул (но это не точно)",
        "% упердел на бугуртовой тяге.",
        "% смог, а ты всё сидишь тут.",
        "% теперь наблюдает за нами с небес.",
        "% больше не сможет сраться во флудилке.",
        "% наконец перестал всех раздражать своим мерзким голосом.",
        "% вышел с сервера, а никто и не заметил.",
        "% покинул сервер. Всем плакать 15 минут.",
        "% всё.",
        "% ливнул. Ну ливнул и ливнул.",
        "% убежал на радугу.",
        "% больше не сможет пукать подмышкой в войс-чате.",
        "% сдался.",
        "% пересел на более лёгкие наркотики.",
        "% ушёл. Можно больше не открывать форточку.",
        "% не смог поднять русский геймдев с колен.",
        "% больше не будет вам докучать.",
        "% шышел-мышел, с сервера вышел.",
        "% обнулился.",
        "% решил жить исключительно ИРЛ.",
        "% вылетел за борт.",
        "% слишком долго смотрел в бездну.",
        "% оказался слишком слаб.",
        "% просил передать, что ненавидит вас.",
        "% просил передать, что будет скучать.",
        "% решил не садиться на стул с пиками.",
        "% вернул себе 2007.",
        "% вышел на крыльцо.",
        "% больше не вернётся.",
        "% возможно вернётся.",
        "% роскомнадзорнулся. Разойдитесь, здесь не на что смотреть.",
        "% когда-нибудь станет успешным и богатым, но это уже совсем другая история.",
        "% ушел жить в коробке из-под холодильника.",
        "% решил, что с него хватит.",
        "% пукнул в последний раз.",
        "% хотя бы ливнул. Дядя Женя не сделал и этого.",
        "% ушёл по-английски.",
        "% ушёл по-пидорски.",
        "% кончился.",
        "% вышел с сервера. Вы рады? Вы этого добивались? Что вы за люди вообще? Да вы не люди, вы - животные. Тьфу, мне противно смотреть на вас, выродки. К любому человеку можно найти подход, любого можно удержать, с любым можно найти общий язык. Фу нахуй, токсики, убейтесь.",
        "% поматросил и вышел с сервера.",
        "% не оплатил интернет.",
        "% - помним, любим, скорбим.",
        "% ушёл в люди.",
        "% сдуло нахуй.",
        "% и от бабушки ушёл, и от волка ушёл, и от Жени ушёл.",
        "% устал кринжевать от Дани",
        "% наматался на вал",
        "% решил что на заводе будет лучше",
        "% попустился",
        "% ушел в армию",
        "% сел в тюрьму",
        "% попил таблеток",
        "% вышел за сигаретами",
        "% наелся и спит",
        "% увидел гуся",
    ];

    public static function onMemberLeave(g:Guild, u:User) {
        if (g.id.id != Rgd.rgdId) return;
        Rgd.db.request('UPDATE users SET here = 0 WHERE userId = ${u.id.id}');
        Rgd.db.request('UPDATE users SET leave = leave + 1 WHERE userId = ${u.id.id}');

        if (u.username == null) {
            Rgd.bot.getUser(u.id.id, user -> {
                Rgd.bot.sendMessage(Rgd.msgChan, {content: StringTools.replace(phrases[Std.random(phrases.length)], "%", '${user.username} [<@${user.id.id}>]')});
            });
        } else {
            Rgd.bot.sendMessage(Rgd.msgChan, {content: StringTools.replace(phrases[Std.random(phrases.length)], "%", '${u.username} [<@${u.id.id}>]')});
        } 
    }
}