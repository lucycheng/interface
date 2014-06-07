//Sean Cockey
//Changing Places
//MIT Media Lab

//variables for drawing functions

PGraphics model;
PGraphics walkSimulation;
PGraphics employmentSimulation;

//variables for coefficients

int modelLength = 48;
int modelWidth = 48;
int numIndices = modelLength * modelWidth;
//String[][] buildings = new String[modelLength*modelWidth][10];  //parametes are Category, Type, UC, Target, Height, Containment Rate, R, G, B, x, y, Transit
//int maxDistance = 100;
float[][] jobs; //parameters are Available, Number of walkable trips, Number of non-car trips, Average walk score, Average non-car score
float[][] labor; //parameters are same as above
int[] transit; //holds list of indices where there are transit;
int [] availableBusinesses;  //tracks indices of buidings that are not full
int [] availableHouses;  //tracks indices of buidings that are not full

//model size variables

int brickPixelWidth = 10;
int brickPixelLength = 10;
int brickPixelHeight = 10;
int brickMeterWidth = 10;
int brickMeterLength = 10;
int brickStoryHeight = 1;
int depth = 100;

//variables for walkability study

int population;
float employmentRate;
int containmentRate;
float externalTrips;
float internalTrips;
int totalTrips;
float maxWalkableDistance = 0.0;

int numberOfJobs;
int numberOfBusinesses;
int numberOfWorkers;
int numberOfHouses;
int numberOfTransit;

float totalLaborToJobTrips = 0;
float totalWalkableLaborToJobTrips = 0;
float totalNonCarLaborToJobTrips = 0;
float totalJobToLaborTrips = 0;
float totalWalkableJobToLaborTrips = 0;
float totalNonCarJobToLaborTrips = 0;
float walkabilityScore = 0;
float noCarScore = 0;

float employmentScore = 0;
float recruitingScore = 0;


void setup()
{ 
  for (int i = 0; i < numIndices; i++){
    if (i == 0) {
      buildings[i][0] = "Jobs";
      buildings[i][1] = "lab";
      buildings[i][2] = "10";
      buildings[i][3] = "6";
      buildings[i][4] = "12";
      buildings[i][5] = "100";
      buildings[i][6] = "255";
      buildings[i][7] = "0";
      buildings[i][8] = "0";
    }else if (i == 2){
      buildings[i][0] = "Transit";
      buildings[i][1] = "bus";
      buildings[i][2] = "0";
      buildings[i][3] = "0";
      buildings[i][4] = "0";
      buildings[i][5] = "0";
      buildings[i][6] = "0";
      buildings[i][7] = "0";
      buildings[i][8] = "0";
    }else if (i == 1998){
      buildings[i][0] = "Transit";
      buildings[i][1] = "bus";
      buildings[i][2] = "0";
      buildings[i][3] = "0";
      buildings[i][4] = "0";
      buildings[i][5] = "0";
      buildings[i][6] = "0";
      buildings[i][7] = "0";
      buildings[i][8] = "0";
    }else if (i == 2000 || i == 6 || i == 542){
      buildings[i][0] = "Labor";
      buildings[i][1] = "apartment";
      buildings[i][2] = "10";
      buildings[i][3] = "6";
      buildings[i][4] = "12";
      buildings[i][5] = "100";
      buildings[i][6] = "0";
      buildings[i][7] = "0";
      buildings[i][8] = "255";
    }else{
      buildings[i][0] = "Empty";
      buildings[i][1] = "empty";
      buildings[i][2] = "0";
      buildings[i][3] = "0";
      buildings[i][4] = "0";
      buildings[i][5] = "0";
      buildings[i][6] = "255";
      buildings[i][7] = "255";
      buildings[i][8] = "255";
      buildings[i][9] = "0";
    }
   }
  
  //set up display

  size(modelWidth * brickPixelWidth * 3 + 300, modelLength * brickPixelLength + 100, P2D);
  setUpOutputScreen();
  model = createGraphics(modelWidth * brickPixelWidth, modelLength*brickPixelLength, P3D);
  walkSimulation = createGraphics(modelWidth * brickPixelWidth, modelLength*brickPixelLength, P3D);
  employmentSimulation = createGraphics(modelWidth * brickPixelWidth, modelLength*brickPixelLength, P3D);
 
  noLoop();
}

void setUpOutputScreen()
{
  
  background(200);
  textSize(32);
  fill(0, 0, 0);
  textAlign(CENTER);
  text("Model", (modelWidth * brickPixelWidth / 2) + 50, 40);
  text("Walkability", (modelWidth * brickPixelWidth * 3 / 2) + 150, 40);
  text("Employment", (modelWidth * brickPixelWidth * 5 / 2) + 250, 40);
  textSize(16);
  fill(0, 0, 0);
  textAlign(LEFT);
  text("Percent of trips that are walkable: ", (modelWidth * brickPixelWidth) + 150, (modelLength * brickPixelLength) + 70);
  text("Percent of trips that do not require a car: ", (modelWidth * brickPixelWidth) + 150, (modelLength * brickPixelLength) + 90);
  text("Percent of workers that can access a job: ", (modelWidth * brickPixelWidth) * 2 + 250, (modelLength * brickPixelLength) + 70);
  text("Percent of jobs that can access a worker: ", (modelWidth * brickPixelWidth) * 2 + 250, (modelLength * brickPixelLength) + 90);
  fill(255);
  rect((modelWidth * brickPixelWidth) + 525, (modelLength * brickPixelLength) + 55, 100, 36);
  rect((modelWidth * brickPixelWidth) * 2 +625, (modelLength * brickPixelLength) + 55, 100, 36);
  fill(0, 0, 0);
  text("%", (modelWidth * brickPixelWidth) + 600, (modelLength * brickPixelLength) + 70);
  text("%", (modelWidth * brickPixelWidth) + 600, (modelLength * brickPixelLength) + 90);
  text("%", (modelWidth * brickPixelWidth) * 2 + 700, (modelLength * brickPixelLength) + 70);
  text("%", (modelWidth * brickPixelWidth) * 2 + 700, (modelLength * brickPixelLength) + 90);
  
  
  
  
}
int i = 0;
void draw() 
{
  setUpOutputScreen();
  readParameters();
  updateModel();
  updateSimulations();
}
 
void readParameters()
{
  maxWalkableDistance = float(maxDistance);
  employmentRate = 100.0;
}

float getMaxWalkableDistance()
{
  return maxWalkableDistance;
}

private void updateModel()
{
  //start drawing
  model.beginDraw();
  model.background(125);
  model.stroke(0);
  model.colorMode(RGB, 255, 255, 255);

  //pattern a grid to represent the model
  for (int i = 0; i < modelWidth; i = i + 1) {
    for (int j = 0; j < modelLength; j = j + 1) {
      makeModelBrick(i + modelWidth*j);  //indices loop through rows then columns
    }
  }

  //end drawing
  model.endDraw();
  image(model, 50, 50);
}

private void updateSimulations()
{
  int UC;
  int containmentRate;
  int Height;
  String Category;
  
  countBuildings();

  setTransitScores();

  startDrawing(walkSimulation);
  
  updateWalkSimulation();

  startDrawing(employmentSimulation);

  updateEmploymentSimulation();

  //display overall simulation scores using HSB color code
  colorMode(HSB);
  float H;
  int S = 100;
  int B = 100;

  if (walkabilityScore < 100) {
    H = walkabilityScore;
  }
  else if (walkabilityScore >= 100) {
    H = 100;
  }
  else {
    H = 0;
  }
  fill(H, S, B);
  text(walkabilityScore, (modelWidth * brickPixelWidth) + 525, (modelLength * brickPixelLength) + 70);
  //text(maxWalkableDistance, (modelWidth * brickPixelWidth) + 525, (modelLength * brickPixelLength) + 70);

  if (noCarScore < 100) {
    H = noCarScore;
  }
  else if (noCarScore >= 100) {
    H = 100;
  }
  else {
    H = 0;
  }  
  fill(H, S, B);
  text(noCarScore, (modelWidth * brickPixelWidth) + 525, (modelLength * brickPixelLength) + 90);

  if (employmentScore < 250) {
    H = employmentScore;
  }
  else if (employmentScore >= 250) {
    H = 250;
  }
  else {
    H = 0;
  }
  fill(H, S, B);
  text(employmentScore, (modelWidth * brickPixelWidth) * 2 + 625, (modelLength * brickPixelLength) + 70);

  if (recruitingScore < 250) {
    H = recruitingScore;
  }
  else if (recruitingScore >= 250) {
    H = 100;
  }
  else {
    H = 0;
  }  
  fill(H, S, B);
  text(recruitingScore, (modelWidth * brickPixelWidth) * 2 + 625, (modelLength * brickPixelLength) + 90);
}

private void startDrawing(PGraphics simulation)
{
  //start drawing
  simulation.beginDraw();
  simulation.stroke(0);
  simulation.colorMode(HSB, 300, 100, 100);
  simulation.background(300, 0, 50);

  //pattern white grid
  for (int i = 0; i < modelLength; i = i + 1) {
    for (int j = 0; j < modelWidth; j = j + 1) {
      simulation.fill(100, 0, 100);
      simulation.translate(Xpixel(j), Ypixel(i+1), -depth);
      simulation.box(brickPixelWidth, brickPixelLength, 0);
      simulation.translate(-Xpixel(j), -Ypixel(i+1), depth);
    }
  }
}

private void countBuildings()
{
  int UC;
  int Height;
  String Category;

  numberOfHouses = 0;
  numberOfWorkers = 0;
  numberOfBusinesses = 0;
  numberOfJobs = 0;
  numberOfTransit = 0;

  for (int i = 0; i < numIndices; i = i + 1) {
    Category = buildings[i][0];
    UC = int(buildings[i][2]);
    Height = int(buildings[i][4]);
    if (Category.equals("Labor")) {
      numberOfHouses = numberOfHouses + 1;
      numberOfWorkers = numberOfWorkers + int(float(UC) * float(Height) * employmentRate /  100.0);
    }
    else if (Category.equals("Jobs")) {
      numberOfBusinesses = numberOfBusinesses + 1;
      numberOfJobs = numberOfJobs + UC * Height;
    }
    else if (Category.equals("Transit")) {
      numberOfTransit = numberOfTransit + 1;
    }
  }
  
  jobs = new float[numberOfBusinesses][11];
  labor = new float[numberOfHouses][11];
  transit = new int[numberOfTransit];
  availableBusinesses = new int[numberOfBusinesses];
  availableHouses = new int [numberOfHouses];
  int jobIndex = 0;
  int laborIndex = 0;
  int transitIndex = 0;
  
  for (int i = 0; i < numIndices; i = i + 1) {
    Category = buildings[i][0];
    if (Category.equals("Labor")) {
      labor[laborIndex][0] = i;
      availableHouses[laborIndex] = laborIndex;
      laborIndex++;
    }
    else if (Category.equals("Jobs")) {
      jobs[jobIndex][0] = i;
      availableBusinesses[jobIndex] = jobIndex;
      jobIndex++;
    }
    else if (Category.equals("Transit")) {
      transit[transitIndex] = i;
      transitIndex++;
    }
  }
  
}

private void updateWalkSimulation()
{
  int x;
  int y;
  int transitScore;
  float score;
  int containmentRate;
  String Category;

  totalLaborToJobTrips = 0;
  totalWalkableLaborToJobTrips = 0;
  totalNonCarLaborToJobTrips = 0;
  totalJobToLaborTrips = 0;
  totalWalkableJobToLaborTrips = 0;
  totalNonCarJobToLaborTrips = 0;
  walkabilityScore = 0;
  noCarScore = 0;

  for (int i = 0; i < numIndices; i = i + 1) {
    Category = buildings[i][0];
    containmentRate = int(buildings[i][5]);
    x = Xvalue(i);
    y = Yvalue(i);
    transitScore = int(buildings[i][9]);

    if (Category.equals("Transit")) {
      //make all Transit black since score doesn't make sense
      float H = 0;
      int S = 0;
      int B = 0;
      walkSimulation.fill(H, S, B);
      walkSimulation.translate(Xpixel(x), Ypixel(y), -depth);
      walkSimulation.box(brickPixelWidth, brickPixelLength, 0);
      walkSimulation.translate(-Xpixel(x), -Ypixel(y), depth);
    }
    else if (Category.equals("Empty")) {
    }
    else if (Category.equals("Jobs") || Category.equals("Labor")){
      score = calculateWalkScore(x, y, Category, transitScore, containmentRate);
      outputWalkSimulationBrick(i, score);
    }
  }

  //end drawing
  walkSimulation.endDraw();
  image(walkSimulation, 150 + modelWidth * brickPixelWidth, 50);

  //calculate overall walkablity score
  walkabilityScore = (totalWalkableLaborToJobTrips + totalWalkableJobToLaborTrips) / (totalLaborToJobTrips + totalJobToLaborTrips) * 100.0;
  noCarScore = (totalNonCarLaborToJobTrips + totalNonCarJobToLaborTrips) / (totalLaborToJobTrips + totalJobToLaborTrips) * 100.0;
}

private void updateEmploymentSimulation()
{
  int x;
  int y;
  int transitScore;
  float score;
  float walkScore;
  int UC;
  int containmentRate;
  int Height;
  String Category;
  
  numberOfBusinesses = 0;
  numberOfHouses = 0;

  employmentScore = 0;
  recruitingScore = 0;

  //create job, labor, and time-average tables;

  for (int i = 0; i < numIndices; i = i + 1) {
  
    Category = buildings[i][0];
    x = Xvalue(i);
    y = Yvalue(i);
    
    if ((Category.equals("Labor")) || (Category.equals("Jobs"))) {
      if (Category.equals("Labor")) {
        numberOfHouses++;
      }
      else {
        numberOfBusinesses++;
      }
    }
    else if (Category.equals("Transit")) {
      //make all Transit black since score doesn't make sense
      float H = 0;
      int S = 0;
      int B = 0;
      employmentSimulation.fill(H, S, B);
      employmentSimulation.translate(Xpixel(x), Ypixel(y), -depth);
      employmentSimulation.box(brickPixelWidth, brickPixelLength, 0);
      employmentSimulation.translate(-Xpixel(x), -Ypixel(y), depth);
    }
  }
  labor = new float[numberOfHouses][11];
  jobs = new float[numberOfBusinesses][11];
  
  int laborIndex = 0;
  int jobIndex = 0;
  
  for (int i = 0; i < numIndices; i = i + 1) {
    
    Category = buildings[i][0];
    UC = int(buildings[i][2]);
    Height = int(buildings[i][4]);
    containmentRate = int(buildings[i][5]);
    x = Xvalue(i);
    y = Yvalue(i);
    transitScore = int(buildings[i][9]);
    
    if (Category.equals("Labor")) {
      labor[laborIndex][0] = i;
      labor[laborIndex][1] = float(containmentRate)/100.0 * float(UC) * float(Height);
      labor[laborIndex][2] = 0;
      labor[laborIndex][3] = 0;
      labor[laborIndex][4] = 0;
      labor[laborIndex][5] = 0;
      labor[laborIndex][6] = x;
      labor[laborIndex][7] = y;
      labor[laborIndex][8] = transitScore;
      labor[laborIndex][9] = UC;
      labor[laborIndex][10] = Height;
      laborIndex++;
    }
    else if (Category.equals("Jobs")){
      jobs[jobIndex][0] = i;
      jobs[jobIndex][1] = float(containmentRate)/100.0 * float(UC) * float(Height);
      jobs[jobIndex][2] = 0;
      jobs[jobIndex][3] = 0;
      jobs[jobIndex][4] = 0;
      jobs[jobIndex][5] = 0;
      jobs[jobIndex][6] = x;
      jobs[jobIndex][7] = y;
      jobs[jobIndex][8] = transitScore;
      jobs[jobIndex][9] = UC;
      jobs[jobIndex][10] = Height;
      jobIndex++;
    }
  }

  //run score code many times to get a probability of employment instead of just a random distribution
  int trials = 1;

  for (int n = 0; n < trials; n ++) {
    
    //clear counters
    laborIndex = 0;
    jobIndex = 0;
 
    for (int i = 0; i < numIndices; i = i + 1) {
      Category = buildings[i][0];
      UC = int(buildings[i][2]);
      Height = int(buildings[i][4]);
      containmentRate = int(buildings[i][5]);
  
      if (Category.equals("Labor")) {
        labor[laborIndex][1] = float(containmentRate)/100.0 * float(UC) * float(Height);
        labor[laborIndex][2] = 0;
        labor[laborIndex][3] = 0;
        laborIndex++;
      }
      else if (Category.equals("Jobs")){
        jobs[jobIndex][1] = float(containmentRate)/100.0 * float(UC) * float(Height);
        jobs[jobIndex][2] = 0;
        jobs[jobIndex][3] = 0;
        jobIndex++;
      }
    }
    
    //if a job is available, match the worker with the job

    int[] listOfIncompleteHouses = new int[laborIndex];
    int[] listOfIncompleteBusinesses = new int[jobIndex];

    //keep track of which rows in the labor and job tables have buildings with people or jobs left to be assigned; also reset counters for new trial
    for (int i = 0; i < numberOfHouses; i ++) {
      listOfIncompleteHouses[i] = i;
    }
    for (int i = 0; i < numberOfBusinesses; i ++) {
      listOfIncompleteBusinesses[i] = i; 
    }
    //println("trial ", n, "incomplete houses ", listOfIncompleteHouses.length);
    int incompleteHouses = numberOfHouses;
    int incompleteBusinesses = numberOfBusinesses;
    
    boolean tripIsNotWalkable = true;
    int[] notWalkable = new int[0];
    int numNotWalkable = 0;
    
    while ( (incompleteHouses > 0) && (incompleteBusinesses > 0)) {
      
      //pick a random house
      int randomHouseRow = int(random(incompleteHouses));
      if (randomHouseRow == incompleteHouses) { //prevents array index errors
        randomHouseRow = incompleteHouses - 1;
      }

      int randomHouse = listOfIncompleteHouses[randomHouseRow];
      int availableWorkersInThisHouse = int(labor[randomHouse][1]);
      //println(availableWorkersInThisHouse);
      if (availableWorkersInThisHouse > 0) {
       
        //get info for start house
        x = int(labor[randomHouse][6]);
        y = int(labor[randomHouse][7]);
        transitScore = int(labor[randomHouse][8]);
        tripIsNotWalkable = true;
        while (tripIsNotWalkable == true) {
          
          //pick a random business and get its info
          int randomBusinessRow = int(random(incompleteBusinesses));
          if (randomBusinessRow == incompleteBusinesses) { //prevents array index errors
            randomBusinessRow = incompleteBusinesses - 1;
          }
          int randomBusiness = listOfIncompleteBusinesses[randomBusinessRow];
          int availableJobsInThisBusiness = int(jobs[randomBusiness][1]);
          int destinationX = int(jobs[randomBusiness][6]);
          int destinationY = int(jobs[randomBusiness][7]);
          int destinationTransitScore = int(jobs[randomBusiness][8]);
          //println(availableJobsInThisBusiness);
          // see if a job is available
          if (availableJobsInThisBusiness > 0) {
            
            //determine if the randomly-generated labor to job trip is walkable
            int tripDistance = abs(x - destinationX) * brickMeterWidth + abs(y - destinationY) * brickMeterLength;
            if (tripDistance <= maxWalkableDistance) {
              
              tripIsNotWalkable = false;
              int numWalkableLaborTrips = int(labor[randomHouse][2]);
              int numWalkableJobTrips = int(jobs[randomBusiness][2]);
              labor[randomHouse][2] = numWalkableLaborTrips + 1;
              jobs[randomBusiness][2] = numWalkableJobTrips + 1;
              //a walkable trip is non-car, but not vice versa
              int numNonCarLaborTrips = int(labor[randomHouse][3]);
              int numNonCarJobTrips = int(jobs[randomBusiness][3]);
              labor[randomHouse][3] = numNonCarLaborTrips + 1;
              jobs[randomBusiness][3] = numNonCarJobTrips + 1;
              //if a job is available, match the worker with the job
              labor[randomHouse][1] = availableWorkersInThisHouse - 1;
              jobs[randomBusiness][1] = availableJobsInThisBusiness - 1;
              //println("walkable", jobs[randomBusiness][1]);
            }
            else if (transitScore + destinationTransitScore <= maxWalkableDistance) {
              
              tripIsNotWalkable = false;
              int numNonCarLaborTrips = int(labor[randomHouse][3]);
              int numNonCarJobTrips = int(jobs[randomBusiness][3]);
              //println("non-car ", randomHouse);
              labor[randomHouse][3] = numNonCarLaborTrips + 1;
              jobs[randomBusiness][3] = numNonCarJobTrips + 1;

              //if a job is available, match the worker with the job
              labor[randomHouse][1] = availableWorkersInThisHouse - 1;
              //println("available: ", labor[randomHouse][1]);
              jobs[randomBusiness][1] = availableJobsInThisBusiness - 1;
              //println("non-car", jobs[randomBusiness][1]);
            }
            else {
              
              numNotWalkable = notWalkable.length;
              boolean found = false;
              if (numNotWalkable > 0) {
                for (int i = 0; i < numNotWalkable; i ++) {
                  if (notWalkable[i] == randomBusiness) {
                    found = true;
                    
                  }
                }
              }
              if (found == false) {
                notWalkable = append(notWalkable, randomBusiness);
                
              }
              if (notWalkable.length >= incompleteBusinesses) { //means all possible trips are not walkable
                
                tripIsNotWalkable = false;  //trip is still not walkable, but this terminates the while loop when all jobs have been determined to not be walkable
                // remove this house from the list of incomplete houses
                int newList[] = new int[listOfIncompleteHouses.length-1];
                //println("length = ",listOfIncompleteHouses.length-1);
                int newListIndex = 0;
                for (int i = 0; i < listOfIncompleteHouses.length; i++){
                  //println("incomplete = ", listOfIncompleteHouses[i], " ", randomHouse);
                  if (listOfIncompleteHouses[i] == randomHouse){
                  }else{
                    //println("newListIndex = ", newListIndex, " ", i);
                    newList[newListIndex] = listOfIncompleteHouses[i];
                    newListIndex++;
                  }
                }
                //println(16);
                listOfIncompleteHouses = new int[newListIndex];
                for (int i = 0; i < listOfIncompleteHouses.length; i++){
                     listOfIncompleteHouses[i] = newList[i];
                }
              }
            }
          }else {
            int newList[] = new int[listOfIncompleteBusinesses.length-1];
            int newListIndex = 0;
            for (int i = 0; i < listOfIncompleteBusinesses.length; i++){
              if (listOfIncompleteBusinesses[i] == randomBusiness){
              }else{
                newList[newListIndex] = listOfIncompleteBusinesses[i];
                newListIndex++;
              }
            }
            listOfIncompleteBusinesses = new int[newListIndex];
            for (int i = 0; i < listOfIncompleteBusinesses.length; i++){
                 listOfIncompleteBusinesses[i] = newList[i];
            }
            //if building is full, add it to list of non-walkable so loop ends
            notWalkable = append(notWalkable, randomBusiness);
            //println(notWalkable.length);
            if (notWalkable.length >= incompleteBusinesses) { //means all possible trips are not walkable
              tripIsNotWalkable = false;  //trip is still not walkable, but this terminates the while loop when all jobs have been determined to not be walkable
              int newList2[] = new int[listOfIncompleteHouses.length-1];
              int newListIndex2 = 0; 
              for (int i = 0; i < listOfIncompleteHouses.length; i++){
                if (listOfIncompleteHouses[i] == randomHouse){
                }else{
                  newList2[newListIndex2] = listOfIncompleteHouses[i];
                  newListIndex2++;
                }
              }
              listOfIncompleteHouses = new int[newListIndex2];
              for (int i = 0; i < listOfIncompleteHouses.length; i++){
                   listOfIncompleteHouses[i] = newList2[i];
              }
            }
          }
          //println("end");
          incompleteHouses = listOfIncompleteHouses.length;
          incompleteBusinesses = listOfIncompleteBusinesses.length;
          //println(incompleteBusinesses);
        }
      }else {
        int newList2[] = new int[listOfIncompleteHouses.length-1];
        int newListIndex2 = 0;
        for (int i = 0; i < listOfIncompleteHouses.length; i++){
          if (listOfIncompleteHouses[i] == randomHouse){
          }else{
            newList2[newListIndex2] = listOfIncompleteHouses[i];
            newListIndex2++;
          }
        }
        listOfIncompleteHouses = new int[newListIndex2];
        for (int i = 0; i < listOfIncompleteHouses.length; i++){
             listOfIncompleteHouses[i] = newList2[i];
        }
      }

      incompleteHouses = listOfIncompleteHouses.length;
      incompleteBusinesses = listOfIncompleteBusinesses.length;
    }
    for (int i = 0; i < numberOfHouses; i ++) {
      float numberOfWalkableTrips = labor[i][2];
      float numberOfNonCarTrips = labor[i][3];
      float numberOfWorkersInThisHouse = labor[i][9] * labor[i][10];
      score = numberOfNonCarTrips / numberOfWorkersInThisHouse * 100.0;
      //println("trial: ", n, " score: ", score);
      walkScore = numberOfWalkableTrips / numberOfWorkersInThisHouse * 100.0;
      labor[i][4] = labor[i][4] + walkScore;
      labor[i][5] = labor[i][5] + score;
      //println(labor[i][5]);
    }
    for (int i = 0; i < numberOfBusinesses; i ++) {
      float numberOfWalkableTrips = jobs[i][2];
      float numberOfNonCarTrips = jobs[i][3];
      float numberOfJobsInThisBusiness = jobs[i][9] * jobs[i][10];
      score = numberOfNonCarTrips / numberOfJobsInThisBusiness * 100.0;
      walkScore = numberOfWalkableTrips / numberOfJobsInThisBusiness * 100.0;
      jobs[i][4] = jobs[i][4] + walkScore;
      jobs[i][5] = jobs[i][5] + score;
    }
    
  }
  for (int i = 0; i < numberOfHouses; i ++) {
    x = int(labor[i][6]);
    y = int(labor[i][7]);
    Height = int(labor[i][10]);
    float averageScore = labor[i][5]/trials;
    employmentScore = employmentScore + averageScore;
    outputEmploymentSimulationBrick(x, y, Height, averageScore);
  }

  for (int i = 0; i < numberOfBusinesses; i ++) {
    x = int(jobs[i][6]);
    y = int(jobs[i][7]);
    Height = int(jobs[i][10]);
    float averageScore = jobs[i][5]/trials;
    recruitingScore = recruitingScore + averageScore;
    outputEmploymentSimulationBrick(x, y, Height, averageScore);
  }

  //end drawing
  employmentSimulation.endDraw();
  image(employmentSimulation, 250 + modelWidth * brickPixelWidth * 2, 50);
  employmentScore = employmentScore / numberOfHouses;
  recruitingScore = recruitingScore / numberOfBusinesses;
}



private void makeModelBrick(int index)
{
  //create bricks
  String category = buildings[index][0];
  String type = buildings[index][1];
  int UC = int(buildings[index][2]);
  int Height = int(buildings[index][4]);
  int containmentRate = int(buildings[index][5]);
  int R = int(buildings[index][6]);
  int G = int(buildings[index][7]);
  int B = int(buildings[index][8]);
  model.fill(R, G, B);
  int x = Xvalue(index);
  int y = Yvalue(index);
  if (category.equals("Empty")) {
    model.translate(Xpixel(x), Ypixel(y), -depth);
    model.box(brickPixelWidth, brickPixelLength, 0);
    model.translate(-Xpixel(x), -Ypixel(y), depth);
  }
  else {
    model.translate(Xpixel(x), Ypixel(y), -depth + Height * brickPixelHeight / 2);
    model.box(brickPixelWidth, brickPixelLength, Height * brickPixelHeight);
    model.translate(-Xpixel(x), -Ypixel(y), depth - Height * brickPixelHeight / 2);  
  }
}

private void outputWalkSimulationBrick (int i, float score)
{
  int Height = int(buildings[i][4]);
  int x = Xvalue(i);
  int y = Yvalue(i);
  float H;
  if (score < 100) {
    H = score;
  }
  else if (score >= 100) {
    H = 100;
  }
  else {
    H = 0;
  }
  int S = 100;
  int B = 100;

  walkSimulation.fill(H, S, B);
  walkSimulation.translate(Xpixel(x), Ypixel(y), -depth + Height * brickPixelHeight / 2);
  walkSimulation.box(brickPixelWidth, brickPixelLength, Height * brickPixelHeight);
  walkSimulation.translate(-Xpixel(x), -Ypixel(y), depth - Height * brickPixelHeight / 2);
}

private void outputEmploymentSimulationBrick (int x, int y, int Height, float score)
{
  float H;
  if (score < 250) {
    H = score;
  }
  else if (score >= 250) {
    H = 250;
  }
  else {
    H = 0;
  }
  int S = 100;
  int B = 100;

  employmentSimulation.fill(H, S, B);
  employmentSimulation.translate(Xpixel(x), Ypixel(y), -depth + Height * brickPixelHeight / 2);
  employmentSimulation.box(brickPixelWidth, brickPixelLength, Height * brickPixelHeight);
  employmentSimulation.translate(-Xpixel(x), -Ypixel(y), depth - Height * brickPixelHeight / 2);
}

private float calculateWalkScore(int x, int y, String Category, int transitScore, int containmentRate)
{
  float containmentRateFloat = float(containmentRate);
  int newWalkableLaborToJobTrips = 0;
  int newNonCarLaborToJobTrips = 0;
  int newWalkableJobToLaborTrips = 0;
  int newNonCarJobToLaborTrips = 0;
  int numberOfWalkableLaborToJobTrips = 0;
  int numberOfWalkableJobToLaborTrips = 0;
  int destinationX;
  int destinationY;
  int destinationUC;
  int destinationHeight;
  int tripDistance;
  String destinationCategory;
  int destinationUCRow;
  int destinationTransitScore;

  //loop through all other buildings in the city to find which ones are walkable  
  for (int i = 0; i < numIndices; i = i + 1) {
    destinationCategory = buildings[i][0];
    destinationUC = int(buildings[i][2]);
    destinationHeight = int(buildings[i][4]);
    destinationX = Xvalue(i);
    destinationY = Yvalue(i);
    destinationTransitScore = int(buildings[i][9]);

    tripDistance = abs(x - destinationX) * brickMeterWidth + abs(y - destinationY) * brickMeterLength;

    if (Category.equals("Labor")) {
      if (destinationCategory.equals("Jobs")) {
        totalLaborToJobTrips = totalLaborToJobTrips + destinationUC * destinationHeight;
        if (tripDistance <= maxWalkableDistance) {
          numberOfWalkableLaborToJobTrips = numberOfWalkableLaborToJobTrips + destinationUC * destinationHeight;
          newWalkableLaborToJobTrips = newWalkableLaborToJobTrips + destinationUC * destinationHeight;
        }
        else if (transitScore + destinationTransitScore <= maxWalkableDistance) {
          numberOfWalkableLaborToJobTrips = numberOfWalkableLaborToJobTrips + destinationUC * destinationHeight;
          newNonCarLaborToJobTrips = newNonCarLaborToJobTrips + destinationUC * destinationHeight;
        }
      }
    }
    else if (Category.equals("Jobs")) {
      if (destinationCategory.equals("Labor")) {
        totalJobToLaborTrips = totalJobToLaborTrips + destinationUC * destinationHeight;
        if (tripDistance <= maxWalkableDistance) {
          numberOfWalkableJobToLaborTrips = numberOfWalkableJobToLaborTrips + destinationUC * destinationHeight;
          newWalkableJobToLaborTrips = newWalkableJobToLaborTrips + destinationUC * destinationHeight;
        }
        else if (transitScore + destinationTransitScore <= maxWalkableDistance) {
          numberOfWalkableJobToLaborTrips = numberOfWalkableJobToLaborTrips + destinationUC * destinationHeight;
          newNonCarJobToLaborTrips = newNonCarJobToLaborTrips + destinationUC * destinationHeight;
        }
      }
    }
  }

  if (Category.equals("Labor")) {
    totalWalkableLaborToJobTrips = totalWalkableLaborToJobTrips + float(newWalkableLaborToJobTrips) * containmentRateFloat / 100.0;
    totalNonCarLaborToJobTrips = totalNonCarLaborToJobTrips + float(newNonCarLaborToJobTrips + newWalkableLaborToJobTrips) * containmentRateFloat / 100.0;  
    if (numberOfJobs == 0) {
      //println("problem labor");
      return 0.0;
    }
    else {
      float J = float(numberOfJobs);
      float N = float(numberOfWalkableLaborToJobTrips);
      return 100*(N*containmentRateFloat/J/100.0);//output score as a percent
    }
  }
  else if (Category.equals("Jobs")) {
    totalWalkableJobToLaborTrips = totalWalkableJobToLaborTrips + float(newWalkableJobToLaborTrips) * containmentRateFloat / 100.0;
    totalNonCarJobToLaborTrips = totalNonCarJobToLaborTrips + float(newNonCarJobToLaborTrips + newWalkableJobToLaborTrips) * containmentRateFloat / 100.0;
    if (numberOfWorkers == 0) {
      //println("problem job");
      return 0.0;
    }
    else {
      float W = float(numberOfWorkers);
      float N = float(numberOfWalkableJobToLaborTrips);
      return 100*(N*containmentRateFloat/W/100);//output score as a percent
    }
  }

  return 0.0; //necessary to make the if statement work
}

private void setTransitScores()
{
  int startX;
  int startY;
  int transitScore;
  int destinationX;
  int destinationY;
  int newTransitScore;
  String Category;

  for (int i = 0; i < numIndices; i = i + 1) {
    startX = Xvalue(i);
    startY = Yvalue(i);
    transitScore = modelLength*brickMeterLength + modelWidth*brickMeterWidth;
    for (int j = 0; j < numIndices; j = j + 1) {
      Category = buildings[j][0];
      if (Category.equals("Transit")) {
        destinationX = Xvalue(j);
        destinationY = Yvalue(j);
        newTransitScore = abs(startX - destinationX) * brickMeterWidth + abs(startY - destinationY) * brickMeterLength;
        if (newTransitScore < transitScore) {
          transitScore = newTransitScore; //find the closest Transit
        }
      }
    }
    buildings[i][9] = str(transitScore);
  }
}


//functions for inverting Cartesian coordinates for drawing ((0,0) is top left in drawing)

private int Xpixel (int x)
{
  return brickPixelWidth * x + 5;
}

private int Ypixel (int y)
{
  return brickPixelLength * (modelLength - y - 1) + 5;
}

//functions for converting indices to x, y

private int Xvalue (int index)
{
  return index % modelWidth;
}

private int Yvalue (int index)
{
  return modelLength - (index / modelWidth);
}
