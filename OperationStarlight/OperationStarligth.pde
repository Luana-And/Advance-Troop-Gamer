Player player;

import processing.sound.*; // novo
SoundFile shootSound, damageSound, explosionSound; // nobo
SoundFile backgroundMusic, victoryMusic, defeatMusic; // NOVO


ArrayList<Enemy> enemies;
ArrayList<Bullet> playerBullets;
ArrayList<Bullet> enemyBullets;
ArrayList<Item> items;
ArrayList<Particle> particles;
boolean shieldActive = false;
int shieldTimer = 0;
PImage playerImg1, playerImg2, playerImg3;
PImage enemyImg, bossImg;
PFont font;
PImage bgImage;
float bgY = 0;
int score = 0;
int highScore = 0;
int lives = 3;
int shootCooldown = 0;
boolean gameOver = false;
boolean inMenu = true;
int spawnTimer = 0;
float enemySpeed;
float shootChance;
int playerFirePower = 1;
boolean speedBoost = false;
int speedBoostTimer = 0;

String scoreFile = "highscore.txt";

Boss boss;
boolean bossActive = false;
boolean bossDefeated = false;

Button btnEasy, btnNormal, btnHard;
int menuButtonX = 300;
int menuButtonY = 350;
int menuButtonW = 200;
int menuButtonH = 40;
boolean paused = false; // pausa

boolean victory = false;

// Variáveis para controle da tela de história
boolean mostrarHistoria = true;
int paginaHistoria = 0;

// Textos da história divididos em páginas
String[] historia = {
  "Ano 2587. A humanidade conquistou as estrelas.\nPor séculos, a paz reinou sob a federação galáctica.",

  "Mas uma ameaça surgiu das profundezas do universo...\nOs Kragons, uma raça de máquinas destruidoras,\ncomeçaram a dizimar planetas inteiros.",

  "Liderados pelo terrível Overlord Zarg,\neles consomem tudo em seu caminho,\nalimentando sua frota de guerra imbatível.",

  "As defesas da federação caíram.\nA esperança desaparece...\nMas uma última resistência surge...",

  "Você é um dos Galaxy Defenders,\no último piloto capaz de enfrentar essa ameaça.\nO destino da galáxia está em suas mãos.",

  "\"Quando a escuridão consome as estrelas...\nsó os Defensores da Galáxia podem reacender a esperança.\"\n\nPressione ESPAÇO para iniciar sua missão!"
};

void setup() {
  size(800, 600);
  font = createFont("Arial", 16);
  textFont(font);

  shootSound = new SoundFile(this, "shoot.wav"); // novo
  damageSound = new SoundFile(this, "damage.wav"); // novo
  explosionSound = new SoundFile(this, "explosion.wav"); // novo
  
   // Load new music files <<<< NOVO
  try {
    backgroundMusic = new SoundFile(this, "background_music.mp3"); // NOVO
    victoryMusic = new SoundFile(this, "victory_jingle.wav");    // NOVO
    defeatMusic = new SoundFile(this, "defeat_jingle.wav");       // NOVO

    backgroundMusic.loop(); // Start background // NOVO
  } catch (Exception e) {// NOVO
    System.err.println("Error loading sound files. Make sure they are in the sketch's 'data' folder.");// NOVO
    e.printStackTrace();// NOVO
  }
  
  

  playerImg1 = loadImage("player1.png");
  playerImg2 = loadImage("player2.png");
  playerImg3 = loadImage("player3.png");

  enemyImg = loadImage("enemy.png");
  bossImg = loadImage("boss.png");





  playerImg1.resize(70, 70);
  playerImg2.resize(70, 70);
  playerImg3.resize(70, 70);
  enemyImg.resize(50, 50);
  bossImg.resize(150, 150);

  btnEasy = new Button("Fácil", width / 2 - 100, 250, 200, 40, color(0, 200, 0));
  btnNormal = new Button("Normal", width / 2 - 100, 310, 200, 40, color(200, 200, 0));
  btnHard = new Button("Difícil", width / 2 - 100, 370, 200, 40, color(200, 0, 0));

  String[] data = loadStrings(scoreFile);
  if (data != null && data.length > 0) {
    highScore = int(data[0]);
  }
}

void checarSalvarRecorde() {
  if (score > highScore) {
    highScore = score;
    saveStrings(scoreFile, new String[]{str(highScore)});
  }
}

void draw() {
  if (paused) {// pausa
    fill(255);// pausa
    textAlign(CENTER, CENTER);// pausa
    textSize(32);// pausa
    text("Jogo Pausado", width/2, height/2);// pausa
    return;// pausa
  } // pausa

  if (mostrarHistoria) {
    mostrarTelaHistoria();
  } else {
    // Fundo com rolagem
    if (bgImage != null) {
      image(bgImage, 0, bgY);
      image(bgImage, 0, bgY - height);
      bgY += 1;
      if (bgY >= height) bgY = 0;
    } else {
      background(0);
    }

    fill(255);
    textSize(16);

    if (inMenu) {
      drawMenu();
    } else if (victory) {
      drawVictoryScreen();
    } else if (!gameOver) {
      drawGameplay();
    } else {
      drawGameOverScreen();
    }
  }
}

void mostrarTelaHistoria() {
  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);

  textSize(18);
  text(historia[paginaHistoria], width/2, height/2);

  textSize(14);
  text("Pressione ESPAÇO para continuar...", width/2, height - 40);
}
void drawGameplay() {
  
  textAlign(LEFT); 
  text("Recorde: " + highScore, 10, 20); 


  textAlign(CENTER); 
  text("Pontuação: " + score, width / 2, 20); 


  textAlign(RIGHT); 
  text("Vidas: " + lives, width - 10, 20); 
 

  if (shieldActive) {
    shieldTimer--;
    if (shieldTimer <= 0) {
      shieldActive = false;
    }
  }

  updateEnemies();
  updateBullets();  
  updateItems();
  updateParticles();
  updateBoss();   

  updatePlayerUpgrade();  

  player.update();
  player.display();

  if (speedBoost) {
    speedBoostTimer--;
    if (speedBoostTimer <= 0) speedBoost = false;
  }

  // Shoot cooldown
  shootCooldown = max(0, shootCooldown - 1);
}
void updateEnemies() {
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    e.display();
    if (e.y > height) {
      gameOver = true;
      
          // Music handling for GAME OVER <<<< NOVO
          if (backgroundMusic != null && backgroundMusic.isPlaying()) {
              backgroundMusic.stop();
          }
          if (victoryMusic != null && victoryMusic.isPlaying()) { // Stop victory music
              victoryMusic.stop();
          }
          if (defeatMusic != null && !defeatMusic.isPlaying()) {
              defeatMusic.play();
          }
    }
  }

  // Spawn de inimigos 
  if (!bossActive && !bossDefeated) {
    spawnTimer--;
    if (spawnTimer <= 0) {
      float x = random(width - 50);
      enemies.add(new Enemy(x, -50, enemyImg, enemySpeed, shootChance));
      spawnTimer = 60;  // Ajuste o intervalo de spawn
    }
  }
}
void updateBullets() {
  // Atualiza e exibe os tiros do jogador
  for (int i = playerBullets.size() - 1; i >= 0; i--) {
    Bullet b = playerBullets.get(i);
    b.update();
    b.display();

    // Remove bala fora da tela
    if (b.y < 0) {
      playerBullets.remove(i);
      continue;
    }

    // Checa colisão com inimigos
    boolean hitEnemy = false;
    for (int j = enemies.size() - 1; j >= 0; j--) {
      Enemy e = enemies.get(j);
      if (b.hits(e)) {
        createExplosion(e.x + 25, e.y + 25);
        explosionSound.play(); // Play explosion sound
        enemies.remove(j);
        playerBullets.remove(i);

        // Chance de spawnar item
        float rand = random(1);
        int itemType;
        if (rand < 0.3) itemType = 0;         // Azul - power
        else if (rand < 0.6) itemType = 1;    // Laranja - speed
        else if (rand < 0.85) itemType = 2;  // Ciano - shield
        else itemType = 3;                  // Nova - múltiplos tiros

        items.add(new Item(e.x + 25, e.y + 25, itemType));

        score += 10;
        hitEnemy = true;
        break;
      }
    }
    if (hitEnemy) continue;

    // colisão com o boss
    if (bossActive && boss != null && b.hits(boss)) {
      boss.health -= 5 * playerFirePower;
      createExplosion(b.x, b.y);
      playerBullets.remove(i);
      if (boss.health <= 0) {
        createExplosion(boss.x + 75, boss.y + 75);
        explosionSound.play(); // Play explosion sound when boss is defeated
        bossActive = false;
        bossDefeated = true;
        score += 500;
        victory = true;
        checarSalvarRecorde();
           // Music handling for VICTORY <<<< NOVO
            if (backgroundMusic != null && backgroundMusic.isPlaying()) {
                backgroundMusic.stop();
            }
            if (defeatMusic != null && defeatMusic.isPlaying()) { // Stop defeat music if somehow playing
                defeatMusic.stop();
            }
            if (victoryMusic != null && !victoryMusic.isPlaying()) {
                victoryMusic.play();
            }
        }
      }
    }

  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    Bullet b = enemyBullets.get(i);
    b.update();
    b.display();

    // Remove bala fora da tela
    if (b.y > height) {
      enemyBullets.remove(i);
      continue;
    }

    // colisão com o jogador
    if (b.hits(player)) {
      enemyBullets.remove(i);
      if (shieldActive) {
        // Escudo bloqueia o tiro
        shieldActive = false; // Desativa após um tiro
      } else {
        lives--;
        damageSound.play(); // Play damage sound
        createExplosion(player.x + 35, player.y + 35);
        if (lives <= 0) {
          gameOver = true;
          checarSalvarRecorde();
          
          // Music handling for GAME OVER <<<< NOVO
                  if (backgroundMusic != null && backgroundMusic.isPlaying()) {
                      backgroundMusic.stop();
                  }
                  if (victoryMusic != null && victoryMusic.isPlaying()) { // Stop victory music if somehow playing
                      victoryMusic.stop();
                  }
                  if (defeatMusic != null && !defeatMusic.isPlaying()) {
                      defeatMusic.play();
        }
      }
    }
  }
  }
}

void drawVictoryScreen() {
  background(0, 0, 50);
  textAlign(CENTER, CENTER);
  textSize(40);
  fill(0, 255, 100);
  text("Vitória!", width / 2, height / 2 - 60);

  textSize(20);
  fill(255);
  text("Você salvou a galáxia dos Kragons!", width / 2, height / 2);

  textSize(16);
  text("Pontuação final: " + score, width / 2, height / 2 + 40);

  fill(50, 50, 200);
  rect(menuButtonX, menuButtonY, menuButtonW, menuButtonH, 10);
  fill(255);
  text("Menu Principal", menuButtonX + menuButtonW / 2, menuButtonY + 25);
}

void updateItems() {
  for (int i = items.size() - 1; i >= 0; i--) {
    Item item = items.get(i);
    item.update();
    item.display();

    if (item.collected(player)) {
      if (item.type == 0) {
        playerFirePower = min(playerFirePower + 1, 3);
      } else if (item.type == 1) {
        speedBoost = true;
        speedBoostTimer = 300;
      } else if (item.type == 2) {
        shieldActive = true;
        shieldTimer = 300; // 5 segundos
      } else if (item.type == 3) {
        playerFirePower = min(playerFirePower + 1, 3); 
      }
      items.remove(i);
    } else if (item.y > height) {
      items.remove(i);
    }
  }
}

void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}
void updateBoss() {
  if (score >= 300 && !bossActive && !bossDefeated) {
    boss = new Boss(width / 2 - 75, -150, bossImg);
    bossActive = true;
  }

  if (bossActive && boss != null) {
    boss.update();
    boss.display();
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
  
    float creditsStartY = btnHard.y + btnHard.h + 60; // Posição Y inicial para os créditos, 60 pixels abaixo do botão "Difícil"
// --- Créditos Adicionados ---
  textSize(18); // Tamanho para o nome da marca
  fill(220, 220, 50); // Uma cor dourada/amarela para destaque da marca
  text("Advanced Troop Gamer", width / 2, creditsStartY);

  textSize(14); // Tamanho para o título "Criadores"
  fill(255);  // Cor branca para o restante do texto
  textSize(12); // Tamanho para os nomes dos criadores
  text("Kawan Marcus, Luana de Andrade", width / 2, creditsStartY + 50); // Espaçamento de 20px
  text("Miguel Moura e Nicolas Ramalho", width / 2, creditsStartY + 68); // Espaçamento de 18px para a próxima linha
  // --- Fim dos Créditos Adicionados ---

}

void drawGameOverScreen() {
  textAlign(CENTER);
  textSize(32);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 3);

  textSize(16);
  fill(255);
  text("Pressione R para reiniciar", width / 2, height / 2 + 30);

  text("Recorde: " + highScore, width / 2, height / 2 + -10);

  fill(50, 50, 200);
  rect(menuButtonX, menuButtonY, menuButtonW, menuButtonH, 10);
  fill(255);
  text("Menu Principal", menuButtonX + menuButtonW / 2, menuButtonY + 25);
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
  victory = false;

  player = new Player(width / 2 - 35, height - 80, playerImg1);
  enemies = new ArrayList<Enemy>();
  playerBullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<Bullet>();
  items = new ArrayList<Item>();
  particles = new ArrayList<Particle>();
  lives = 3;
  score = 0;
  shootCooldown = 0;
  playerFirePower = 1;
  speedBoost = false;
  spawnTimer = 60;
  gameOver = false;
  bossActive = false;
  bossDefeated = false;
  
  // Music Management <<<< NOVO / MODIFICADO
  if (victoryMusic != null && victoryMusic.isPlaying()) {
    victoryMusic.stop();
  }
  if (defeatMusic != null && defeatMusic.isPlaying()) {
    defeatMusic.stop();
  }
  if (backgroundMusic != null && !backgroundMusic.isPlaying()) {
    backgroundMusic.loop();
  } else if (backgroundMusic != null) { 
    backgroundMusic.stop(); 
    backgroundMusic.loop();
  }
}

void updatePlayerUpgrade() {
  if (score >= 150) player.setImage(playerImg3);
  else if (score >= 75) player.setImage(playerImg2);
  else player.setImage(playerImg1);
}

void createExplosion(float x, float y) {
  for (int i = 0; i < 20; i++) {
    particles.add(new Particle(x, y));
  }
}
class Player {
  float x, y;
  float speed = 5;
  int direction = 0;
  PImage img;

  Player(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.img = img;
  }

  void setImage(PImage newImg) {
    img = newImg;
  }

  void move(int dir) {
    direction = dir;
  }

  void update() {
    float currentSpeed = speedBoost ? speed * 1.5 : speed;
    x += direction * currentSpeed;
    x = constrain(x, 0, width - 70);
  }

  void display() {
    image(img, x, y, 70, 70);

    if (shieldActive) {
      noFill();
      stroke(0, 255, 255);
      strokeWeight(3);
      ellipse(x + 35, y + 35, 80, 80);
      noStroke();
    }
  }
}

class Enemy {
  float x, y;
  float speed;
  float shootChance;
  PImage img;

  Enemy(float x, float y, PImage img, float speed, float shootChance) {
    this.x = x;
    this.y = y;
    this.img = img;
    this.speed = speed;
    this.shootChance = shootChance;
  }

  void update() {
    y += speed;
    if (random(1) < shootChance) {
      enemyBullets.add(new Bullet(x + 25, y + 50, 4));
    }
  }

  void display() {
    image(img, x, y, 50, 50);
  }
}

class Boss {
  float x, y;
  float speed = 1;
  int health = 200;
  PImage img;
  int shootTimer = 0;
  boolean movingRight = true;

  Boss(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.img = img;
  }

  void update() {
    if (y < 50) {
      y += speed;
    } else {
      if (movingRight) x += 2;
      else x -= 2;
      if (x <= 0 || x + 150 >= width) movingRight = !movingRight;
    }

    shootTimer++;
    if (shootTimer >= 30) {
      enemyBullets.add(new Bullet(x + 30, y + 120, 5));
      enemyBullets.add(new Bullet(x + 120, y + 120, 5));
      shootTimer = 0;
    }
  }

  void display() {
    image(img, x, y, 150, 150);
    fill(255, 0, 0);
    rect(x, y - 10, 150, 5);
    fill(0, 255, 0);
    rect(x, y - 10, map(health, 0, 200, 0, 150), 5);
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
    return x > p.x && x < p.x + 70 && y > p.y && y < p.y + 70;
  }

  boolean hits(Enemy e) {
    return x > e.x && x < e.x + 50 && y > e.y && y < e.y + 50;
  }

  boolean hits(Boss b) {
    return x > b.x && x < b.x + 150 && y > b.y && y < b.y + 150;
  }
}

class Item {
  float x, y;
  int type; // 0 = aumento de tiro, 1 = velocidade

  Item(float x, float y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;
  }

  void update() {
    y += 2;
  }

  void display() {
    if (type == 0) fill(0, 150, 255);         // Power (azul-claro)
    else if (type == 1) fill(255, 140, 0);    // Velocidade (laranja)
    else if (type == 2) fill(0, 255, 255);    // Escudo (ciano)
    else if (type == 3) fill(255, 50, 50);    // Multi-tiro (vermelho)

    ellipse(x, y, 15, 15);
  }

  boolean collected(Player p) {
    return dist(x, y, p.x + 35, p.y + 35) < 30;
  }
}

class Particle {
  float x, y;
  float dx, dy;
  float lifespan = 255;

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    dx = random(-2, 2);
    dy = random(-2, 2);
  }

  void update() {
    x += dx;
    y += dy;
    lifespan -= 5;
  }

  void display() {
    noStroke();
    fill(255, lifespan);
    ellipse(x, y, 5, 5);
  }

  boolean isDead() {
    return lifespan <= 0;
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
  } else if (victory) {
    if (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
        mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH) {
      inMenu = true;
      victory = false;
      // Music for returning to menu <<<< NOVO
      if (victoryMusic != null && victoryMusic.isPlaying()) {
        victoryMusic.stop();
      }
      if (backgroundMusic != null && !backgroundMusic.isPlaying()) {
        backgroundMusic.loop(); // Restart background music for menu
      }
    }
  } else if (gameOver) {
    if (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
        mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH) {
      inMenu = true;
      
      if (defeatMusic != null && defeatMusic.isPlaying()) {
        defeatMusic.stop();
      }
      if (backgroundMusic != null && !backgroundMusic.isPlaying()) {
        backgroundMusic.loop(); // Restart background music for menu
      }
    }
  }
} 
void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (!inMenu && !mostrarHistoria && !gameOver && !victory) {
      paused = !paused;
      
      
       // Pause/Resume background music <<<< NOVO
      if (backgroundMusic != null) {
          if (paused) {
            if (backgroundMusic.isPlaying()) {
              backgroundMusic.pause();
            }
          } else {
            if(!backgroundMusic.isPlaying()){ 
                backgroundMusic.play(); 
            }
          }
      }
    }
  }

  if (mostrarHistoria) {
    if (key == ' ' || key == ' ') { 
      paginaHistoria++;
      if (paginaHistoria >= historia.length) {
        mostrarHistoria = false;
        // After story, go to menu by default
        inMenu = true;
      }
    }
  } else if (paused) { 
    return;
  }
   else { 
    if (!inMenu && !gameOver && !victory) { 
     
      if (key == 'a' || key == 'A' || keyCode == LEFT) {
        player.move(-1);
      } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
        player.move(1);
      } else if ((key == ' ' || Character.toLowerCase(key) == 'w' || keyCode == UP) && shootCooldown == 0) {
        shootSound.play();
        if (playerFirePower == 1) {
          playerBullets.add(new Bullet(player.x + 32, player.y, -7));
        } else if (playerFirePower == 2) {
          playerBullets.add(new Bullet(player.x + 20, player.y, -7));
          playerBullets.add(new Bullet(player.x + 44, player.y, -7));
        } else if (playerFirePower >= 3) {
          playerBullets.add(new Bullet(player.x + 15, player.y, -7));
          playerBullets.add(new Bullet(player.x + 32, player.y, -7));
          playerBullets.add(new Bullet(player.x + 49, player.y, -7));
        }
        shootCooldown = 20;
      }
    }

    if (gameOver && (key == 'r' || key == 'R')) {
      startGame(); 
      inMenu = false;          
      mostrarHistoria = false; 
    }
   }
}

void keyReleased() {
  if (!inMenu && (key == 'a' || key == 'A' || key == 'd' || key == 'D')) {
    player.move(0);
  }
}
