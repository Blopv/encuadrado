# Encuadrado

Este proyeto se conectó directamente con Firebase, para visualizar la base de datos del proyecto pueden ingresar a este link: [Firestore Database](https://console.firebase.google.com/u/1/project/encuadrado-e1dd8/firestore/).

Para iniciar sesión, pueden ingresar con las siguientes credenciales de usuarios de ejemplo creados (los cuales ya tienen agendas y servicios), o pueden registrarse y crear una nueva cuenta.

- Admin 1: 
    - admin1@test.com
    - admin123

- Admin 2: 
    - admin2@test.com
    - admin123

- User 1: 
    - user1@test.com
    - user123

- User 2: 
    - user2@test.com
    - user123

Se recomienda que creen sus propias cuentas, agreguen servicios como Admin, o agenden citas como User, así podrán probar las funcionalidades completas que se solicitaban.

Dentro de la aplicación, encontrarán una interfaz interactiva, junto con una NavBar que posee 3 elementos:
- Botón Home.
- Botón '+': Dependiendo del tipo de usuario, abrirá un Bottom Sheet para añadir un Servicio (Admin) o redirigirá a la sección de Agendar un Servicio (User).
- Botón de Logout.

## Setup Inicial

El proyecto fue testeado en un simulador de Android (Pixel 7 Pro API 34) y iOS (iPhone 16 - iOS 18.2), no se dejó ningún archivo .apk, pero como recomendación, para probarlo rápidamente, es mejor utilizar el simulador de Android.

Único comando recomendable al descargar la carpeta sería:
- flutter pub get

Todo lo demás debería funcionar correctamente, pero en caso de enfrentar problemas para compilar la aplicación, o ejecutarla en alguno de los dispositivos, por favor contactarme: pablos1806@gmail.com
