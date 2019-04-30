PImage img;
PFont mono;
byte[] data;
String in, out, myText, myText2, myText3;
int dayInt, hourInt, minuteInt, secondInt, loopCount;
boolean bool = false;

void setup() {
  size(1280, 720, P2D);
  loopCount = 0;
  out = "/home/pi/Desktop/alephBend/data/capture/output.jpg";
  mono = createFont("DejaVuSansMono.ttf", 16);
  textFont(mono);
  textAlign(CENTER, CENTER);
}

void draw() {

  if (bool == false) {
    background(255);
    fill(#767676);
    textSize(32);
    myText = "This photobooth takes photos...and then breaks them!";
    text(myText, 0, 0, width, height - 200);
    textSize(16);
    myText2 = "To start the program, click the mouse ONCE. A preview of the camera's view will display for 5 seconds before the program snaps a picture. This screen will reappear for 10 seconds and then the glitching will begin. The program will loop through the image four times, performing random data bending operations each time. This process can take varying amounts of time. Please be patient, this software runs on a $30 computer!"; 
    text(myText2, 0, 20, width, height);
    myText3 = "If the program stops working, please notify a staff member. Have fun!";
    text(myText3, 0, 60, width, height + 100);
  }

  //once the mouse is clicked (inverting the toggle state), runs the databending 
  //code after the delay in the mousePressed function runs its course. 
  //if we don't have the photo from raspistill yet, the following code will fail and 
  //throw a null pointer exception.  
  if (bool == true) {
    //load the capture photo's bytes into array
    try {
      data = loadBytes(in);

      //create PImage 
      img = loadImage(in);

      //save the data array to new file

      saveBytes(out, data);

      //load those bytes back into the data array so we don't break the original
      data = loadBytes(out);

      //this for loop controls the number of iterations where we write random bytes
      //of value 0-data.length into the array. the loc variable is where we define the 
      //header length so we don't immediately break the file. important!
      for (int i = 0; i < 32; i++) {
        int loc = (int)random(256, data.length);
        data[loc] = (byte)random(data.length);
      }
    }

    catch(Exception e1) {
      bool = false;
      loopCount = 0;
    }

    //save these new mangled bytes into the data array
    try {
      saveBytes(out, data);


      //make PImage of mangled image
      img = loadImage(out);

      //display the mangled image. 
      image(img, 0, 0);
    }

    catch(Exception e2) {
      bool = false;
      loopCount = 0;
    }

    //each time the draw loop concludes, the entire process starts again using the 
    //original (non-bent) image. this is so you can see the fruits of the random seeds
    //changing each time, but also so you can (generally speaking) just leave the image
    //looping over and over like animation without it getting fatally broken.
    loopCount++;
    println(loopCount);

    if (loopCount >= 4) {
      bool = !bool;
      loopCount = 0;
    }

    if (loopCount <= 4) {
      saveFrame(in + "_glitched" + "_" + loopCount + ".jpg");
    }
  }
}

void mousePressed() {
  //get timestamp "ingredients" and match their formatting w/ bash timestamp.
  dayInt = day();
  //cast day() int to a string so we can use it for the filename. 
  String day = nf(dayInt);
  if (day.length() < 2) {
    day = "0" + day;
  }

  hourInt = hour();
  String hour = nf(hourInt);
  if (hour.length() < 2) {
    hour = "0" + hour;
  }

  minuteInt = minute();
  String minute = nf(minuteInt);
  if (minute.length() < 2) {
    minute = "0" + minute;
  }

  secondInt = second();
  String second = nf(secondInt);
  if (second.length() < 2) {
    second = "0" + second;
  }

  //construct timestamp and assign it as the input file. note this has to precisely
  //match the actual photo taken by raspistill or it won't load anything. 
  in = "/home/pi/Desktop/alephBend/data/capture/" + day + "_" + hour + minute + second + ".jpg";

  //launch a .desktop file which in turns launches a bash script which in turn launches
  //the command line raspistill camera app and tells it to take a picture and save it 
  //in this program's data folder with the filename being the timestamp (D:H:M). 
  launch("/home/pi/Desktop/alephBend/scripts/bash.desktop");

  //this delay is critical. it's what allows the bash script and raspistill enough time 
  //to do their jobs. the default raspistill timer is 5000ms. i added a 5 sec buffer 
  //for the time it takes to save the file.
  delay(10000);

  //invert the toggle state 
  bool = !bool;
  println(in, bool);
}
