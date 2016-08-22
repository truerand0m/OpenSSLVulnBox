#Creamos los directorios donde instalaremos
mkdir -p /usr/heartbleed/gvazquez/openssl
mkdir -p /usr/heartbleed/gvazquez/apache

#Descargamos una version vulnerable de openssl
wget https://www.openssl.org/source/openssl-1.0.1f.tar.gz
#La descomprimimos
tar xzfv openssl-1.0.1f.tar.gz
cd openssl-1.0.1f
./config --prefix=/usr/heartbleed/gvazquez/openssl/
make
make install
#Esto da un error lo solucionamos con lo siguiente
make install_sw

#Regresamos al directorio principal
cd /usr/hearbleed/gvazquez/

#Descargamos apache http server, apr-1.52 y apr-util
wget www-us.apache.org/dist/httpd/httpd-2.2.31.tar.gz
wget www-us.apache.org/dist/apr/apr-1.5.2.tar.gz
wget www-us.apache.org/dist/apr/apr-util-1.5.4.tar.gz
#Descomprimimos
tar zxvf httpd-2.2.31.tar.gz
cd httpd-2.2.31/srclib
tar zxvf ../../apr-1.5.2.tar.gz
#Hacemos una liga suave
ln -s apr-1.5.2/ apr
tar zxvf ../../apr-utils-1.5.4.tar.gz
#Hacemos otra liga 
ln -s apr-util-1.5.4/ apr-util
#Configuramos apache

#NOTA: PARECE QUE FALTA UN cd ..
cd ..
#NOTA: explicar porque quitamos ldl
#NOTA faltaba una s
#v1env LDLFLAGS="-ldl" ./configure --prefix=/usr/heartbleed/gvazquez/apache/ --with-included-apr --enable-ssl --with-ssl=/usr/heartbleed/gvazque/openssl --enable-ssl-staticlib-deps --enable-mods-static=ssl

#v2:
export LIBS=-ldl
./configure --prefix=/usr/heartbleed/gvazquez/apache/ --with-included-apr --enable-ssl --with-ssl=/usr/heartbleed/gvazquez/openssl --enable-ssl-staticlib-deps --enable-mods-static=ssl
#v2
#Hacemos make
make
#Instalamos
make install

#Iniciamos apache para probar que fue instalado correctamente
#v2
cd ..
cd apache
cd bin
#v2
./apachectl start

#Generamos las llaves
#NOTA: Explicar parametros
#NOTA: Ver que comando se uso al final, ver con virtual
cd /usr/heartbleed/gvazquez/openssl/bin 
./openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 345
#Ingresamos los datos y la llave es generada
#v2
#copiamos la llave al root
cp cert.pem ../../
cp key.pem	../../
#v2

#v2
cd ..
cd ..
cd apache/bin/
#v2
#Detenemos apache con
#NOTA: poner la ruta antes
./apachectl stop
#Configuramos apache para que use los certificados
cd /usr/heartbleed/gvazquez/apache/conf
#V1nano httpd.conf
#Agregamos escucha en el puerto 443 y el virtualhost:
#Listen 443
#Al final:
#<VirtualHost *:443>
#	SSLEngine on
#	SSLCertificateFile		/usr/heartbleed/gvazquez/cert.pem
#	SSLCertificateKeyFile	/usr/heartbleed/gvazquez/key.pem
#</VirtualHost>
#v2
echo "Listen 443" >> httpd.conf
echo "<VirtualHost *:443>" >> httpd.conf
echo "SSLEngine on" >> httpd.conf
echo "SSLCertificateFile /usr/heartbleed/gvazquez/cert.pem" >> httpd.conf
echo "SSLCertificateKeyFile /usr/heartbleed/gvazquez/key.pem" >> httpd.conf
echo "</VirtualHost>" >> httpd.conf
#v2

#v3
#modificamos la pagina
cd /usr/heartbleed/gvazquez/apache/htdocs/
echo "<html>" > index.html
echo "<body>" >> index.html
echo "<h1>"	>> index.html
echo "Gonzalo VC" >> index.html
echo "</h1>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
#v3

#Reiniciamos apache
cd /usr/heartbleed/gvazquez/apache/bin
#v2 aqui puede ocurrir un error si ocurre eliminar ./apache/logs/httpd.id
./apachectl stop
./apachectl start
#Ingresamos la contrasena que definimos al generar los certificados
#Es todo

#Probando: Cambiamos la configuracion del adaptador de red a Host-Only
#Ahora podemos conectarnos desde la maquina host a la guest
#Ingresando en el navegador host
https://{ipmaquinavirtual}
#Aparece un error diciendo que la conexion no es segura (el cert esta autofirmado)
#Agregamos la excepcion
#Para ver que es vulnerable usamos nmap desde la maquina host
#NOTA: Explicar los parametros
nmap -sV -p 443 --script=ssl-heartbleed.nse 192.168.56.101 
#DICIENDONOS QUE:
#ssl-heartbleed: VULNERABLE
