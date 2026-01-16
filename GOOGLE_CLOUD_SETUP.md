# Google Cloud & Drive API Setup Guide

Para que o backup no Google Drive funcione, você precisa configurar um projeto no Google Cloud Console e obter as credenciais para o seu aplicativo. Siga os passos abaixo:

## Passo 1: Criar Projeto no Google Cloud
1. Acesse: [console.cloud.google.com](https://console.cloud.google.com/).
2. Crie um **Novo Projeto** (dê o nome de "Good Day App" por exemplo).
3. Selecione o projeto criado.

## Passo 2: Ativar API do Google Drive
1. No menu lateral, vá em **APIs e Serviços > Biblioteca**.
2. Pesquise por **"Google Drive API"**.
3. Clique nela e depois em **Ativar**.

## Passo 3: Configurar Tela de Consentimento OAuth
1. Vá em **APIs e Serviços > Tela de consentimento OAuth**.
2. Em "User Type", escolha **Externo** (ou Teste) e clique em Criar.
3. Preencha:
    - **Nome do App**: Good Day
    - **Email de suporte**: Seu email
    - **Dados de contato do desenvolvedor**: Seu email
4. Clique em Salvar e Continuar.
5. **Escopos**: Clique em "Adicionar ou Remover Escopos".
    - Procure por `.../auth/drive.appdata` (Ver e gerenciar seus próprios dados de configuração no Google Drive).
    - Selecione-o e salve.
6. **Usuários de Teste**: Adicione o SEU email do Google (conta que você vai usar para testar no celular). 
   - *Importante: Enquanto o app não for verificado pelo Google, apenas emails listados aqui conseguirão fazer login.*

## Passo 4: Criar Credenciais (OAuth Client ID)
1. Vá em **APIs e Serviços > Credenciais**.
2. Clique em **Criar Credenciais > ID do cliente OAuth**.
3. Tipo de Aplicativo: **Android**.
4. **Nome**: Client Android (pode ser qualquer um).
5. **Nome do pacote**: `com.example.good_day` (ou o que estiver no seu `AndroidManifest.xml` / `build.gradle`).
6. **Impressão digital do certificado SHA-1**:
    - Para pegar o SHA-1 da sua chave de Debug (usada quando roda `flutter run`), abra o terminal do projeto e rode:
      - **Windows**: `keytool -list -v -keystore "C:\Users\<SEU_USUARIO>\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android`
      - *Nota: Se `keytool` não for reconhecido, ele fica na pasta `bin` do Java/JDK.*
    - Copie o código SHA-1 (ex: `BB:0D:AC:74:D3:21:E5:43...`) e cole no site.
7. Clique em **Criar**.

## Passo 5: Testar
1. Rode o aplicativo novamente (`flutter run`).
2. Vá em Configurações > Backup.
3. Clique em **Connect Google Drive**.
4. Selecione sua conta e dê permissão.

---

> [!WARNING]
> Se der erro `10` ou `Developer Error`, verifique se o **SHA-1** está correto e se o **Nome do Pacote** bate exatamente com o do seu app.
> Se der erro `12500`, geralmente é falta de configurar o **Email de Suporte** na tela de consentimento.
