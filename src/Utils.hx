import com.raidandfade.haxicord.types.Message;


class Utills {
    public static function answer(m:Message, text:String) {
        m.reply({embed: {description: text}});
    }   


    public static function isOtec(m:Message):Bool {
        return m.author.id.id == "371690693233737740";
    }


    public static function removeQuotes(txt:String):String {
        return StringTools.replace(txt, '"', '');
    }

}