/*
  Evolving Ant Farm
  -----------------
  This program simulates a colony of langton ants. These ants however will age and die overtime and can only reproduce by eating.
  When an ant reproduces its offspring will mutate slightly. This leads to the evolution of unique species which will compete.
  
  written by Adrian Margel, Fall 2018
*/

//if food is displayed
boolean displayFood=false;
//if the color of the ant is displayed
boolean displayColor=false;

//the number of different types of tiles
int tileTypes=5;

//the map of all tiles
Tile[][] tiles;

//all alive ants
ArrayList<Ant> ants;

//how much the camera is zoomed in
float zoom=1;

void setup() {
  //setup window size
  size(800, 800);
  //set color to use hue
  colorMode(HSB);
  
  //setup map to size of screen
  tiles=new Tile[width][height];
  for(int x=0;x<tiles.length;x++){
    for(int y=0;y<tiles[x].length;y++){
      tiles[x][y]=new Tile(0,new Vector(x,y));
    }
  }
  
  //spawn starting random ants
  ants=new ArrayList<Ant>();
  for (int i=0; i<5000; i++) {
    spawnRandomAnt();
  }
  
  //draw starting tiles
  for (int x=0; x<tiles.length; x++) {
    for (int y=0; y<tiles[x].length; y++) {
      fill(tiles[x][y].type*255/tileTypes);
      noStroke();
      rect(x*zoom, y*zoom, zoom, zoom);
    }
  }
  
  //set framerate really high so it'll max out
  frameRate(300);
}
void draw() {
  //try to spawn up to 200 new food tiles
  for(int i=0;i<200;i++){
    spawnFood(tiles);
  }
  
  //move all ants
  for (int i=0; i<ants.size(); i++) {
    ants.get(i).move(tiles);
  }
  
  //remove and kill all dead ants
  for (int i=ants.size()-1; i>=0; i--) {
    if(!ants.get(i).alive){
      ants.get(i).die();
      ants.remove(i);
    }
  }
}



//-------------General Methods-------------



//spawns food onto the map
void spawnFood(Tile[][] grid){
  //if the tile was successfully placed
  boolean placed=false;
  //the number of times it will attempt to place the food
  int tries=100;
  while(!placed&&tries>0){
    //how many more times it will try to place the food
    tries--;
    
    //spawn food
    int x=(int)random(0,tiles.length);
    int y=(int)random(0,tiles[0].length);
    
    //unused code for spawning food in a circle
    /*float d=random(0,400);
    float a=random(0,TWO_PI);
    int x=(int)(cos(a)*d)+400;
    int y=(int)(sin(a)*d)+400;*/
    
    //if food somehow spawns out of bounds loop it around back into bounds
    if (x<0) {
      x=x+grid.length;
    }
    if (x>=grid.length) {
      x=x-grid.length;
    }
    if (y<0) {
      y=y+grid[0].length;
    }
    if (y>=grid[0].length) {
      y=y-grid[0].length;
    }
    
    //calculate using a simple set of rules if the food can spawn at this position
    //this is based on the amount of air around the tile
    
    //rules vary over space creating multiple biomes
    int surr=getSurround(tiles,0,new Vector(x,y),4);
    if(grid[x][y].type==0&&(surr>x/10&&surr<x/10+y/10)){
      //if the food can spawn then replace the tile with food
      grid[x][y].resetTile();
      grid[x][y].type=tileTypes;
      //draw the food optionally
      if(displayFood){
        fill(100,255,150);
        noStroke();
        rect(x*zoom, y*zoom, zoom, zoom);
      }
      //set flag that the tile was placed
      placed=true;
    }
    
    //unused simpler single biome ruleset
    /*int surr=getSurround(tiles,0,new Vector(x,y),2)+getSurround(tiles,tileTypes,new Vector(x,y),2);
    if(grid[x][y].type==0&&surr>20&&surr<25){
      //if the food can spawn then replace the tile with food
      grid[x][y].resetTile();
      grid[x][y].type=tileTypes;
      //draw the food optionally
      if(displayFood){
        fill(100,255,150);
        noStroke();
        rect(x*zoom, y*zoom, zoom, zoom);
      }
      //set flag that the tile was placed
      placed=true;
    }*/
  }
}

//get the number of tiles surrounding a tile
int getSurround(Tile[][] grid,int fType,Vector pos,int range){
  int total=0;
  for(int tx=-range;tx<=range;tx++){
    for(int ty=-range;ty<=range;ty++){
      int x=pos.x+tx;
      int y=pos.y+ty;
      if (x<0) {
        x=x+grid.length;
      }
      if (x>=grid.length) {
        x=x-grid.length;
      }
      if (y<0) {
        y=y+grid[0].length;
      }
      if (y>=grid[0].length) {
        y=y-grid[0].length;
      }
      if(grid[x][y].type==fType){
        total++;
      }
    }
  }
  return total;
}

//spawn new ants
void spawnRandomAnt(){
  ants.add(new Ant(new Vector((int)random(0,tiles.length), (int)random(0,tiles[0].length))));
}
void spawnFromRandom(ArrayList<Ant> options){
  int id=(int)random(0,options.size());
  spawnAnt(options.get(id),new Vector(options.get(id).pos));
}
void spawnAnt(Ant parAnt,Vector pos){
  ants.add(new Ant(parAnt,pos));
  ants.get(ants.size()-1).mutate();
}



//-------------Classes-------------



//simple integer based vector class
class Vector {
  int x, y;
  Vector(int tx, int ty) {
    x=tx;
    y=ty;
  }
  Vector(Vector clone) {
    x=clone.x;
    y=clone.y;
  }
  boolean isSame(Vector compare) {
    return compare.x==x&&compare.y==y;
  }
}

//this class generates random numbers to be used in mutations
//the mutator class is also able to be mutated
class Mutator {
  
  //maximum value to be produced
  float high;
  //other values for the math equation used to generate numbers
  float spread;
  float modifier;
  
  //if true it cannot mutate it's high value
  boolean fixedHigh;
  
  Mutator(float s, float h, float mod) {

    spread=s;
    high=h;
    modifier=mod;
    fixedHigh=false;
  }

  //create a mutator based off another mutator
  Mutator(Mutator clone) {

    spread=clone.spread;
    high=clone.high;
    modifier=clone.modifier;
    fixedHigh=clone.fixedHigh;
  }

  //set high to be fixed
  void fixHigh() {
    fixedHigh=true;
  }

  //mutate the mutator based on other mutators
  void mutate(Mutator mutateMutateHigh, Mutator mutateMutateSpread, Mutator mutateMutateMod) {
    if (!fixedHigh) {
      if ((int)random(0, 2)==1) {
        high+=mutateMutateHigh.getValue();
      } else {
        high-=mutateMutateHigh.getValue();
      }
    }
    high=max(high, 0);

    if ((int)random(0, 2)==1) {
      spread+=mutateMutateSpread.getValue();
    } else {
      spread-=mutateMutateSpread.getValue();
    }
    spread=min(max(spread, 1), 10);

    if ((int)random(0, 2)==1) {
      modifier+=mutateMutateMod.getValue();
    } else {
      modifier-=mutateMutateMod.getValue();
    }
    modifier=max(modifier, 0);
  }

  //get the value for a seed number from 0 to 1
  float getValue(float in) {
    float val=(pow(in, spread)*pow(high, 2)+in*modifier*high)/(high+modifier);
    return val;
  }

  //get a float value
  float getValue() {
    float x=random(0, 1);
    return getValue(x);
  }

  //get an int value
  int getIntValue() {
    int temp=(int)getValue();
    return temp;
  }
}

//this class checks for the existance of a certain tile type at a certain relative position
class Find {
  //the relative position of the tile to be checked
  Vector pos;
  //the type of tile expected
  int type;
  
  Find(Find clone){
    type=clone.type;
    pos=new Vector(clone.pos);
  }
  Find(Vector p, int t) {
    pos=new Vector(p);
    type=t;
  }
  
  //returns true if the tile type matches the expected type at position searched
  //the pos will be rotated based on direction to ensure that ants cannot form directional biases
  boolean matches(Tile[][] grid, Vector p, int direction) {
    int xAdd=0;
    int yAdd=0;
    if (direction==0) {
      xAdd=pos.x;
      yAdd=pos.y;
    } else if (direction==1) {
      xAdd=-pos.y;
      yAdd=pos.x;
    } else if (direction==2) {
      xAdd=-pos.x;
      yAdd=-pos.y;
    } else if (direction==3) {
      xAdd=pos.y;
      yAdd=-pos.x;
    }

    int x=p.x+xAdd;
    int y=p.y+yAdd;

    if (x<0) {
      x=x+grid.length;
    }
    if (x>=grid.length) {
      x=x-grid.length;
    }
    if (y<0) {
      y=y+grid[0].length;
    }
    if (y>=grid[0].length) {
      y=y-grid[0].length;
    }
    if (x>=0&&y>=0&&x<grid.length&&y<grid[0].length) {
      return grid[x][y].type==type;
    }
    return false;
  }
}

//a rule will check for the existance of multiple tiles in a
class Rule {
  //list of tiles it checks for
  ArrayList<Find> search;
  //the type that will be created if the searched tiles are found
  int newType;
  //how much the ant will turn by
  int turn;
  //if the rule is going to be added, this is set to false if the rule discovers it is a duplicate of an existing rule
  boolean alive;
  
  //create rule as a copy of another rule
  Rule(Rule clone){
    alive=true;
    turn=clone.turn;
    newType=clone.newType;
    search=new ArrayList<Find>();
    for(int i=0;i<clone.search.size();i++){
      search.add(new Find(clone.search.get(i)));
    }
  }
  Rule(ArrayList<Find> s, int nt, int t) {
    search=s;
    newType=nt;
    turn=t;
    alive=true;
    for (int i=0; i<s.size(); i++) {
      for (int j=i+1; j<s.size(); j++) {
        if (s.get(i).pos.isSame(s.get(j).pos)) {
          alive=false;
        }
      }
    }
  }
  
  boolean isAlive() {
    return alive;
  }
  
  //returns if the rule has found what it is searching for 
  boolean matches(Tile[][] grid, Vector pos, int direction) {
    for (int i=0; i<search.size(); i++) {
      if (!search.get(i).matches(grid, pos, direction)) {
        return false;
      }
    }
    return true;
  }
}

//this is the class for the modified langton ants that create the ecosystem
class Ant {
  //how old the ant can live
  int ageMax;
  //how much longer the ant has to live
  int age;
  
  //the rules the ant follows (it's genome)
  ArrayList<Rule> rules;
  
  //the ant's position
  Vector pos;
  //the direction the ant is facing
  int direction;
  
  //the color of the ant
  int hue;
  //if the ant is alive
  boolean alive;
  //the id of the tile that will kill the ant
  //each ant is forced to find at least one tile type poisonous
  int weakness;
  
  //all tiles the ant has created
  ArrayList<Tile> claimed;
  
  //the mutators for the ant
  //these allow the ants to evolve over time
  Mutator addMut;
  Mutator rangeMut;
  Mutator remMut;
  Mutator shiftMut;
  Mutator shiftDistMut;
  Mutator complexMut;
  Mutator spreadMut;
  Mutator ageMut;
  Mutator mutateMutateHigh;
  Mutator mutateMutateSpread;
  Mutator mutateMutateMod;
  
  //create an ant from a parent
  Ant(Ant parAnt,Vector p){
    //set random direction
    direction=(int)random(0,4);
    //init claimed arraylist
    claimed=new ArrayList<Tile>();
    //set base stats to same as parent
    weakness=parAnt.weakness;
    ageMax=parAnt.ageMax;
    age=ageMax;
    pos=new Vector(p);
    //set to be alive
    alive=true;
    //set the hue to be almost the same as the parent so that species are the same color
    hue=(parAnt.hue+(int)random(-3,3))%256;
    if(hue<0){
      hue+=256;
    }
    
    //add rules
    rules=new ArrayList<Rule>();
    for(int i=0;i<parAnt.rules.size();i++){
      rules.add(new Rule(parAnt.rules.get(i)));
    }
    
    
    //copy parent's mutators
    addMut=new Mutator(parAnt.addMut);
    rangeMut=new Mutator(parAnt.rangeMut);
    remMut=new Mutator(parAnt.remMut);
    shiftMut=new Mutator(parAnt.shiftMut);
    shiftDistMut=new Mutator(parAnt.shiftDistMut);
    complexMut=new Mutator(parAnt.complexMut);
    spreadMut=new Mutator(parAnt.spreadMut);
    ageMut=new Mutator(parAnt.ageMut);
    
    mutateMutateHigh=new Mutator(parAnt.mutateMutateHigh);
    mutateMutateSpread=new Mutator(parAnt.mutateMutateSpread);
    mutateMutateMod=new Mutator(parAnt.mutateMutateMod);
  }
  
  //create new ant
  Ant(Vector p) {
    //setup mutators
    addMut=new Mutator(1,1,0);
    rangeMut=new Mutator(1,1,0);
    remMut=new Mutator(1,1,0);
    shiftMut=new Mutator(1,1,0);
    shiftDistMut=new Mutator(1,1,0);
    complexMut=new Mutator(1,1,0);
    spreadMut=new Mutator(1,1,0);
    ageMut=new Mutator(1,1,0);
    mutateMutateHigh=new Mutator(1, 0.2, 0);
    mutateMutateSpread=new Mutator(1, 0.2, 0);
    mutateMutateMod=new Mutator(1, 0.2, 0);
    for(int i=0;i<100;i++){
      mutMuts();
    }
    
    //set generic starting stats
    direction=(int)random(0,4);
    claimed=new ArrayList<Tile>();
    changeWeakness();
    ageMax=1000;
    age=ageMax;
    alive=true;
    hue=(int)random(0,256);
    pos=new Vector(p);
    
    //startup rules
    rules=new ArrayList<Rule>();
    for(int i=0;i<30;i++){
      addRuleStart();
    }
  }
  
  //mutate the ants
  void mutate(){
    mutMuts();
    removeRules();
    addRules();
    shiftRules();
    
    /*
    //this code allows age to evolve
    int ageChange=ageMut.getIntValue();
    if(ageMutMut.getValue()>0.5){
      ageChange*=-1;
    }
    ageMax+=ageChange;
    */
    
    //very rarely allow weakness to change
    if(random(0,1000)<1){
      changeWeakness();
    }
  }
  
  //mutate the mutators
  void mutMuts(){
    addMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    rangeMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    remMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    shiftMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    shiftDistMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    complexMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    spreadMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
    ageMut.mutate(mutateMutateHigh,mutateMutateSpread,mutateMutateMod);
  }
  
  //randomly add a random number of new rules
  void addRules(){
    int add=addMut.getIntValue();
    for(int i=0;i<add;i++){
      ArrayList<Find> temp;
      Rule tempRule;
      temp = new ArrayList<Find>();
      int rSize=(int)random(1, complexMut.getIntValue()+1);
      for (int j=0; j<rSize; j++) {
        int spreadX=spreadMut.getIntValue();
        int spreadY=spreadMut.getIntValue();
        if((int)random(0,2)==0){
          spreadX*=-1;
        }
        if((int)random(0,2)==0){
          spreadY*=-1;
        }
        temp.add(new Find(new Vector(spreadX,spreadY), (int)random(0, tileTypes+1)));
      }
      tempRule=new Rule(temp, (int)random(0, tileTypes), (int)random(0, 4));
      if (tempRule.isAlive()) {
        rules.add((int)random(0,rules.size()+1),tempRule);
      }
    }
  }
  
  //add new rules for a new ant
  void addRuleStart(){
    ArrayList<Find> temp;
    Rule tempRule;
    temp = new ArrayList<Find>();
    int rSize=(int)random(1, 10);
    for (int j=0; j<rSize; j++) {
      int spreadX=(int)random(0,3);
      int spreadY=(int)random(0,3);
      if((int)random(0,2)==0){
        spreadX*=-1;
      }
      if((int)random(0,2)==0){
        spreadY*=-1;
      }
      temp.add(new Find(new Vector(spreadX,spreadY), (int)random(0, tileTypes+1)));
    }
    tempRule=new Rule(temp, (int)random(0, tileTypes), (int)random(0, 4));
    if (tempRule.isAlive()) {
      rules.add((int)random(0,rules.size()+1),tempRule);
    }
  }
  
  //randomly add rules
  void removeRules(){
    int rem=min(remMut.getIntValue(),rules.size());
    for(int i=0;i<rem;i++){
      rules.remove((int)random(0, rules.size()));
    }
  }
  
  //randomly shuffle the priority of the rules
  void shiftRules(){
    int shift=min(shiftMut.getIntValue(),rules.size());
    for(int i=0;i<shift;i++){
      int shiftId=(int)random(0, rules.size());
      int shiftAmount=shiftDistMut.getIntValue();
      Rule temp=rules.get(shiftId);
      rules.remove(shiftId);
      shiftId=min(max(shiftId+shiftAmount,0),rules.size());
      rules.add(shiftId,temp);
    }
  }
  
  void changeWeakness(){
    weakness=(int)random(1,tileTypes);
  }
  
  //move the ant and apply the ant's rules
  void move(Tile[][] map) {
    //if the ant is dead then exit the method
    if (!alive){
      return;
    }
    
    //apply all the rules in order
    for (int i=0; i<rules.size(); i++) {
      if (rules.get(i).matches(map,pos,direction)) {
        //rotate the direction based on the active rule
        direction=(direction+rules.get(i).turn)%4;
        //unused support for 8 direction movement
        //direction=(direction+rules.get(i).turn)%8;
        
        //change the tile type 
        map[pos.x][pos.y].setTile(rules.get(i).newType,this);
        //add the new tile to the list of tiles it's changed
        claimed.add(map[pos.x][pos.y]);
        
        //draw changed tiles
        if(displayColor){
          //draw the new tiles as the color of the ant
          fill(hue,255,255);
        }else{
          //draw the new tiles as their real color
          fill(tiles[pos.x][pos.y].type*255/tileTypes);
        }
        noStroke();
        rect(pos.x*zoom, pos.y*zoom, zoom, zoom);
        
        break;
      }
    }
    
    //move in the direction the ant is facing
    if (direction==0) {
      pos.x++;
    } else if (direction==1) {
      pos.y++;
    } else if (direction==2) {
      pos.x--;
    } else if (direction==3) {
      pos.y--;
    }
    
    
    
    //unused support for 8 direction movement
    /*if (direction==0) {
     pos.x++;
     } else if (direction==1) {
     pos.x++;
     pos.y++;
     } else if (direction==2) {
     pos.y++;
     } else if (direction==3) {
     pos.y++;
     pos.x--;
     } else if (direction==4) {
     pos.x--;
     } else if (direction==5) {
     pos.y--;
     pos.x--;
     } else if (direction==6) {
     pos.y--;
     } else if (direction==7) {
     pos.y--;
     pos.x++;
     }*/
    
    //if it goes off the map's edge loop it around to the other side
    if (pos.x<0) {
      pos.x=map.length-1;
    }
    if (pos.x>=map.length) {
      pos.x=0;
    }
    if (pos.y<0) {
      pos.y=map[pos.x].length-1;
    }
    if (pos.y>=map[pos.x].length) {
      pos.y=0;
    }
    
    //if it is on food eat the food and make a child
    if(map[pos.x][pos.y].type==tileTypes){
      map[pos.x][pos.y].type=0;
      spawnAnt(this,new Vector(pos));
      
      //re-draw the food tile as empty
      fill(0);
      noStroke();
      rect(pos.x*zoom, pos.y*zoom, zoom, zoom);
    }
    
    //cause ant to age
    age--;
    //cause ant to age faster depending on the amount of empty tiles around it, this makes it harder for ants to spread
    //keep in mind food only spawns in tiles with space around them
    age-=abs(getSurround(map,0));
    
    //if it's age reaches 0 kill the ant
    if(age<0){
      alive=false;
      
    //if the ant is on a tile it is weak to die
    }else if(map[pos.x][pos.y].die(this,weakness)){
      alive=false;
    }
  }
  
  //get the number of a tile around the ant of a certain type
  int getSurround(Tile[][] grid,int fType){
    int total=0;
    for(int tx=-2;tx<=2;tx++){
      for(int ty=-2;ty<=2;ty++){
        int x=pos.x+tx;
        int y=pos.y+ty;
        if (x<0) {
          x=x+grid.length;
        }
        if (x>=grid.length) {
          x=x-grid.length;
        }
        if (y<0) {
          y=y+grid[0].length;
        }
        if (y>=grid[0].length) {
          y=y-grid[0].length;
        }
        if(grid[x][y].type==fType||grid[x][y].type==tileTypes){
          total++;
        }
      }
    }
    return total;
  }
  
  //kill the ant
  //redraws all the tiles the ant has covered as dead tiles and resets their owner
  void die(){
    noStroke();
    for(Tile t:claimed){
      //if the ant still owns the tile reset and redraw the tile
      if(t.isOwner(this)){
        t.resetTile();
        fill(t.type*255/tileTypes);
        rect(t.pos.x*zoom, t.pos.y*zoom, zoom, zoom);
      }
    }
  }
}

//the tiles the map is made of, act as the environment
class Tile{
  //the type of tile
  int type;
  //the last alive ant to change the tile
  Ant owner;
  //position of the tile
  Vector pos;
  
  Tile(int t,Vector p){
    pos=p;
    owner=null;
    type=t;
  }
  
  //have an ant change the tile type
  void setTile(int t,Ant o){
    type=t;
    owner=o;
  }
  
  //reset the tile owner
  void resetTile(){
    owner=null;
    //unused to set tile back to being empty
    //type=0;
  }
  
  //check if an ant is the owner
  boolean isOwner(Ant test){
    if(owner==null){
      return false;
    }
    return test==owner;
  }
  
  //check it the tile has an alive owner
  boolean claimed(){
    return owner!=null&&owner.alive;
  }
  
  //check if an ant will die on this tile
  boolean die(Ant test,int weakness){
    if(type!=weakness){
      return false;
    }
    if(owner==null){
      return true;
    }
    return test!=owner;
  }
}
