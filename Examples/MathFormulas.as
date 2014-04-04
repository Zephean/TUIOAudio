package utilities{
	import flash.geom.Point;
	
	//import gameobjects.Mallet;
	public class MathFormulas {
		//private var gravConst:Number;//6.673 *10^-11;
		public function MathFormulas(){
			//Stand back I'm about to try Math!
			
		}
		
		//converts radians to degrees
		public static function radiansToDegrees(rad:Number){//converts radians to degrees
			//to convert radians to degrees, multiply by 180/p, like this:
			var degrees = rad * (180 / Math.PI);
			return degrees;
		}
		//send it degrees, it will give you a vector as an x,y point
		public static function degreesToSlope(deg:Number):Point {
			var rad = (deg-90) * Math.PI / 180			
			return new Point(Math.cos(rad), Math.sin(rad));
		}
		
		//send it two points and it will give you the angle in degrees
		public static function getAngle(pt1:Point, pt2:Point):Number {
			var theX:int = pt1.x - pt2.x;
			var theY:int = (pt1.y - pt2.y) * -1;
			if(theX == 0 && theY == 0){//if we are dividing by by zero!
				return 0;
			}else{
				var angle = Math.atan(theY/theX)/(Math.PI/180);
				if (theX<0){
					angle += 180;
				}
				if (theX>=0 && theY<0){
					angle += 360;
				}
				//trace("angle "  + angle);
				return(angle*-1) + 90;
			}
		}
		
		// returns the distance between 2 points
		public static function distanceFormula(p1,p2){
			var dist,dx,dy:Number;
			dx = p2.x-p1.x;
			dy = p2.y-p1.y;
			dist = Math.sqrt(dx*dx + dy*dy);
			//trace(dist);
			return dist;
		}
		
		//this works, just commented out because it references an old game
		/*
		public static function gravity(obj1, obj2,gravity){
			var xDiff:Number = obj1.x - obj2.x;//difference between 2 objects on x axis
			var yDiff:Number = obj1.y - obj2.y;//diff between 2 objecgts on y axis
			var fg:Number;//the force of gravity to be applied to the object
			var gravConst:Number = gravity;//6.673 *10^-11; is set from the game class
			var m1:Number = obj1.mass;//the mass of object 1
			var m2:Number = obj2.mass;//the mass of object 2
			var dist:Number = MathFormulas.distanceFormula(obj1,obj2)//distance between 2 objects
			
			//fg = (gravConst * m1*m2)/dist^2
			//6.673 x 10 ^-11
			fg = (gravConst * m1 * m2)/(dist * dist);//calculate force
			//trace(fg);
			var xChange :Number = fg * xDiff;//change on X axis
			var yChange :Number = fg * yDiff;//change on Y axis
			if(obj2 is gameobjects.Wormhole){//resolve attraction between puck and wormhole
				obj1.deltaX -= xChange;//apply change to x
				obj1.deltaY -= yChange;//apply change to y
			}
			if(obj2 is  gameobjects.CenterPoint){//resolve attraction between puck and wormhole
				obj2.deltaX += xChange;//apply change to x
				obj2.deltaY += yChange;//apply change to y
			}
		}*/
		
		//returns the new delta X and Y for only the first object
		public static function circleToCircleCollision(obj1, obj2, multiplier) {
			
				
				//horizontal distance between the two object centers
                var run:Number=obj1.x-obj2.x;
				//verticle distance between the two object centers
                var rise:Number=obj1.y-obj2.y;
				//the horizontal velocity at which the two objects are approaching
                var vel_run:Number=obj1.deltaX - obj2.deltaX;
				//the verticle velocity at which the two objects are approaching
                var vel_rise:Number=obj1.deltaY - obj2.deltaY;
				//original horizontal posistion of obj1
                var oldselfvx:Number=obj2.deltaX;
				//original verticle possition of obj1
                var oldselfvy:Number=obj2.deltaY;
				//original radius of obj1
                var oldselfr:Number=obj2.radius;
				//original radius of obj2
                var oldbr:Number=obj1.radius;
				//combined radii of obj1 and obj2
                var radii:Number=obj1.radius + obj2.radius;
				//Distance between the centers of obj1 and obj2: squareroot of ((x2-x1)^2 + (y2-y1)^2)
                var distCollision:Number=Math.sqrt(run*run+rise*rise);
				var normalX;
				var normalY;
				var dVector;
				var dvx;
				var dvy;
				var oldBX=obj1.deltaX;
				var oldBY=obj1.deltaY;
				var bouncyness:Number=1
				
				// return old velocities if bodies are not approaching
				if ((vel_run * run + vel_rise * rise) >= 0) {
					return;
				}
				//trace("normalX " + normalX);
				//trace("run " + run);
				//trace("distCollision " + distCollision);
				//trace("normalY " + normalY);
				//trace("rise " + rise);
				normalX=run/distCollision;
				normalY=rise/distCollision;
				dVector = (obj2.deltaX - obj1.deltaX) * normalX + (obj2.deltaY - obj1.deltaY) * normalY;
				dvx= dVector*normalX;
				dvy= dVector*normalY;
				//trace("dVector " + dVector);
				//trace("dvx " + dvx);
				//trace("dvy " + dvy);
				
				
				var addToDeltaX = dvx*bouncyness * multiplier;//the additional speed added to the deltas of the puck
				var addToDeltaY = dvy*bouncyness * multiplier;
				//if the puck is colliding with either a mallet that is not moving or a pocket circle
				//don't average the deltas before applying
				/*if(obj2 is gameobjects.Mallet || obj2 is gameobjects.PocketHalfCircle){
					if(obj2.deltaX == 0){
						addToDeltaX*=2;
					}
					if(obj2.deltaY == 0){
						addToDeltaY*=2;
					}
				}*/
				return(new Point(addToDeltaX,addToDeltaY));
		}
	}
}