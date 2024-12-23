# **Encuadrado**

## **Firebase**

Este proyeto se conectó directamente con Firebase, para visualizar la base de datos del proyecto pueden ingresar a este link: [Firestore Database](https://console.firebase.google.com/u/1/project/encuadrado-e1dd8/firestore/).

Dentro de la base de datos podrán encontrar la siguiente estructura:

1.   Colección **Servicios**: Cada vez que un usuario *Admin* ingresa un nuevo servicio dentro de la aplicación, este se guarda como documento en la colección dentro de Firebase, cada documento posee un campo *userId*, para poder referenciar al profesional que añadió tal servicio.

2.   Colección **users**: Se encarga de manejar toda la autenticación de usuarios dentro de Firebase.

3.  Subcolección **appointments**: Cada vez que se agenda una cita por parte de un *User*, se genera una subcolección de documentos asignada a cada usuario (profesional y cliente), que contiene las citas registradas con sus datos. Es importante entender que cada *documento user* posee una **subcolección appointments** con *documentos de citas*, la cual contiene los ID's de profesional, cliente y servicio para referenciarlos y obtener toda la información correspondiente.

## **Aplicación**

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

## **Setup Inicial**

El proyecto fue testeado en un simulador de Android (Pixel 7 Pro API 34) y iOS (iPhone 16 - iOS 18.2). Como recomendación, para probarlo rápidamente es mejor utilizar el simulador de Android o, en su defecto, descargar el archivo .apk contenido en **build\app\outputs\flutter-apk\app-release.apk** después de generarlo con el comando mencionado abajo e instalarlo en un dispositivo Android físico.

Adicionalmente también se puede testear en el navegador de Chrome pero algunas funcionalidades como el scroll horizontal no funcionan correctamente con el mouse del computador según las pruebas realizadas.

Comandos recomendables al descargar el repositorio (solo en caso de ser necesario):
- flutter upgrade (actualiza el SDK de Flutter a su versión más reciente)
- flutter pub get (obtiene o actualiza dependencias)
- flutter build apk (generar .apk para Android)
- versión mínima de iOS en Podfile: 13.0

Todo lo demás debería funcionar correctamente, pero en caso de enfrentar problemas para compilar la aplicación, o ejecutarla en alguno de los dispositivos, por favor contactarme: pablos1806@gmail.com
