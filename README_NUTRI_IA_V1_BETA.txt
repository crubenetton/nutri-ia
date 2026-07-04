Nutri IA v1.0 Beta

Esta versão foi limpa do build/cache e está preparada para uso sem Blaze.

Como rodar:
C:\flutter\bin\flutter pub get
C:\flutter\bin\flutter run -d chrome

Como publicar sem Blaze:
C:\flutter\bin\flutter build web
firebase.cmd deploy --only hosting

Importante:
- O arquivo firebase.json foi ajustado para Hosting apenas, evitando erro de Functions/Blaze.
- A pasta functions não foi incluída nesta versão para evitar deploy acidental com Blaze.
- A IA por foto atual é modo assistido/local.
