

class RndTest {
    static function main() {
        var arr:Array<{f:() -> Void, c:Int}> = new Array();
        var m:Map<Int, Int> = new Map();

        for (i in 1...9) {
            m[i] = 0;
        }

        arr.push({f:() -> m[1]++, c: 1});
        arr.push({f:() -> m[2]++, c: 2});
        arr.push({f:() -> m[3]++, c: 3});
        arr.push({f:() -> m[4]++, c: 4});
        arr.push({f:() -> m[5]++, c: 5});
        arr.push({f:() -> m[6]++, c: 6});
        arr.push({f:() -> m[7]++, c: 7});
        arr.push({f:() -> m[8]++, c: 8});

        var sum = 0; 
        for (func in arr) {
            sum += func.c;
        }
        

        var r = 0;
        while (r < 10000) {
            var rand = Std.random(sum);
            for (func in arr) {
                if (func.c < rand) {
                    func.f();
                    break;
                } else {
                    rand -= func.c;
                }
            }
            ++r;
        }

        for (index => value in m) {
            trace('$index : $value');
        }

    }
}