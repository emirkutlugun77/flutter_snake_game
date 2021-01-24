import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static List<int> snakePosition = [
    15,
    25,
    35,
    45,
    55
  ]; // yılanın başlangıç pozisyonu
  int numberOfSquares = 760; //ekranı 760 parçaya bölüyoruz

  static var randomNumber =
      Random(); //dart math kütüphanesini kullanarak elma için yeni bir yer oluşturuyoruz
  int food = randomNumber.nextInt(50);
  void generateNewFood() {
    food = randomNumber.nextInt(50);
  }

  void startGame() {
    //alttaki start düğmesine basıncabu fonksiyon çalışıyor
    snakePosition = [15, 25, 35, 45, 55];
    const duration = const Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      //timer fonksiyonu timer.periodic() constructor methodu ile çağırıldığında timer.cancel() methodu çağırılana
      //kadar belirtilen zaman aralığında kendi bloğundaki işlemleri tekrar eder, örnek:duration=1 saniye ise her saniye en baştan çalışır
      updateSnake();
      if (gameOver()) {
        timer
            .cancel(); //eğer oyun biterse timerı durdurup yılanın hareket etmesini engelliyoruz
        _showGameOverScreen();
      }
    });
  }

  var direction =
      'down'; //yılanın hareketeni yönlerle kontrol ediyoruz ve oyun başlarken yılan aşağı doğru iniyor.
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > 740) {
            //eğer yılan aşağı gidiyorsa ve en alta geldiyse yoluna en üstten devam eder,
            //if döngüsü bu özel durumu kontrol ediyor. Not:760 tane kare var ve 20 tane sütun vardı yani tek bir yatayda 20 kare var,
            //bu yüzden 740-760 arası en uç olur
            //diğer durumların da açıklamaları çok benzer hepsini yazmıyorum
            snakePosition.add(snakePosition.last + 20 - 760);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }

          break;

        case 'up':
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + 760);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;

        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }

          break;

        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;

        default:
      }
      //update metodunda her şekilde bir tane kare yılana ekleniyor, ama eğer yılan elmayı almadıysa bir parça da siliniyor yani boyutu aynı kalıyor
      //aşağıdaki if kondisyonu sağlanırsa silme işlemi gerçekleşmiyor ve yılanın boyutu 1 artıyor.
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  //aşağıdaki algoritmayı kendiniz düşünmenizi istiyorum, eğer anlamadığınız bir yer olursa sorun bana
  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count += 1;
        }
        if (count == 2) {
          return true;
        }
      }
    }
    return false;
  }

  //önceki derste gördüğümüz showDialog() fonksiyonunu kullandık, bu fonksiyon kullanıcı önüne bir pop-up window çıkartıyor
  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'),
            content: Text('You\'re score: ' + snakePosition.length.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('Play Again'),
                onPressed: () {
                  startGame();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              //kullanıcı hareketlerini kaydetmek ve bu hareketlere bağlı olarak yönü değiştirmek için GestureDetector widget'ına bağlı
              //fonksiyonları kullanıyoruz, bu deltaları anlamaya çalışırken telefonu bir koordinat düzlemi gibi düşünebilirsiniz
              onVerticalDragUpdate: (details) {
                //eğer yılan yukarı dışında herhangi bir yöne gidiyorsa ve değişim aşağı doğruysa
                //(yani elinizi aşağı kaydırırsanız yönünüz 'down' olarak değişir)
                //diğerleri için de benzer durumlar söz konusu
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: Container(
                child: GridView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), //bu kısım yazıldığı sürece gridView ne kadar uzun olursa olsun ekranı aşağı kaydıramazsınız
                    itemCount: 760, //GridView da kaç tane kare olucak
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20), //kaç tane sütun olucak
                    itemBuilder: (BuildContext context, int index) {
                      //item builder içerisinde mantıksal işlemler yapabilirsiniz,
                      //burda her kareye atanan bir index var, ve biz bu index numberlarını kullanarak, kareleri boyuyoruz
                      //yeşile boyanan kareler yılanı, kırmızılar elmayı ve siyah olanlar boş alanları temsil etmekte
                      //bu kareleri boyarken updateSnake() fonksiyonunda güncellediğimiz sayıları kullanıyoruz
                      //örnek olarak yılan [25,45,65,85,125 ] ise bu index numbera sahip kareleri boyuyoruz
                      //timer fonksiyonunda yaptığımız işlemleri setState(){} methodu içinde  aldığımız için bu kısım da anlık olarak değişiyorr

                      if (snakePosition.contains(index)) {
                        return Center(
                          child: snakeContainer(Colors.green),
                        );
                      }
                      if (index == food) {
                        return snakeContainer(Colors.red);
                      } else {
                        return snakeContainer(Colors.grey[900]);
                      }
                    }),
              ),
            ),
          ),

          //START BUTONU
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: startGame,
                  child: Text(
                    's t a r t',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          )
          //START BUTONU
        ],
      ),
    );
  }

  //GridView de kullanılan her bir kare için UI kodu
  Container snakeContainer(Color color) {
    return Container(
      padding: EdgeInsets.all(2),
      child: ClipRRect(
        child: Container(
          color: color,
        ),
      ),
    );
  }
}
