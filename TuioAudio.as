package 
{
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.sources.SineSource;
	import org.tuio.*;
	import org.tuio.osc.*;
	import org.tuio.connectors.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.geom.Point;

	/*This is an audio manipulator meant to work with the iPhone's TUIOpad app.
	@author Cody Hard*/

	public class TuioAudio extends MovieClip implements ITuioListener
	{
		public var tuio:TuioClient;
		public var currentCircle:Circle;
		public var oneCircle:Circle;
		public var twoCircle:Circle;
		public var oneX, oneY, twoX, twoY:Number;
		public var onePt, twoPt:Point;
		public var aSource:SineSource;
		public var player:AudioPlayer;
		public var descript:AudioDescriptor;
		public var touch:Boolean;
		public var back_btn, try_btn, trouble_btn, success_btn:SimpleButton;

		public function TuioAudio()
		{
			trace("Function TuioAudio called.");
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		//initialization function
		private function init(e:Event=null):void
		{
			stop();
			trace("Function init called.");
			connector = new TCPConnector();
			tuio = new TuioClient(connector);
			this.tuio.addListener(this);
			oneX = new Number;
			oneY = new Number;
			twoX = new Number;
			twoY = new Number;
			onePt = new Point;
			twoPt = new Point;
			descript = new AudioDescriptor;
			aSource = null;
			player = new AudioPlayer;
			//back_btn=stage.back_btn;
			back_btn.addEventListener(MouseEvent.CLICK, clickButton);
			try_btn.addEventListener(MouseEvent.CLICK, clickButton);
			trouble_btn.addEventListener(MouseEvent.CLICK, clickButton);
			success_txt.visible=false;
			trouble_btn.visible=false;
			try_btn.visible=false;
			error_txt.visible=false;
			touch=false;
			trace(connector.connection.connected);
			getFrame();
		}
		//functions for button clicks
		public function clickButton(e:MouseEvent):void
		{
			if(e.currentTarget==back_btn||e.currentTarget==try_btn){
				gotoAndStop(1);
				success_txt.visible=false;
				trouble_btn.visible=false;
				try_btn.visible=false;
				error_txt.visible=false;
				getFrame();
			}
			if(e.currentTarget==trouble_btn)
			{
				gotoAndStop(2);
			}
		}
		//checks connection
		public function getFrame()
		{
			if(currentFrame == 1)
			{
				if(connector.connection.connected==false)
				{
					status_txt.visible=false;
					error_txt.visible=true;
					try_btn.visible=true;
					trouble_btn.visible=true;
				}
				else
				{
					status_txt.visible=false;
					success_txt.visible=true;
				}
			}
		}

		//Returns the distance between 2 points
		public static function distance(pt1,pt2)
		{
			var dist,dx,dy:Number;
			dx = pt2.x - pt1.x;
			dy = pt2.y - pt1.y;
			dist = Math.sqrt(dx * dx + dy * dy);
			//trace("Distance: " + dist);
			return dist;
		}

		//send it two points and it will give you the angle in degrees
		public static function getAngle(pt1:Point,pt2:Point):Number
		{
			var theX:Number = (pt1.x*100) - (pt2.x*100);
			var theY:Number = (pt1.y*100) - (pt2.y*100);
			trace(pt1.x + " " + pt1.y+ "   "+pt2.x+" "+pt2.y);
			trace(theX +" "+theY);
			if (theX == 0 && theY == 0)
			{//if we are dividing by by zero!
				return 0;
			}
			else
			{
				var angle = theY / theX // Math.PI / 180;
				if (theX < 0)
				{
					angle +=  180;
				}
				if (theX >= 0 && theY < 0)
				{
					angle +=  360;
				}
				trace("Angle " + angle);
				return angle * -1 + 90;
			}
		}

		//TuioCursor functions
		public function addTuioCursor(tuioCursor:TuioCursor):void
		{
			if(touch==false)
			{
				touch=true;
				gotoAndStop(3);
				oneCircle = new Circle(tuioCursor.sessionID.toString(),stage,tuioCursor.x * stage.stageWidth,tuioCursor.y * stage.stageHeight,10,0xee3333);
			}
			//if first one, assign to circleOne. if second, assign to twoCircle.
			else if (oneCircle == null)
			{
				oneCircle = new Circle(tuioCursor.sessionID.toString(),stage,tuioCursor.x * stage.stageWidth,tuioCursor.y * stage.stageHeight,10,0xee3333);
				oneX = tuioCursor.x;
				oneY = tuioCursor.y;
				onePt.x = oneX*stage.stageWidth;
				onePt.y = oneY*stage.stageHeight;
			}
			else /*if (twoCircle == null)*/ //uncomment for sole two-finger support
			{
				twoCircle = new Circle(tuioCursor.sessionID.toString(),stage,tuioCursor.x * stage.stageWidth,tuioCursor.y * stage.stageHeight,10,0xee3333);
				twoX = tuioCursor.x;
				twoY = tuioCursor.y;
				twoPt.x = twoX*stage.stageWidth;
				twoPt.y = twoY*stage.stageHeight;
				if (aSource == null)
				{
					aSource = new SineSource(descript,int.MAX_VALUE,distance(onePt,twoPt),getAngle(onePt,twoPt));
					player.play(aSource);
				}
				else
				{
					aSource.frequency = (distance(onePt,twoPt));
					aSource.setAmp(getAngle(onePt, twoPt));
					player.play(aSource);
				}
			}
			//trace("addTuioCursor"+" x: "+tuioCursor.x+" y:" +tuioCursor.y);
		}
		public function updateTuioCursor(tuioCursor:TuioCursor):void
		{
			//trace("updateTuioCursor called");
			//if(tuioCursor==null) ?
			if (tuioCursor.sessionID.toString() == oneCircle.name)
			{
				if (tuioCursor.x == oneX && tuioCursor.y == oneY)
				{
					//trace("CAUGHT!");
				}
				else
				{
					currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
					currentCircle.x = tuioCursor.x * stage.stageWidth;
					currentCircle.y = tuioCursor.y * stage.stageHeight;
					oneX = tuioCursor.x;
					oneY = tuioCursor.y;
					onePt.x = oneX*stage.stageWidth;
					onePt.y = oneY*stage.stageHeight;
					//trace("updateTuioCursor ONE"+" x: "+tuioCursor.x+" y:" +tuioCursor.y);
				}
			}
			else /*if (tuioCursor.sessionID.toString() == twoCircle.name)*/ //uncomment for sole two-finger support
			{
				if (tuioCursor.x == twoX && tuioCursor.y == twoY)
				{
					//trace("CAUGHT!");
				}
				else
				{
					currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
					currentCircle.x = tuioCursor.x * stage.stageWidth;
					currentCircle.y = tuioCursor.y * stage.stageHeight;
					twoX = tuioCursor.x;
					twoY = tuioCursor.y;
					twoPt.x = twoX*stage.stageWidth;
					twoPt.y = twoY*stage.stageHeight;
					//trace("updateTuioCursor TWO "+" x: "+tuioCursor.x+" y:" +tuioCursor.y);
				}
				if(aSource!=null){
				aSource.frequency = (distance(onePt,twoPt));
				aSource.setAmp(getAngle(onePt, twoPt));}
			}
		}
		public function removeTuioCursor(tuioCursor:TuioCursor):void
		{
			//if twoCircle, remove twocircle. if oneCircle, twoCircle=oneCircle, remove oneCircle. if both points are removed, null everything.
			if (twoCircle != null)
			{
				if (tuioCursor.sessionID.toString() == twoCircle.name)
				{
					currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
					stage.removeChild(currentCircle);
					twoCircle = null;
					aSource = null;
				}
				else if (tuioCursor.sessionID.toString() == oneCircle.name)
				{
					currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
					oneCircle = twoCircle;
					stage.removeChild(currentCircle);
					twoCircle = null;
					aSource = null;
				}
				else
				{//issue with Tuio generating more than one point per fingertip
					currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
					stage.removeChild(currentCircle);
					trace("extra point");
				}
			}
			else
			{
				currentCircle = stage.getChildByName(tuioCursor.sessionID.toString()) as Circle;
				stage.removeChild(currentCircle);
				twoCircle=null;
				oneCircle=null;
				aSource = null;
			}
			player.stop();
		}

		//Implementing all the functions from the ITuioListener interface class that I'm not using
		public function addTuioObject(tuioObject:TuioObject):void
		{
		}
		public function updateTuioObject(tuioObject:TuioObject):void
		{
		}
		public function removeTuioObject(tuioObject:TuioObject):void
		{
		}
		public function addTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		public function updateTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		public function removeTuioBlob(tuioBlob:TuioBlob):void
		{
		}
		public function newFrame(id:uint):void
		{
		}
	}
}