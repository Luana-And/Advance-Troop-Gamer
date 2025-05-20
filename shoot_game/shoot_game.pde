import processing.sound.*;


SoundFile shootSound, damageSound, explosionSound;

Player player;
ArrayList<Enemy> enemies;
ArrayList<Bullet> playerBullets;
ArrayList<Bullet> enemyBullets;

PFont font;

int score = 0;
int lives = 3;
int shootCooldown = 0;
boolean gameOver = false;
boolean inMenu = true;

int spawnTimer = 0;
float enemySpeed;
float shootChance;

// Botões de dificuldade
Button btnEasy, btnNormal, btnHard;

// Botão de menu no Game Over
int menuButtonX = 300;
int menuButtonY = 350;
int menuButtonW = 200;
int menuButtonH = 40;

void setup() {
  size(800, 600);
  font = createFont("Arial", 16);
  textFont(font);

  shootSound = new SoundFile(this, "shoot.wav");
  damageSound = new SoundFile(this, "damage.wav");
  explosionSound = new SoundFile(this, "explosion.wav");

  btnEasy = new Button("Fácil", width / 2 - 100, 250, 200, 40, color(0, 200, 0));
  btnNormal = new Button("Normal", width / 2 - 100, 310, 200, 40, color(200, 200, 0));
  btnHard = new Button("Difícil", width / 2 - 100, 370, 200, 40, color(200, 0, 0));
}

void draw() {
  background(0);
  fill(255);
  textSize(16);

  if (inMenu) {
    drawMenu();
  } else if (!gameOver) {
    text("Pontuação: " + score, 10, 20);
    text("Vidas: " + lives, width - 100, 20);

    player.update();
    player.display();

    spawnTimer--;
    if (spawnTimer <= 0) {
      enemies.add(new Enemy(random(0, width - 30), -40, enemySpeed, shootChance));
      spawnTimer = 60;
    }

    for (int i = playerBullets.size() - 1; i >= 0; i--) {
      Bullet b = playerBullets.get(i);
      b.update();
      b.display();
      for (int j = enemies.size() - 1; j >= 0; j--) {
        Enemy e = enemies.get(j);
        if (b.hits(e)) {
          enemies.remove(j);
          playerBullets.remove(i);
          score += 10;
          explosionSound.play();
          break;
        }
      }
    }

    for (int i = enemyBullets.size() - 1; i >= 0; i--) {
      Bullet b = enemyBullets.get(i);
      b.update();
      b.display();
      if (b.hits(player)) {
        enemyBullets.remove(i);
        lives--;
        damageSound.play();
        if (lives <= 0) {
          explosionSound.play();
          gameOver = true;
        }
      }
    }

    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy e = enemies.get(i);
      e.update();
      e.display();
      if (e.y > height) {
        gameOver = true;
        explosionSound.play();
      }
    }

    shootCooldown = max(0, shootCooldown - 1);
  } else {
    textAlign(CENTER);
    textSize(32);
    fill(255, 0, 0);
    text("Game Over", width / 2, height / 2);
    textSize(16);
    fill(255);
    text("Pressione R para reiniciar", width / 2, height / 2 + 30);
    fill(50, 50, 200);
    rect(menuButtonX, menuButtonY, menuButtonW, menuButtonH, 10);
    fill(255);
    text("Menu Principal", menuButtonX + menuButtonW / 2, menuButtonY + 25);
  }
}

void drawMenu() {
  textAlign(CENTER);
  textSize(32);
  fill(255);
  text("Escolha a Dificuldade", width / 2, 180);
  btnEasy.display();
  btnNormal.display();
  btnHard.display();
}

void keyPressed() {
  if (!inMenu && !gameOver) {
    if (key == 'a' || key == 'A') player.move(-1);
    else if (key == 'd' || key == 'D') player.move(1);
    else if (key == ' ' && shootCooldown == 0) {
      playerBullets.add(new Bullet(player.x + 20, player.y, -7));
      shootCooldown = 20;
      shootSound.play();
    }
  }

  if (gameOver && (key == 'r' || key == 'R')) {
    startGame();
  }
}

void keyReleased() {
  if (!inMenu && (key == 'a' || key == 'A' || key == 'd' || key == 'D')) {
    player.move(0);
  }
}

void mousePressed() {
  if (inMenu) {
    if (btnEasy.isClicked(mouseX, mouseY)) {
      setDifficulty("easy");
      startGame();
      inMenu = false;
    } else if (btnNormal.isClicked(mouseX, mouseY)) {
      setDifficulty("normal");
      startGame();
      inMenu = false;
    } else if (btnHard.isClicked(mouseX, mouseY)) {
      setDifficulty("hard");
      startGame();
      inMenu = false;
    }
  } else if (gameOver) {
    if (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
        mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH) {
      inMenu = true;
    }
  }
}

void setDifficulty(String level) {
  if (level.equals("easy")) {
    enemySpeed = 0.3;
    shootChance = 0.0005;
  } else if (level.equals("normal")) {
    enemySpeed = 0.5;
    shootChance = 0.001;
  } else if (level.equals("hard")) {
    enemySpeed = 0.8;
    shootChance = 0.002;
  }
}

void startGame() {
  player = new Player(width / 2 - 20, height - 60);
  enemies = new ArrayList<Enemy>();
  playerBullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<Bullet>();
  lives = 3;
  score = 0;
  shootCooldown = 0;
  gameOver = false;
  spawnTimer = 60;
}

// ----------------------- CLASSES -----------------------

class Player {
  float x, y;
  float speed = 5;
  int direction = 0;

  Player(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void move(int dir) {
    direction = dir;
  }

  void update() {
    x += direction * speed;
    x = constrain(x, 0, width - 40);
  }

  void display() {
    fill(0, 255, 0);
    rect(x, y, 40, 40);
  }
}

class Enemy {
  float x, y;
  float speed;
  float shootChance;

  Enemy(float x, float y, float speed, float shootChance) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.shootChance = shootChance;
  }

  void update() {
    y += speed;
    if (random(1) < shootChance) {
      enemyBullets.add(new Bullet(x + 15, y + 30, 4));
    }
  }

  void display() {
    fill(255, 0, 0);
    rect(x, y, 30, 30);
  }
}

class Bullet {
  float x, y, speed;

  Bullet(float x, float y, float speed) {
    this.x = x;
    this.y = y;
    this.speed = speed;
  }

  void update() {
    y += speed;
  }

  void display() {
    fill(255, 255, 0);
    rect(x, y, 5, 10);
  }

  boolean hits(Player p) {
    return x > p.x && x < p.x + 40 && y > p.y && y < p.y + 40;
  }

  boolean hits(Enemy e) {
    return x > e.x && x < e.x + 30 && y > e.y && y < e.y + 30;
  }
}

class Button {
  String label;
  float x, y, w, h;
  color c;

  Button(String label, float x, float y, float w, float h, color c) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
  }

  void display() {
    fill(c);
    rect(x, y, w, h, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isClicked(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }
}
