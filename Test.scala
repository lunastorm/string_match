import scala.util.matching.Regex
import scala.actors.Actor
import scala.actors.Actor._

case object Stop

class Matcher(reg: Regex) extends Actor{
  def act() {
    loop{
      react {
        case Stop =>
          exit()
        case msg => 
          msg match {
            case reg() =>{
              print(msg)
              print("matches")
              println(reg)
            }
            case _ =>
          }
      }
    }
  }
}

object Test{
  def main(args: Array[String]){
    var matchers = List[Matcher]()
    for(ln <- io.Source.fromFile("../../akame/patterns").getLines){
      var matcher = new Matcher(new Regex(ln))
      matcher.start
      matchers ::= matcher
    }
    for(ln <- io.Source.stdin.getLines ) {
      for(matcher <- matchers){
        matcher ! ln
      }
    }
    for(matcher <- matchers){
      matcher ! Stop
    }
  }
}

