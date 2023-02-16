class Leaderboard {
    private static var leaderboard = new Array<Int>();
    private static var result:String;

    public static inline function IsEmpty() return leaderboard == null || leaderboard.length <= 0;

    public static function GetHighscores(numBest:Int):String
    {
        result = "";
        
        if(leaderboard != null && leaderboard.length > 0)
        {
            result = "> Highscores: ";

            var idx:Int;
            for(i in 0...numBest)
            {
                idx = leaderboard.length - i - 1;
                if(idx < 0)
                    break;

                result += leaderboard[idx];
                
                if(idx - 1 >= 0 && i + 1 < numBest)
                    result += " | ";
            }
            result += "\n\n";
        }


        return result;
    }

    public static function PushScore(score:Int)
    {
        leaderboard.push(score);
        leaderboard.sort(Reflect.compare);
    }
}