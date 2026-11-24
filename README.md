# T8S con DOSBox-X para Windows de 64 bits

TRANSYT-8S (T8S) es un programa de MS-DOS, por lo que no corre de forma nativa en Windows de 64 bits. Este repositorio reúne lo necesario para ejecutarlo con DOSBox-X: el lote `CORRER_T8S.bat`, que corre todas las redes de la carpeta `redes` en una sola sesión de DOSBox-X y deja cada salida en la carpeta `resultados`, junto con un caso de ejemplo ya corrido.

## Contenido

```
CORRER_T8S.bat     corre todas las redes *.prn de la carpeta redes
mingw/             DOSBox-X 2026.10.01 para Windows de 64 bits
redes/             redes de entrada de T8S (aquí se dejan los .prn a correr)
resultados/        salidas de T8S, una por red: "resultados - NOMBRE_RED.txt"
T8S.EXE            no se incluye: debe copiarlo cada usuario (ver abajo)
```

## Puesta en marcha

1. Descargue o clone el repositorio en una carpeta cuya ruta no tenga espacios, por ejemplo `C:\T8S`. El lote se detiene si la ruta tiene espacios, porque DOSBox-X monta esa carpeta como unidad de disco.
2. Copie su `T8S.EXE` en la raíz de la carpeta, junto a `CORRER_T8S.bat`. El programa no viene en el repositorio porque su uso es restringido según los términos fijados por la UOCT y SECTRA, como indica el propio encabezado de sus salidas.
3. Deje en `redes` los archivos `.prn` que quiera correr.
4. Haga doble clic en `CORRER_T8S.bat`.

El lote busca solo `dosbox-x.exe` dentro de la carpeta y guarda la ruta encontrada en `DOSBOX_RUTA.txt`. Luego copia cada red a una carpeta temporal `trabajo` con un nombre corto (`N001.PRN`, `N002.PRN`, ...) y abre una sola sesión de DOSBox-X. En ella, el comando `AUTOTYPE` escribe en T8S el nombre de cada archivo de datos y de su salida. Al terminar, cada salida se mueve a `resultados\resultados - NOMBRE_RED.txt`. Mientras DOSBox-X está abierto no se debe tocar el teclado dentro de su ventana.

Al inicio del lote hay cuatro parámetros que se pueden ajustar. `PAUSA=1` deja DOSBox-X abierto al final para revisar la pantalla. `ESPERA` y `PACE` son los segundos antes de escribir y entre teclas; si alguna red queda sin resultado, suba `ESPERA` a 4 o `PACE` a 0.3. `EXT` es la extensión de los archivos de red.

## Caso de ejemplo

Las redes `redes/EJEMPLO_PM.prn` y `redes/EJEMPLO_PT.prn` son ficticias y sirven para probar la instalación. Representan una avenida oriente-poniente con dos intersecciones semaforizadas de dos etapas (nodos 1 y 2, separados por 300 m), un cruce con prioridad al poniente (nodo 3) donde un pasaje cede el paso a la avenida, y dos arcos de buses. Son 12 arcos en total, con un ciclo de 90 s, numerados como 100·nodo + 10·acceso + clase. El periodo PT tiene flujos 10% menores que PM y otra programación semafórica.

Sus salidas de T8S están en `resultados/`. Para comprobar que la instalación funciona, corra el lote y compare las nuevas salidas con las del repositorio: los valores deben ser idénticos, salvo la fecha y la hora de ejecución que T8S imprime en el encabezado.

## Licencias

El archivo LICENSE (MIT) cubre el lote `CORRER_T8S.bat`, la documentación y las redes de ejemplo. DOSBox-X, en la carpeta `mingw`, es software libre bajo licencia GPL-2.0; su código fuente está en https://github.com/joncampbell123/dosbox-x. T8S.EXE no forma parte de este repositorio.
