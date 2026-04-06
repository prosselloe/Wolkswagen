# Blueprint del Projecte: Volkswagen Classic App

## Visió General

Aquesta aplicació és una eina de referència completa i un catàleg interactiu per a entusiastes dels cotxes clàssics de Volkswagen. Permet als usuaris explorar una base de dades de models històrics, identificar vehicles a partir dels seus números de sèrie, i aprendre sobre la història de la marca a través de les seves plantes de producció. L'aplicació prioritza una experiència d'usuari neta, una navegació intuïtiva i una presentació visual atractiva de les dades.

## Característiques Implementades

- **Catàleg de Models**:
    - Graella visualment atractiva de models clàssics de VW.
    - **Cerca Dinàmica**: Cerca per nom de model en temps real.
    - **Filtratge Avançat**: Filtra els models per planta de fabricació.
    - **Ordenació Flexible**: Ordena la llista per nom, any de producció o nombre d'unitats produïdes.

- **Pantalla de Detalls del Model**:
    - **Transició Hero**: Animació suau de la imatge del model des de la llista fins a la pantalla de detalls.
    - **Informació Completa**:
        - Imatge d'alta qualitat.
        - Descripció històrica i dades tècniques (dissenyador, motor, etc.).
        - Llista detallada de versions amb anys de model i rangs de números de bastidor.
        - Secció de models relacionats per a una navegació contínua.

- **Eines d'Identificació de Vehicles**:
    - **Cerca per Número de Bastidor**: Eina que permet introduir un número de bastidor clàssic (fins a 10 dígits) per identificar el model, l'any del model i una data de producció estimada.
    - **Descodificador de VIN**: Una utilitat per a vehicles més moderns que descodifica un Número d'Identificació del Vehicle (VIN) de 17 dígits per obtenir informació detallada sobre el cotxe, com el país de fabricació, la planta de muntatge i l'any del model.

- **Visualització Geogràfica**:
    - **Mapa de Plantes**: Un mapa interactiu (`flutter_map`) que mostra la ubicació de les plantes de producció de Volkswagen arreu del món, amb marcadors personalitzats.

- **Personalització i Usabilitat**:
    - **Temes Clar i Fosc**: Suport complet per a temes clar i fosc, amb una paleta de colors consistent i adaptada.
    - **Localització**: L'aplicació està completament localitzada en català (`ca`).

- **Pantalla d'Informació**:
    - Una secció "Quant a l'aplicació" que carrega dinàmicament el contingut del fitxer `README.md`.
    - Llista de crèdits a projectes i comunitats externes amb enllaços directes.

## Estil i Disseny (UI/UX)

- **Tipografia**: `Google Fonts` s'utilitza per a una estètica moderna i llegible:
    - **Títols**: `Exo 2` per a una aparença més tècnica i moderna.
    - **Text del Cos**: `Lato` per a una llegibilitat òptima.
- **Paleta de Colors**:
    - **Color Primari**: Blau corporatiu de Volkswagen (`#001e50`) utilitzat a l'AppBar i elements clau.
    - **Esquema de Colors**: S'utilitza `ColorScheme.fromSeed` per generar paletes harmonioses per als temes clar i fosc.
    - **Contrast**: El text i les icones de l'AppBar són sempre blancs per garantir un contrast perfecte sobre el fons blau fosc.
- **Components Visuals**:
    - **Targetes (`Card`)**: S'utilitzen per agrupar informació, amb cantonades arrodonides i ombres subtils per donar una sensació de profunditat.
    - **Consistència**: Es manté un disseny coherent a tota l'aplicació a través de temes de components centralitzats (`appBarTheme`, `cardTheme`, etc.).

## Estructura i Arquitectura del Projecte

- **Gestió d'Estat**: S'utilitza el paquet `provider` per a la gestió de l'estat global, com el tema actual (`ThemeProvider`) i les dades dels models (`ModelProvider`).
- **Navegació**: S'implementa un sistema de rutes declaratiu amb `go_router` per a una navegació robusta i clara entre pantalles.
- **Estructura de Fitxers**:
    - `lib/`
        - `main.dart`: Punt d'entrada. Configuració de `MaterialApp`, `GoRouter`, i `Providers`.
        - `models/`: Classes de dades (`VwModel`, `Plant`, `ChassisInfo`).
        - `providers/`: `ChangeNotifiers` per a la gestió de l'estat (`ModelProvider`, `LocaleProvider`, etc.).
        - `services/`: Lògica de negoci i càrrega de dades (`VwService`, `VinDecoder`).
        - `screens/`: Widgets que representen pantalles completes (`HomeScreen`, `DetailScreen`, `AboutScreen`).
        - `widgets/`: Widgets reutilitzables (`PlantMap`, `ChassisSearchDialog`, `VinDecoderDialog`).
    - `assets/`
        - `data/`: Fitxers de dades en format JSON (`db_*.json`, `plants.json`).
        - `images/`: Imatges dels models i logo de l'aplicació.
- `pubspec.yaml`: Defineix les dependències i la configuració dels `assets` (inclosos fitxers de dades, imatges i el `README.md`).
- `blueprint.md`: Aquest fitxer, documentació tècnica del projecte.
