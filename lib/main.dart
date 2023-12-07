import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Forca(),
  ));
}

class Forca extends StatefulWidget {
  @override
  _ForcaState createState() => _ForcaState();
}

class _ForcaState extends State<Forca> {
  String palavraSecreta = '';
  List<String> letrasChutadas = [];
  List<String> letrasErradas = [];
  List<String> letrasCorretas = [];
  int tentativasErradas = 0;
  final int maxTentativas = 6;
  final controller = TextEditingController();
  final wordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    iniciarJogo();
    controller.addListener(() {
      final text = controller.text;
      if (text.length > 1) {
        controller.text = text.substring(0, 1);
      }
      if (!RegExp(r'[A-Za-z]').hasMatch(controller.text)) {
        controller.clear();
      }
    });
  }

  void iniciarJogo() async {
    final response = await http.get(Uri.parse('https://devmma.000webhostapp.com/palavras_forca.php'));
    print('Resposta do servidor: ${response.body}');
    var data = jsonDecode(response.body);
    palavraSecreta = data['palavra'].toUpperCase();
    print('Palavra do PHP: $palavraSecreta');
    setState(() {
      letrasChutadas = List.filled(palavraSecreta.length, '_');
      letrasErradas = [];
      letrasCorretas = [];
      tentativasErradas = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da Forca'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('@copy: Murilo Martins Alves, RA: 1431432312004', style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),
            Center(
              child: Text(
                letrasChutadas.join(' '),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Tentativas erradas: $tentativasErradas', style: TextStyle(fontSize: 18)),
                Text('Tentativas restantes: ${maxTentativas - tentativasErradas}', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),
            Text('Letras erradas: ${letrasErradas.join(', ')}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text('Tentar letra: ', style: TextStyle(fontSize: 18)),
                Container(
                  width: 50,
                  child: TextField(
                    controller: controller,
                    onChanged: (chute) {
                      chute = chute.toUpperCase();
                      if (chute == palavraSecreta) {
                        letrasChutadas = palavraSecreta.split('');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Jogo da Forca'),
                              content: Text('Parabéns, você venceu!'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    iniciarJogo();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (letrasErradas.contains(chute) || letrasCorretas.contains(chute)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Jogo da Forca'),
                              content: Text('Essa letra já foi inserida, por favor digite outra letra'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (palavraSecreta.contains(chute)) {
                        for (int i = 0; i < palavraSecreta.length; i++) {
                          if (palavraSecreta[i] == chute) {
                            setState(() {
                              letrasChutadas[i] = chute;
                              letrasCorretas.add(chute);
                            });
                          }
                        }
                        print('Palavra atual: ' + letrasChutadas.join(' '));
                        if (!letrasChutadas.contains('_')) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Jogo da Forca'),
                                content: Text('Parabéns, você venceu!'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      iniciarJogo();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        setState(() {
                          letrasErradas.add(chute);
                          tentativasErradas++;
                        });
                        if (tentativasErradas >= maxTentativas) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Jogo da Forca'),
                                content: Text('Você perdeu! A palavra era $palavraSecreta'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      iniciarJogo();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                      Future.delayed(Duration(seconds: 1), () {
                        controller.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text('Tentar palavra: ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: TextField(
                    controller: wordController,
                    maxLength: palavraSecreta.length,
                    onSubmitted: (word) {
                      word = word.toUpperCase();
                      if (word == palavraSecreta) {
                        letrasChutadas = palavraSecreta.split('');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Jogo da Forca'),
                              content: Text('Parabéns, você venceu!'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    iniciarJogo();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        setState(() {
                          tentativasErradas++;
                        });
                        if (tentativasErradas >= maxTentativas) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Jogo da Forca'),
                                content: Text('Você perdeu! A palavra era $palavraSecreta'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      iniciarJogo();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                      Future.delayed(Duration(seconds: 1), () {
                        wordController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
