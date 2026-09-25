# Forest Ninja Adventure — Flutter + Dart + Web

Projeto de jogo 2D em Flutter/Dart, preparado para ser guardado no GitHub e publicado automaticamente como Flutter Web pelo GitHub Pages.

## O que está incluído

- `lib/` — código Dart do jogo.
- `assets/` — personagens, inimigos, moedas, fundo e plataformas.
- `pubspec.yaml` — configuração do Flutter e dos assets.
- `web/` — arquivos de inicialização do Flutter Web.
- `.github/workflows/deploy-web.yml` — build automático e publicação no GitHub Pages.

## Testar na escola

Abra esta pasta no VS Code e rode:

```bash
flutter pub get
flutter run
```

Para testar no Chrome:

```bash
flutter run -d chrome
```

## Colocar no GitHub e publicar online

1. Crie um repositório no GitHub, por exemplo `meu-jogo-flutter`.
2. Envie para o repositório o CONTEÚDO desta pasta: `lib`, `assets`, `web`, `pubspec.yaml`, `README.md` e `.github`.
3. Faça commit dos arquivos na branch `main`.
4. No GitHub, abra `Settings` → `Pages`.
5. Em `Build and deployment` → `Source`, selecione `GitHub Actions`.
6. Vá em `Actions` e aguarde o fluxo `Build and deploy Flutter Web` terminar.
7. Depois do deploy, em `Settings` → `Pages` aparecerá o endereço publicado.

O workflow executa `flutter pub get`, `flutter analyze` e `flutter build web --release`. Ele usa o nome do repositório como `base-href` para funcionar em uma URL do tipo `https://USUARIO.github.io/NOME-DO-REPOSITORIO/`.

## Trocar imagens

Mantenha os mesmos nomes para trocar automaticamente:

```text
assets/images/player/ninja.png
assets/images/enemies/skeleton.png
assets/images/items/coin.png
assets/images/background/forest.png
assets/images/platforms/large.png
assets/images/platforms/medium.png
assets/images/platforms/rocky.png
```

Os arquivos de personagem, inimigo, moeda e plataformas devem ter fundo transparente quando o visual precisar ficar recortado sobre o cenário.

## Observação importante

O projeto foi preparado para Flutter Web, mas a compilação final depende da versão do Flutter usada pelo ambiente. O GitHub Actions instala o Flutter no runner e mostra qualquer erro de análise ou build na aba `Actions`.
