import commands.SIgame;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Base64;
import sys.Http;

class ImgBb {
    static var key = InitData.imgDbKey;


    public static function postImageQuestion(qq:SiQuest) {
        var reqv = new Http("https://api.imgbb.com/1/upload");
        reqv.setParameter('key', key);
        reqv.setParameter('expiration', '15552000');

        var f = StringTools.urlEncode(qq.question[0]);
        var bytes = File.getBytes('siFiles/' + f);
        var encod = Base64.encode(bytes);
        reqv.setParameter('image', encod);

        reqv.onStatus = s -> {
            if (s != 200) {
                SIgame.askNext();
            }
        }

        reqv.onData = d -> {
            var responce:ImgBbResponce = Json.parse(d);
            var link = responce.data.display_url;


            Rgd.bot.sendMessage(Rgd.botChan, {
                embed: {
                    author: {
                        name: 'Категория: ${qq.theme}',
                        icon_url: "https://vladimirkhil.com/images/si.jpg",
                    },
                    image: {url: link},
                    footer: {
                        text: 'Цена вопроса: ${qq.price}',
                    }
                }
            });

        }

        reqv.request(true);
    }

}

typedef ImgBbResponce = {
    var data: {
        var id:String;
        var title:String;
        var url_viewer:String;
        var url:String;
        var display_url:String;
        var size:String;
        var time:String;
        var expiration:String;
        var image: {
            var filename:String;
            var name:String;
            var extension:String;
            var url:String;
        }

        var thumb: {
            var filename:String;
            var name:String;
            var mime:String;
            var extension:String;
            var url:String;
        }
        var medium: {
            var filename:String;
            var name:String;
            var mime:String;
            var extension:String;
            var url:String;
        }
        var delete_url:String;
    }
    var success:Bool;
    var status:Int;
}