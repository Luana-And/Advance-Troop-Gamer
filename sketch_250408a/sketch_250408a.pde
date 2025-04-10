import processing.sound.*;

int cols, rows;
final int cardSize = 100;
final int telaLargura = 700;
final int telaAltura = 600;

int offsetX, offsetY;

PImage[][] boardImages;
boolean[][] revealed;

int botaoX = 0, botaoY = 0;
int botaoLargura = 200;
int botaoAltura = 50;

int[] firstPick = {-1, -1};
int[] secondPick = {-1, -1};
boolean checking = false;
int checkTime;

int matches = 0;
int totalPairs;
boolean mostrandoHistoria = false;

int tentativasRestantes;
boolean fimDeJogo = false;
boolean selecionandoModo = true;
boolean modoDificil = false;

String historia =
  "Há muito tempo, em uma floresta mágica escondida dos olhos humanos...\n" +
  "Um antigo guardião da natureza, desejando preservar a alegria dos animais para sempre,\n" +
  "lançou um feitiço encantado que selou as criaturas mais adoráveis dentro de cartas mágicas.\n\n" +
  "Filhotes brincalhões, corujas sábias, pandas sonolentos e até raposas curiosas...\n" +
  "Todos foram aprisionados, espalhados aleatoriamente em um tabuleiro misterioso.\n\n" +
  "Agora, só há uma maneira de libertá-los:\n" +
  "descobrir todos os pares de animais antes que o encanto se torne permanente.\n\n" +
  "Você é o escolhido pela própria floresta, com memória aguçada e coração corajoso...\n" +
  "Liberte cada criatura e traga a harmonia de volta à natureza.\n\n" +
  "O desafio começa agora.";

// Efeitos sonoros
SoundFile flipSound;
SoundFile matchSound;
SoundFile failSound;
SoundFile winSound;
SoundFile loseSound;
SoundFile clickSound;

void settings() {
  size(telaLargura, telaAltura);
}

void setup() {
  imageMode(CENTER);
  surface.setTitle("Jogo da Memória - Emojis Encantados");

  flipSound = new SoundFile(this, "flip.wav");
  matchSound = new SoundFile(this, "match.wav");
  failSound = new SoundFile(this, "fail.wav");
  winSound = new SoundFile(this, "win.wav");
  loseSound = new SoundFile(this, "lose.wav");
  clickSound = new SoundFile(this, "click.wav");
}

void draw() {
  background(173, 216, 230);

  if (selecionandoModo) {
    mostrarSelecaoModo();
    return;
  }

  if (mostrandoHistoria) {
    mostrarHistoria();
    return;
  }

  drawBoard();

  fill(0);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Tentativas restantes: " + tentativasRestantes, 20, 10);

  if (checking && millis() - checkTime > 1000) {
    checkMatch();
    checking = false;
  }

  if (matches == totalPairs) {
    mostrarMensagemFinal("Parabéns!");
  } else if (tentativasRestantes <= 0) {
    mostrarMensagemFinal("Fim de Jogo!");
  }
}

void mostrarSelecaoModo() {
  fill(0);
  textAlign(CENTER, TOP);
  textSize(24);
  text("Escolha o modo de jogo", width / 2, 80);

  // Botão Normal
  fill(100, 200, 100);
  rect(width / 2 - 110, 200, 100, 50, 10);
  fill(255);
  textSize(18);
  text("Normal", width / 2 - 60, 230);

  // Botão Difícil
  fill(200, 100, 100);
  rect(width / 2 + 10, 200, 100, 50, 10);
  fill(255);
  text("Difícil", width / 2 + 60, 230);
}

void iniciarJogo() {
  if (modoDificil) {
    cols = 6;
    rows = 6;
    tentativasRestantes = 20;
  } else {
    cols = 4;
    rows = 4;
    tentativasRestantes = 15;
  }

  offsetX = (telaLargura - cols * cardSize) / 2;
  offsetY = (telaAltura - rows * cardSize) / 2;

  boardImages = new PImage[cols][rows];
  revealed = new boolean[cols][rows];
  firstPick[0] = -1;
  secondPick[0] = -1;
  checking = false;
  matches = 0;
  fimDeJogo = false;
  mostrandoHistoria = true;
  selecionandoModo = false;
  totalPairs = (cols * rows) / 2;

  ArrayList<PImage> imagens = generateImages();
  int index = 0;
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      boardImages[i][j] = imagens.get(index++);
    }
  }
}

void mostrarHistoria() {
  fill(0);
  textSize(18);
  textAlign(LEFT, TOP);
  textLeading(28);
  text(historia, 20, 20, width - 40, height - 40);

  fill(50, 100, 200);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text("Clique para começar...", width / 2, height - 20);
}

void drawBoard() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = offsetX + i * cardSize;
      int y = offsetY + j * cardSize;

      stroke(0);
      fill(255);
      rect(x, y, cardSize, cardSize);

      if (revealed[i][j]) {
        image(boardImages[i][j], x + cardSize / 2, y + cardSize / 2);
      } else {
        fill(150);
        rect(x + 5, y + 5, cardSize - 10, cardSize - 10);
      }
    }
  }
}

void mousePressed() {
  if (selecionandoModo) {
    if (mouseX > width / 2 - 110 && mouseX < width / 2 - 10 &&
        mouseY > 200 && mouseY < 250) {
      modoDificil = false;
      clickSound.play();
      iniciarJogo();
    } else if (mouseX > width / 2 + 10 && mouseX < width / 2 + 110 &&
               mouseY > 200 && mouseY < 250) {
      modoDificil = true;
      clickSound.play();
      iniciarJogo();
    }
    return;
  }

  if (fimDeJogo) {
    if (mouseX > botaoX && mouseX < botaoX + botaoLargura &&
        mouseY > botaoY && mouseY < botaoY + botaoAltura) {
      clickSound.play();
      reiniciarJogo();
      return;
    }
  }

  if (mostrandoHistoria) {
    mostrandoHistoria = false;
    clickSound.play();
    return;
  }

  if (checking || fimDeJogo) return;

  int x = (mouseX - offsetX) / cardSize;
  int y = (mouseY - offsetY) / cardSize;

  if (x >= 0 && x < cols && y >= 0 && y < rows && !revealed[x][y]) {
    revealed[x][y] = true;
    flipSound.play();

    if (firstPick[0] == -1) {
      firstPick[0] = x;
      firstPick[1] = y;
    } else if (secondPick[0] == -1) {
      secondPick[0] = x;
      secondPick[1] = y;
      checking = true;
      checkTime = millis();
    }
  }
}

void checkMatch() {
  PImage first = boardImages[firstPick[0]][firstPick[1]];
  PImage second = boardImages[secondPick[0]][secondPick[1]];

  if (first != second) {
    revealed[firstPick[0]][firstPick[1]] = false;
    revealed[secondPick[0]][secondPick[1]] = false;
    tentativasRestantes--;
    failSound.play();
  } else {
    matches++;
    matchSound.play();
  }

  firstPick[0] = -1;
  secondPick[0] = -1;
}

void mostrarMensagemFinal(String mensagem) {
  fill(0, 200, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text(mensagem, width / 2, height / 2 - 40);

  botaoX = width / 2 - botaoLargura / 2;
  botaoY = height / 2 + 10;

  fill(50, 150, 250);
  rect(botaoX, botaoY, botaoLargura, botaoAltura, 10);

  fill(255);
  textSize(20);
  text("Reiniciar", width / 2, botaoY + botaoAltura / 2);

  fimDeJogo = true;

  if (mensagem.equals("Parabéns!")) {
    winSound.play();
  } else {
    loseSound.play();
  }

  noLoop();
}

void reiniciarJogo() {
  iniciarJogo();
  loop();
}

ArrayList<PImage> generateImages() {
  String[] urls = {
    "https://i.pinimg.com/736x/22/df/ee/22dfee754a59ae06e41c7070fbf71f1f.jpg",
    "https://i.pinimg.com/736x/2f/1f/3e/2f1f3e3317e14d22b7513c91d1a7d50a.jpg",
    "https://i.pinimg.com/736x/af/ac/b7/afacb78aa35343cd5a49f8ea56b5b1b1.jpg",
    "https://i.pinimg.com/736x/aa/8f/a2/aa8fa2fd9660257347033dcff18c171d.jpg",
    "https://i.pinimg.com/736x/93/d3/2e/93d32e82acf0496daa8b8dd7380ca8c5.jpg",
    "https://i.pinimg.com/736x/f6/96/1f/f6961f7c84341ca40c813fd972cf9e63.jpg",
    "https://i.pinimg.com/736x/6a/1f/99/6a1f99724266aa8134a4e975993fa1ef.jpg",
    "https://i.pinimg.com/736x/8a/e5/c8/8ae5c897cbc230a352d698da334ac8aa.jpg",
    // Adicione mais imagens se for jogar no modo difícil (6x6 = 18 pares)
    "https://i.pinimg.com/736x/e3/54/13/e35413a55ffcd11f680361f13806654b.jpg",
    "https://i.pinimg.com/736x/36/0d/ea/360deac358acc13e46d9ae73cc12baca.jpg",
    "https://i.pinimg.com/736x/ef/f6/b7/eff6b738f12d04951bbf98e1de453707.jpg",
    "https://i.pinimg.com/736x/5e/f8/15/5ef815dcd2d391384eea6d9cb662d041.jpg",
    "https://i.pinimg.com/736x/8d/a2/76/8da27692a9a89250a46e9e04ca7fe98b.jpg",
    "https://i.pinimg.com/736x/ea/3b/6b/ea3b6b22dade24a2acd2e3603505e15e.jpg",
    "https://i.pinimg.com/736x/31/34/8e/31348ee2c8964e2e6792b4b2eff805e5.jpg",
    "https://i.pinimg.com/736x/9c/88/b6/9c88b67424c08fa96eea985a259ec94e.jpg",
    "https://i.pinimg.com/736x/16/1b/54/161b54ecc97a246ed263d4b7f3c811a3.jpg",
    "https://i.pinimg.com/736x/dd/e0/7b/dde07b6f656de77f09e2ee29362b2db1.jpg"
  };

  ArrayList<PImage> list = new ArrayList<PImage>();

  for (String url : urls) {
    if (list.size() >= totalPairs * 2) break; // usar só o necessário
    PImage img = loadImage(url);
    img.resize(cardSize - 20, cardSize - 20);
    list.add(img);
    list.add(img);
  }

  java.util.Collections.shuffle(list);
  return list;
}  
