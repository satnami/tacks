package actors

import scala.concurrent.Future
import scala.concurrent.duration._
import scala.collection.mutable.ListBuffer
import play.api.Logger
import play.api.libs.concurrent.Akka
import play.api.libs.concurrent.Execution.Implicits._
import play.api.Play.current
import akka.actor.{Props, Terminated, ActorRef, Actor}
import akka.pattern.{ask,pipe}
import akka.util.Timeout
import org.joda.time.DateTime
import reactivemongo.bson.BSONObjectID
import models._


case class MountRace(race: Race, master: Player)
case class MountTimeTrialRun(timeTrial: TimeTrial, player: Player, run: TimeTrialRun)
case class MountTutorial(player: Player)
case class GetRace(raceId: BSONObjectID)
case class GetRaceActorRef(raceId: BSONObjectID)
case object GetOpenRaces

case class RaceActorNotFound(raceId: BSONObjectID)

class RacesSupervisor extends Actor {
  var mountedRaces = Seq[(Race, Player, ActorRef)]()
  var subscribers = Seq.empty[(Player, ActorRef)]

  implicit val timeout = Timeout(5.seconds)

  def receive = {

    case MountRace(race, master) => {
      val ref = context.actorOf(RaceActor.props(race, master))
      mountedRaces = mountedRaces :+ (race, master, ref)
      context.watch(ref)
      sender ! Unit
      master match {
        case u: User => RacesSupervisor.notifyNewRace(subscribers, race, u)
        case g: Guest =>
      }
    }

    case GetOpenRaces => {
      val racesFuture = mountedRaces.toSeq.map { case (race, master, ref) =>
        (ref ? GetStatus).mapTo[(Option[DateTime], Seq[PlayerState])].map { case (startTime, players) =>
          RaceStatus(race, master, startTime, players)
        }
      }
      Future.sequence(racesFuture) pipeTo sender
    }

    case GetRace(raceId) => sender ! getRace(raceId)

    case GetRaceActorRef(raceId) => sender ! getRaceActorRef(raceId)

    case Terminated(ref) => mountedRaces = mountedRaces.filterNot { case (_, _, r) => r == ref }

    case MountTimeTrialRun(timeTrial, player, run) => {
      val ref = context.actorOf(TimeTrialActor.props(timeTrial, player, run))
      context.watch(ref)
      sender ! ref
    }

    case MountTutorial(player) => {
      val ref = context.actorOf(TutorialActor.props(player))
      context.watch(ref)
      sender ! ref
    }

    case Subscribe(player, ref) => {
      subscribers = subscribers :+ (player, ref)
    }

    case Unsubscribe(player, ref) => {
      subscribers = subscribers.filterNot(_._2 == ref)
    }
  }

  def getRace(raceId: BSONObjectID): Option[Race] = mountedRaces.find(_._1.id == raceId).headOption.map(_._1)

  def getRaceActorRef(raceId: BSONObjectID): Option[ActorRef] = mountedRaces.find(_._1.id == raceId).map(_._3)
}

object RacesSupervisor {

  val actorRef = Akka.system.actorOf(Props[RacesSupervisor])

  def start() = {
//    Akka.system.scheduler.schedule(0.microsecond, 1.minutes, actorRef, CreateRace)
  }

  def notifyNewRace(subscribers: Seq[(Player, ActorRef)], race: Race, master: User) = {
    subscribers.filter(_._1.id != master.id).foreach { case (_, ref) =>
      ref ! NotificationEvent("newRace", Seq(race.generator, master.handle))
    }
  }

}
